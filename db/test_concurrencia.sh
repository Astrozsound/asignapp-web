#!/usr/bin/env bash
# ============================================================
# INVENTARIO HYCE — prueba de concurrencia (sección 4 y 38)
# Simula las 3 tablets operando a la vez sobre el mismo producto.
# ============================================================
set -u
PSQL="psql -h ${PGHOST:-/var/run/pgsock} -p ${PGPORT:-5433} -U ${PGUSER:-hyce} -d hyce -q -t -A"

ADMIN='11111111-1111-1111-1111-111111111111'
OP='33333333-3333-3333-3333-333333333333'

echo "--- Preparando producto con stock 100 ---"
$PSQL <<SQL
set request.jwt.claim.sub = '$ADMIN';
insert into productos (sku, nombre, categoria_id, unidad_id, es_retornable)
select 'CONC-001','Producto concurrencia',
       (select id from categorias where nombre='Materiales'),
       (select id from unidades where codigo='UND'), false
on conflict (sku) do nothing;
select registrar_movimiento('ENTRADA',(select id from productos where sku='CONC-001'),100,
  p_dispositivo_id=>(select id from dispositivos where codigo='DEVICE-001'));
SQL

PROD=$($PSQL -c "select id from productos where sku='CONC-001'")
OBRA=$($PSQL -c "select id from obras where codigo='OBRA-000'")

salida () { # $1 = cantidad, $2 = device
  $PSQL <<SQL >/dev/null 2>&1
set request.jwt.claim.sub = '$OP';
select registrar_movimiento('SALIDA','$PROD'::uuid,$1,
  p_obra_id=>'$OBRA'::uuid,
  p_dispositivo_id=>(select id from dispositivos where codigo='$2'));
SQL
}

echo "--- Caso 1: Tablet 2 saca 10 y Tablet 3 saca 20 simultáneamente ---"
salida 10 DEVICE-002 &
salida 20 DEVICE-003 &
wait
echo "Stock resultante (esperado 70): $($PSQL -c "select cantidad from inventario where producto_id='$PROD'")"

echo
echo "--- Caso 2: 30 salidas simultáneas de 3 unidades sobre un stock de 70 ---"
echo "    (23 deben pasar, 7 deben ser rechazadas, el stock nunca puede ser negativo)"
for i in $(seq 1 30); do
  salida 3 "DEVICE-00$(( (i % 2) + 2 ))" &
done
wait

FINAL=$($PSQL -c "select cantidad from inventario where producto_id='$PROD'")
OK=$($PSQL -c "select count(*) from movimientos where producto_id='$PROD' and tipo='SALIDA' and cantidad=3")
LEDGER=$($PSQL -c "select coalesce(sum(delta),0) from movimientos where producto_id='$PROD'")

echo "Salidas aceptadas : $OK  (esperado 23)"
echo "Stock final       : $FINAL  (esperado 1)"
echo "Suma del libro    : $LEDGER  (debe coincidir con el stock final)"

if [ "$FINAL" = "$LEDGER" ] && [ "${FINAL%%.*}" -ge 0 ]; then
  echo "RESULTADO: PASS — sin condiciones de carrera, sin stock negativo, libro cuadrado."
else
  echo "RESULTADO: FALLO — inconsistencia detectada."
  exit 1
fi
