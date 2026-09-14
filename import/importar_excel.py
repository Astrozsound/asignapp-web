#!/usr/bin/env python3
"""
INVENTARIO HYCE — importador del Excel original.

No modifica el archivo de origen. Es repetible: genera SQL idempotente
(ON CONFLICT en SKU + client_uuid determinista en los movimientos de
carga inicial), así que puede ejecutarse varias veces durante el
desarrollo sin duplicar stock.

Regla estricta: NO se inventan datos. Todo registro ambiguo se conserva
y se marca REQUIERE_REVISION con el motivo.
"""
import hashlib
import re
import unicodedata
from difflib import SequenceMatcher
from pathlib import Path

import openpyxl
import pandas as pd

ORIGEN = Path("/mnt/user-data/uploads/Inventario_Constructura_HYCE.xlsx")
SALIDA = Path("/home/claude/hyce/import")
SALIDA.mkdir(parents=True, exist_ok=True)

# ------------------------------------------------------------------
# 1. CLASIFICACIÓN DE HOJAS
#    No todas las hojas son stock actual. Esta es la decisión central
#    del importador y queda documentada aquí.
# ------------------------------------------------------------------
HOJAS = {
    "Inventario Equipo":        dict(tipo="STOCK",      cat_def="Equipos",      cols=("cant", "desc", "nota")),
    "Máquina y Herramientas":   dict(tipo="STOCK",      cat_def="Herramientas", cols=("cant", "desc", "nota")),
    "Inventario Herramientas":  dict(tipo="STOCK",      cat_def="Herramientas", cols=("cant", "desc", "nota")),
    "Inventario 5 Oct 2025":    dict(tipo="SNAPSHOT",   cat_def="Consumibles",  cols=("cant", "desc")),
    "Tubos y Materiales":       dict(tipo="STOCK",      cat_def="Materiales",   cols=("cant", "desc", "nota")),
    "Inventario Cont.":         dict(tipo="STOCK",      cat_def="Materiales",   cols=("cant", "desc", "nota")),
    "Compras (registro diario)": dict(tipo="HISTORICO", cat_def=None,           cols=("fecha", "cant", "desc")),
    "Aceites por Máquina":      dict(tipo="REFERENCIA", cat_def=None,           cols=("maquina", "aceite")),
    "Notas de Obra":            dict(tipo="NOTAS",      cat_def=None,           cols=("fecha", "nota")),
}

# ------------------------------------------------------------------
# 2. REGLAS DE CATEGORÍA Y UNIDAD (por palabra clave)
# ------------------------------------------------------------------
CATEGORIAS = [
    ("Máquinas", r"planta el|soplador|aplastadora|cortadora|compactadora|sapo|g[uü]ira|"
                 r"bomba de agua|concretera|vibrador|m[aá]quina de soldar|motor de congeladora|"
                 r"motosierra|sierra"),
    ("Equipos",  r"andamio|escalera|carretilla|tablero"),
    ("Seguridad", r"chaleco|guante|bota|capa|faja|cubrebocas|mascarilla|kn95|tapa\w*\s*boca|casco|"
                  r"careta|m[aá]scara|yana"),
    ("Consumibles", r"aceite|wd\\s?-?\\s?40|pegamento|silic[oó]n|acelerante|impermeabilizante|electrodo|"
                    r"buj[ií]a|grasa|veneno|hormiguicida|fungicida|ridomil|cloro|clorox|pastilla|"
                    r"vaso|papel toalla|lubricante|atomizador|plastificante|pentadr|raiza|hilo|"
                    r"mecha|gasolina|disco|broca|lija|pintura|primoplato|comej"),
    ("Materiales", r"tubo|cemento|malla|varilla|barra|gavi[oó]n|plaqueta|poste|arena|piedra|"
                   r"gravilla|carriola|tee|conector|pin\b|tornillo|pl[aá]stico|manguera|madera|"
                   r"segueta|trampa grasa|tubotic|palajustro|campinga|cebolla|pasto|clavo|"
                   r"repuesto|soporte"),
    ("Herramientas", r"rotomartillo|taladro|flexible|rastrillo|llave|destornillador|machete|mazo|"
                     r"azad[oó]n|pala|pistola|chalk|cepillo|l[aá]ser|extensi[oó]n|l[aá]mpara|"
                     r"olladora|segueta|herramienta"),
]

UNIDADES = [
    ("PAR",  r"^par(es)? de|^\d*\s*pares?\b"),
    ("CAJA", r"\bcaja\b"),
    ("PAQ",  r"\bpaquete\b|\bbolsa\b|\bbolsita\b|\bbulto\b|\bsobre\b"),
    ("GAL",  r"\bgal[oó]n|galonera"),
    ("L",    r"\blitro"),
    ("KG",   r"\bkilo|\blbs?\b|\blibra"),
    ("M",    r"\bmetro|\bmts\b"),
]

# Filas del registro de compras que NO son productos (eventos, clima, personas, mano de obra)
NO_PRODUCTO = re.compile(
    r"vino la jefa|llovi[oó]|curso de|hora \d|descargaron|personas a \$|empez[oó]|"
    r"lleg[oó] prueba|vaciado", re.I)


def norm(s: str) -> str:
    """Normaliza para comparar: sin acentos, minúsculas, sin paréntesis ni signos."""
    s = unicodedata.normalize("NFKD", str(s)).encode("ascii", "ignore").decode()
    s = re.sub(r"\(.*?\)", " ", s.lower())
    s = re.sub(r"[^a-z0-9\s]", " ", s)
    return re.sub(r"\s+", " ", s).strip()


def categoria_de(desc: str, por_defecto: str) -> str:
    d = norm(desc)
    for cat, patron in CATEGORIAS:
        if re.search(patron, d):
            return cat
    return por_defecto


def unidad_de(desc: str) -> str:
    d = norm(desc)
    for uni, patron in UNIDADES:
        if re.search(patron, d):
            return uni
    return "UND"


def parse_cant(v):
    """Devuelve (cantidad, motivo_revision). '-', vacío o texto => ambiguo."""
    if v is None:
        return None, "cantidad vacía en el origen"
    s = str(v).strip()
    if s in {"", "-", "—", "?"}:
        return None, "cantidad marcada como '-' o vacía"
    try:
        return float(s), None
    except ValueError:
        m = re.search(r"\d+(?:[.,]\d+)?", s)
        if m:
            return float(m.group().replace(",", ".")), f"cantidad extraída de texto libre: {s!r}"
        return None, f"cantidad no numérica: {s!r}"


def sku_de(categoria: str, nombre: str, n: int) -> str:
    pref = {"Herramientas": "HER", "Equipos": "EQU", "Máquinas": "MAQ",
            "Materiales": "MAT", "Seguridad": "SEG", "Consumibles": "CON"}[categoria]
    return f"{pref}-{n:03d}"


def uuid_det(semilla: str) -> str:
    """UUID determinista => la importación se puede repetir sin duplicar."""
    h = hashlib.md5(f"hyce-import-{semilla}".encode()).hexdigest()
    return f"{h[:8]}-{h[8:12]}-{h[12:16]}-{h[16:20]}-{h[20:32]}"


# ------------------------------------------------------------------
# 3. LECTURA
# ------------------------------------------------------------------
wb = openpyxl.load_workbook(ORIGEN, data_only=True)
productos, historico, referencias, notas, incidencias = [], [], [], [], []

for ws in wb.worksheets:
    cfg = HOJAS.get(ws.title)
    if cfg is None:
        incidencias.append(dict(hoja=ws.title, fila="-", detalle="Hoja no reconocida; no importada"))
        continue

    filas = [r for r in ws.iter_rows(values_only=True)
             if not all(c is None or str(c).strip() == "" for c in r)]
    # Fila 0 = título de página del cuaderno; fila 1 = encabezados
    cuerpo = filas[2:]

    for i, fila in enumerate(cuerpo, start=3):
        celdas = ["" if c is None else str(c).strip() for c in fila]

        if cfg["tipo"] == "REFERENCIA":
            referencias.append(dict(maquina=celdas[0], aceite=celdas[1] if len(celdas) > 1 else ""))
            continue

        if cfg["tipo"] == "NOTAS":
            notas.append(dict(fecha=celdas[0], nota=celdas[1] if len(celdas) > 1 else ""))
            continue

        if cfg["tipo"] == "HISTORICO":
            fecha, cant_raw, desc = (celdas + ["", "", ""])[:3]
            cant, _ = parse_cant(cant_raw)
            historico.append(dict(fecha=fecha, cantidad=cant, descripcion=desc,
                                  es_producto=not bool(NO_PRODUCTO.search(desc))))
            continue

        # --- Hojas de STOCK / SNAPSHOT ---
        cant_raw, desc = celdas[0], celdas[1] if len(celdas) > 1 else ""
        nota = celdas[2] if len(celdas) > 2 else ""

        # Sub-encabezados dentro de la hoja (ej. "LIJAS / PALAS / HERRAMIENTAS VARIAS")
        if not desc and cant_raw and not re.match(r"^[\d\-—]", cant_raw):
            continue
        if desc.lower().startswith("nota:") or cant_raw.lower().startswith("nota:"):
            continue
        if not desc:
            continue

        cant, motivo = parse_cant(cant_raw)
        motivos = [motivo] if motivo else []

        if re.search(r"no legible|sin descripci|ilegible", desc, re.I):
            motivos.append("descripción ilegible en el cuaderno original")
        if re.search(r"\bde\s*$", desc):
            motivos.append("descripción incompleta")
        if cfg["tipo"] == "SNAPSHOT":
            motivos.append("proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general")

        productos.append(dict(
            hoja=ws.title, fila=i, nombre_original=desc, nota_origen=nota,
            cantidad=cant, categoria=categoria_de(desc, cfg["cat_def"]),
            unidad=unidad_de(desc), tipo_hoja=cfg["tipo"],
            motivos=motivos,
        ))

df = pd.DataFrame(productos)

# ------------------------------------------------------------------
# 4. DUPLICADOS Y NOMBRES SIMILARES
# ------------------------------------------------------------------
df["clave"] = df["nombre_original"].map(norm)

# 4a. Duplicados exactos (misma clave en distintas hojas)
for clave, g in df.groupby("clave"):
    if len(g) > 1:
        detalle = " / ".join(f"{r.hoja} f{r.fila}: {r.cantidad}" for r in g.itertuples())
        for idx in g.index:
            df.at[idx, "motivos"] = df.at[idx, "motivos"] + [f"aparece {len(g)} veces — {detalle}"]
        incidencias.append(dict(hoja="(varias)", fila="-",
                                detalle=f"DUPLICADO '{g.iloc[0].nombre_original}' → {detalle}"))

# 4b. Nombres similares (posible mismo artículo escrito distinto)
claves = df["clave"].unique().tolist()
vistos = set()
for a in range(len(claves)):
    for b in range(a + 1, len(claves)):
        k1, k2 = claves[a], claves[b]
        if k1 == k2 or (k1, k2) in vistos:
            continue
        r = SequenceMatcher(None, k1, k2).ratio()
        if r >= 0.86:
            vistos.add((k1, k2))
            incidencias.append(dict(hoja="(varias)", fila="-",
                                    detalle=f"SIMILAR ({r:.0%}) '{k1}' ~ '{k2}' — revisar si es el mismo artículo"))

# 4c. Artículo del inventario que coincide con una compra registrada
compras_claves = {norm(h["descripcion"]): h["fecha"] for h in historico if h["es_producto"]}
for idx, row in df.iterrows():
    for ck, fecha in compras_claves.items():
        if ck and (ck in row["clave"] or row["clave"] in ck) and len(ck) > 8:
            df.at[idx, "motivos"] = row["motivos"] + [
                f"coincide con una compra del {fecha}; verificar que no se cuente dos veces"]
            break

df["requiere_revision"] = df["motivos"].map(bool)
df["motivo_revision"] = df["motivos"].map(lambda m: " | ".join(m))

# ------------------------------------------------------------------
# 5. SKU Y SALIDAS
# ------------------------------------------------------------------
df = df.sort_values(["categoria", "nombre_original"]).reset_index(drop=True)
contador = {}
skus = []
for _, r in df.iterrows():
    contador[r["categoria"]] = contador.get(r["categoria"], 0) + 1
    skus.append(sku_de(r["categoria"], r["nombre_original"], contador[r["categoria"]]))
df["sku"] = skus

maestro = df[["sku", "nombre_original", "categoria", "unidad", "cantidad",
              "requiere_revision", "motivo_revision", "hoja", "fila", "nota_origen"]]
maestro.columns = ["sku", "nombre", "categoria", "unidad", "cantidad",
                   "requiere_revision", "motivo_revision", "hoja_origen", "fila_origen", "nota_origen"]
maestro.to_csv(SALIDA / "inventario_maestro.csv", index=False)

pd.DataFrame(historico).to_csv(SALIDA / "compras_historicas.csv", index=False)
pd.DataFrame(referencias).to_csv(SALIDA / "referencia_aceites.csv", index=False)
pd.DataFrame(notas).to_csv(SALIDA / "notas_obra.csv", index=False)
pd.DataFrame(incidencias).to_csv(SALIDA / "reporte_inconsistencias.csv", index=False)

# ------------------------------------------------------------------
# 6. SQL REPETIBLE
# ------------------------------------------------------------------
def esc(s):
    return "null" if s in (None, "") else "'" + str(s).replace("'", "''") + "'"

lineas = [
    "-- ============================================================",
    "-- INVENTARIO HYCE — 005_import.sql (GENERADO AUTOMÁTICAMENTE)",
    f"-- Origen: {ORIGEN.name}  |  {len(df)} artículos",
    "-- Repetible: ON CONFLICT en SKU + client_uuid determinista.",
    "-- ============================================================",
    "begin;",
    "",
    "-- La carga se ejecuta en nombre del primer usuario ADMIN existente,",
    "-- para que cada movimiento quede correctamente auditado.",
    "do $$",
    "declare v_admin uuid;",
    "begin",
    "  select id into v_admin from perfiles where rol = 'ADMIN' and activo order by created_at limit 1;",
    "  if v_admin is null then",
    "    raise exception 'Cree primero un usuario ADMIN en Supabase Auth y su fila en perfiles.';",
    "  end if;",
    "  perform set_config('request.jwt.claim.sub', v_admin::text, true);",
    "end $$;",
    "",
]

for _, r in df.iterrows():
    lineas.append(
        "insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)\n"
        f"select {esc(r['sku'])}, {esc(r['nombre_original'])},\n"
        f"       (select id from categorias where nombre = {esc(r['categoria'])}),\n"
        f"       (select id from unidades  where codigo = {esc(r['unidad'])}),\n"
        f"       {str(bool(r['requiere_revision'])).lower()}, "
        f"{esc((r['hoja'] + ' fila ' + str(r['fila']) + '. ' + r['motivo_revision']).strip())},\n"
        f"       {str(r['categoria'] not in ('Consumibles', 'Materiales')).lower()}, "
        f"{str(r['categoria'] in ('Consumibles', 'Materiales')).lower()}\n"
        "on conflict (sku) do nothing;"
    )

lineas.append("\n-- Carga del stock inicial como movimientos ENTRADA (trazable y reconstruible).")
sin_cant = 0
for _, r in df.iterrows():
    if pd.isna(r["cantidad"]) or r["cantidad"] <= 0:
        sin_cant += 1
        continue
    lineas.append(
        "select registrar_movimiento('ENTRADA',\n"
        f"  (select id from productos where sku = {esc(r['sku'])}), {r['cantidad']:g},\n"
        f"  p_client_uuid => '{uuid_det(r['sku'])}'::uuid,\n"
        f"  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),\n"
        f"  p_nota => 'Carga inicial desde Excel — {r['hoja']} fila {r['fila']}');"
    )

lineas += ["", "commit;"]
(Path("/home/claude/hyce/db/005_import.sql")).write_text("\n".join(lineas), encoding="utf-8")

# ------------------------------------------------------------------
# 7. RESUMEN EN PANTALLA
# ------------------------------------------------------------------
print("=" * 64)
print("DIAGNÓSTICO DEL EXCEL")
print("=" * 64)
for nombre, cfg in HOJAS.items():
    n = len(df[df.hoja == nombre]) if cfg["tipo"] in ("STOCK", "SNAPSHOT") else {
        "HISTORICO": len(historico), "REFERENCIA": len(referencias), "NOTAS": len(notas)}[cfg["tipo"]]
    print(f"  {cfg['tipo']:<10} {nombre:<28} {n:>3} filas")
print()
print(f"Artículos candidatos a producto : {len(df)}")
print(f"  con cantidad utilizable       : {int(df['cantidad'].notna().sum())}")
print(f"  sin cantidad (ambiguos)       : {int(df['cantidad'].isna().sum())}")
print(f"  marcados REQUIERE_REVISION    : {int(df['requiere_revision'].sum())}")
print(f"Compras históricas (NO son stock): {len(historico)}"
      f"  — de ellas {sum(1 for h in historico if not h['es_producto'])} no son productos")
print(f"Incidencias detectadas          : {len(incidencias)}")
print(f"Movimientos de carga inicial    : {len(df) - sin_cant}  (se omiten {sin_cant} sin cantidad)")
print()
print("Por categoría:")
print(df.groupby("categoria")
        .agg(articulos=("sku", "count"), unidades=("cantidad", "sum"),
             revision=("requiere_revision", "sum"))
        .to_string())
