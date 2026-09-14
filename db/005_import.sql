-- ============================================================
-- INVENTARIO HYCE — 005_import.sql (GENERADO AUTOMÁTICAMENTE)
-- Origen: Inventario_Constructura_HYCE.xlsx  |  128 artículos
-- Repetible: ON CONFLICT en SKU + client_uuid determinista.
-- ============================================================
begin;

-- La carga se ejecuta en nombre del primer usuario ADMIN existente,
-- para que cada movimiento quede correctamente auditado.
do $$
declare v_admin uuid;
begin
  select id into v_admin from perfiles where rol = 'ADMIN' and activo order by created_at limit 1;
  if v_admin is null then
    raise exception 'Cree primero un usuario ADMIN en Supabase Auth y su fila en perfiles.';
  end if;
  perform set_config('request.jwt.claim.sub', v_admin::text, true);
end $$;

insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-001', 'Aceite 10W-30',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario 5 Oct 2025 fila 7. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-002', 'Aceite de motor 20W-50',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario 5 Oct 2025 fila 12. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-003', 'Aceite de motor Premium 4-Cycle',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario 5 Oct 2025 fila 15. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-004', 'Aceite de motor pequeño Premium 4-Cycle',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 8.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-005', 'Aceite dos tiempos 2T',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 15.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-006', 'Aceites y mecha 2T Two Cycle dos ciclos',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 7.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-007', 'Acelerante',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 19.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-008', 'Acelerante de Swiru',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 26.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-009', 'Atomizador',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario 5 Oct 2025 fila 22. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general | coincide con una compra del 20 oct 2025; verificar que no se cuente dos veces',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-010', 'Bolsa de hormiguicida 10WP',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'PAQ'),
       true, 'Inventario 5 Oct 2025 fila 25. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-011', 'Botella de pegamento chica - PVC',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario 5 Oct 2025 fila 17. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-012', 'Brocas de metal',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 6.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-013', 'Brocas grandes total',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Cont. fila 16.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-014', 'Bujía NGK',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario 5 Oct 2025 fila 14. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-015', 'Bujías de Swiru',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 25.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-016', 'Caja de electrodos total',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'CAJA'),
       true, 'Inventario 5 Oct 2025 fila 13. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-017', 'Disco de flexible grande verde',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 30.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-018', 'Discos de concreto',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario Herramientas fila 11. aparece 2 veces — Inventario Herramientas f11: 3.0 / Inventario 5 Oct 2025 f19: 2.0',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-019', 'Discos de concreto',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario 5 Oct 2025 fila 19. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general | aparece 2 veces — Inventario Herramientas f11: 3.0 / Inventario 5 Oct 2025 f19: 2.0',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-020', 'Discos de concreto pequeños',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 10.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-021', 'Discos de corte chico',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario 5 Oct 2025 fila 28. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-022', 'Discos de corte grandes',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 9.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-023', 'Discos de flexible grande (10-12 oct 2025)',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario 5 Oct 2025 fila 29. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-024', 'Frasco de grasa',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario 5 Oct 2025 fila 18. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-025', 'Galonera, aceite de motor',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'GAL'),
       true, 'Inventario 5 Oct 2025 fila 3. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-026', 'Galón de pentadrín (comején)',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'GAL'),
       true, 'Inventario 5 Oct 2025 fila 23. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-027', 'Galón primoplato (Veneno)',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'GAL'),
       true, 'Inventario 5 Oct 2025 fila 24. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-028', 'Hilos amarillos',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario 5 Oct 2025 fila 10. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general | coincide con una compra del 15 sep 2025; verificar que no se cuente dos veces',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-029', 'Impermeabilizante',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario 5 Oct 2025 fila 6. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general | coincide con una compra del 1 oct 2025; verificar que no se cuente dos veces',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-030', 'Impermeabilizantes',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario Herramientas fila 20. coincide con una compra del 1 oct 2025; verificar que no se cuente dos veces',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-031', 'Lijas',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Máquina y Herramientas fila 5. aparece 2 veces — Máquina y Herramientas f5: 2.0 / Inventario Herramientas f5: 2.0',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-032', 'Lijas',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario Herramientas fila 5. aparece 2 veces — Máquina y Herramientas f5: 2.0 / Inventario Herramientas f5: 2.0',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-033', 'Pastillas de Clorox',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario 5 Oct 2025 fila 16. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-034', 'Pegamento chico',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 13.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-035', 'Pentadrín para planta- portector quimico liquido',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Máquina y Herramientas fila 20.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-036', 'Plastificante',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario 5 Oct 2025 fila 5. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general | coincide con una compra del 1 oct 2025; verificar que no se cuente dos veces',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-037', 'Silicón en plástico',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 23.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-038', 'Silicón permanente entero',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 22.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-039', 'Sobre de fungicida (Ridomil)',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'PAQ'),
       true, 'Inventario 5 Oct 2025 fila 26. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-040', 'Trampa grasa 12 lbs verde',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'KG'),
       false, 'Inventario Cont. fila 7.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-041', 'Vasos',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario Herramientas fila 27. coincide con una compra del 20 oct 2025; verificar que no se cuente dos veces',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-042', 'Vasos plásticos blancos',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario 5 Oct 2025 fila 27. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general | coincide con una compra del 20 oct 2025; verificar que no se cuente dos veces',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'CON-043', 'WD-40',
       (select id from categorias where nombre = 'Consumibles'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario 5 Oct 2025 fila 9. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general | aparece 2 veces — Inventario Herramientas f14: 1.0 / Inventario 5 Oct 2025 f9: 3.0',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'EQU-001', 'Andamio color verde',
       (select id from categorias where nombre = 'Equipos'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 20.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'EQU-002', 'Carretillas',
       (select id from categorias where nombre = 'Equipos'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario 5 Oct 2025 fila 31. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general | aparece 3 veces — Inventario Equipo f14: 4.0 / Inventario Herramientas f28: 4.0 / Inventario 5 Oct 2025 f31: 2.0',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'EQU-003', 'Carretillas (2 azules, 1 metal, y una amarilla)',
       (select id from categorias where nombre = 'Equipos'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario Herramientas fila 28. aparece 3 veces — Inventario Equipo f14: 4.0 / Inventario Herramientas f28: 4.0 / Inventario 5 Oct 2025 f31: 2.0',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'EQU-004', 'Carretillas (una amarilla y otras de metal)',
       (select id from categorias where nombre = 'Equipos'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario Equipo fila 14. aparece 3 veces — Inventario Equipo f14: 4.0 / Inventario Herramientas f28: 4.0 / Inventario 5 Oct 2025 f31: 2.0',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'EQU-005', 'Escalera de metal grande',
       (select id from categorias where nombre = 'Equipos'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 16.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'EQU-006', 'Plantas eléctricas',
       (select id from categorias where nombre = 'Equipos'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 3.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'EQU-007', 'Soporte de carretilla',
       (select id from categorias where nombre = 'Equipos'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Máquina y Herramientas fila 21. coincide con una compra del 1 oct 2025; verificar que no se cuente dos veces',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'EQU-008', 'Tablero de',
       (select id from categorias where nombre = 'Equipos'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Máquina y Herramientas fila 17. descripción incompleta',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-001', '(cantidad sin descripción legible)',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Máquina y Herramientas fila 18. descripción ilegible en el cuaderno original | coincide con una compra del 15 sep 2025; verificar que no se cuente dos veces',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-002', 'Cepillo de flexible chico',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario 5 Oct 2025 fila 20. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-003', 'Cepillo de flexible grande',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario 5 Oct 2025 fila 21. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-004', 'Chalk line',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario 5 Oct 2025 fila 8. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-005', 'Destornilladores',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Máquina y Herramientas fila 10. cantidad marcada como ''-'' o vacía',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-006', 'Destornilladores chicos',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario Herramientas fila 29. aparece 2 veces — Inventario Herramientas f29: 1.0 / Inventario 5 Oct 2025 f30: nan',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-007', 'Destornilladores chicos',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario 5 Oct 2025 fila 30. cantidad marcada como ''-'' o vacía | proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general | aparece 2 veces — Inventario Herramientas f29: 1.0 / Inventario 5 Oct 2025 f30: nan',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-008', 'Extensión eléctrica',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 12.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-009', 'Flexible de corriente',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 27.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-010', 'Flexible inalámbrico',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 24.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-011', 'Llave de agua',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 32.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-012', 'Llaves',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Máquina y Herramientas fila 8. cantidad marcada como ''-'' o vacía | coincide con una compra del 6 oct 2025; verificar que no se cuente dos veces',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-013', 'Lámpara nocturna prolatex',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario Equipo fila 25. aparece 2 veces — Inventario Equipo f25: 1.0 / Inventario Equipo f26: 1.0',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-014', 'Lámpara nocturna prolatex',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario Equipo fila 26. aparece 2 veces — Inventario Equipo f25: 1.0 / Inventario Equipo f26: 1.0',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-015', 'Láser verde',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Cont. fila 3.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-016', 'Machetes Swiru',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 16.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-017', 'Olladora color verde',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 17.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-018', 'Palas',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Máquina y Herramientas fila 6. cantidad marcada como ''-'' o vacía',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-019', 'Pistola grande anaranjada, hueso',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 17.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-020', 'Rastrillo de metal',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Máquina y Herramientas fila 7.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-021', 'Rotomartillo color verde grande',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 5.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-022', 'Taladro chico verde',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 31.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-023', 'Taladro inalámbrico total',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 29.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-024', 'Taladro roto',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 28.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-025', 'Taladro verde chico verde',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 23.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-026', 'Tapas de Swiru',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 24.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'HER-027', 'WD-40',
       (select id from categorias where nombre = 'Herramientas'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario Herramientas fila 14. aparece 2 veces — Inventario Herramientas f14: 1.0 / Inventario 5 Oct 2025 f9: 3.0',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-001', 'Barras/varillas de 1/2"',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Cont. fila 17.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-002', 'Bultos de cemento',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Máquina y Herramientas fila 22. coincide con una compra del 30 sep 2025; verificar que no se cuente dos veces',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-003', 'Caja de lápiz rojo',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'CAJA'),
       false, 'Inventario Cont. fila 4.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-004', 'Carriolas',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Tubos y Materiales fila 8. cantidad marcada como ''-'' o vacía',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-005', 'Carriolas 4x2 #16x20',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario Cont. fila 6. cantidad marcada como ''-'' o vacía',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-006', 'Cebolla en bolsita',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'PAQ'),
       false, 'Máquina y Herramientas fila 16.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-007', 'Clavos de acero 1 caja',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'CAJA'),
       false, 'Máquina y Herramientas fila 12.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-008', 'Clavos dulces',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Máquina y Herramientas fila 11.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-009', 'Conectores orgo',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Cont. fila 15.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-010', 'Conectores para extensión, madre y hembra',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Máquina y Herramientas fila 19.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-011', 'Hojas de segueta',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Cont. fila 8.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-012', 'Mallas electrosoldadas 2M, 6 mts',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'M'),
       false, 'Inventario Cont. fila 5.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-013', 'Manguera verde grande',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 18.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-014', 'Palajustros',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Cont. fila 18.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-015', 'Paquete de tubo de 6" de agua',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'PAQ'),
       false, 'Máquina y Herramientas fila 9.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-016', 'Pasto en bolsita',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'PAQ'),
       false, 'Máquina y Herramientas fila 15.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-017', 'Plásticos circulares',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 21.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-018', 'Repuesto de campingas',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Cont. fila 9.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-019', 'Tee de 4"',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario Cont. fila 10. aparece 2 veces — Inventario Cont. f10: 2.0 / Inventario Cont. f11: 1.0',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-020', 'Tee de 4"',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario Cont. fila 11. aparece 2 veces — Inventario Cont. f10: 2.0 / Inventario Cont. f11: 1.0',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-021', 'Tubo de 6" blanco',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Tubos y Materiales fila 4.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-022', 'Tubos de (descripción no legible)',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Tubos y Materiales fila 5. descripción ilegible en el cuaderno original | aparece 3 veces — Tubos y Materiales f5: 10.0 / Tubos y Materiales f6: 4.0 / Tubos y Materiales f7: 4.0 | coincide con una compra del 18 sep 2025; verificar que no se cuente dos veces',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-023', 'Tubos de (descripción no legible)',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Tubos y Materiales fila 6. descripción ilegible en el cuaderno original | aparece 3 veces — Tubos y Materiales f5: 10.0 / Tubos y Materiales f6: 4.0 / Tubos y Materiales f7: 4.0 | coincide con una compra del 18 sep 2025; verificar que no se cuente dos veces',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-024', 'Tubos de (descripción no legible)',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Tubos y Materiales fila 7. descripción ilegible en el cuaderno original | aparece 3 veces — Tubos y Materiales f5: 10.0 / Tubos y Materiales f6: 4.0 / Tubos y Materiales f7: 4.0 | coincide con una compra del 18 sep 2025; verificar que no se cuente dos veces',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-025', 'Tubos de alcantarilla',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Tubos y Materiales fila 3.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-026', 'Tubotic SCH40 c/c 1/2" x 20',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Cont. fila 12.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-027', 'Tubotic SDR26 c/c 2" x 20',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Cont. fila 14.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAT-028', 'Tubotic SDR26 c/c 4" x 20',
       (select id from categorias where nombre = 'Materiales'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Cont. fila 13.',
       false, true
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAQ-001', 'Aplastadora de concreto con manguera negra',
       (select id from categorias where nombre = 'Máquinas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 6.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAQ-002', 'Bomba de agua chica',
       (select id from categorias where nombre = 'Máquinas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Máquina y Herramientas fila 3.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAQ-003', 'Bomba de agua chica verde total',
       (select id from categorias where nombre = 'Máquinas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 11.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAQ-004', 'Concretera verde',
       (select id from categorias where nombre = 'Máquinas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 13.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAQ-005', 'Cortadora grande verde',
       (select id from categorias where nombre = 'Máquinas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 7.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAQ-006', 'Güiras (una chica y otra grande) verde',
       (select id from categorias where nombre = 'Máquinas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 10.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAQ-007', 'Motor de congeladora',
       (select id from categorias where nombre = 'Máquinas'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Inventario Equipo fila 22. coincide con una compra del 20 oct 2025; verificar que no se cuente dos veces',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAQ-008', 'Motosierra anaranjada',
       (select id from categorias where nombre = 'Máquinas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 18.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAQ-009', 'Máquina de soldar color verde con máscara',
       (select id from categorias where nombre = 'Máquinas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 21.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAQ-010', 'Sapo verde ( Compactadora tipo Rana / Apisonador)',
       (select id from categorias where nombre = 'Máquinas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 9.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAQ-011', 'Sierra de árboles anaranjado',
       (select id from categorias where nombre = 'Máquinas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 12.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAQ-012', 'Sierra grande verde',
       (select id from categorias where nombre = 'Máquinas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 19.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAQ-013', 'Sierra verde pequeña',
       (select id from categorias where nombre = 'Máquinas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 8.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAQ-014', 'Soplador (2024)',
       (select id from categorias where nombre = 'Máquinas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 4.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'MAQ-015', 'Vibrador verde con negro',
       (select id from categorias where nombre = 'Máquinas'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Equipo fila 15.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'SEG-001', 'Chalecos',
       (select id from categorias where nombre = 'Seguridad'),
       (select id from unidades  where codigo = 'UND'),
       false, 'Inventario Herramientas fila 3.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'SEG-002', 'Paquete de cubrebocas tipo concha',
       (select id from categorias where nombre = 'Seguridad'),
       (select id from unidades  where codigo = 'PAQ'),
       true, 'Inventario 5 Oct 2025 fila 4. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'SEG-003', 'Paquete mascarilla KN95',
       (select id from categorias where nombre = 'Seguridad'),
       (select id from unidades  where codigo = 'PAQ'),
       true, 'Inventario 5 Oct 2025 fila 11. proviene del conteo fechado 5-oct-2025, puede solaparse con el inventario general',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'SEG-004', 'Par de botas negra Lually (EPS GARFITADO )',
       (select id from categorias where nombre = 'Seguridad'),
       (select id from unidades  where codigo = 'PAR'),
       false, 'Máquina y Herramientas fila 23.',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'SEG-005', 'Pares de guantes de soldadura',
       (select id from categorias where nombre = 'Seguridad'),
       (select id from unidades  where codigo = 'PAR'),
       true, 'Inventario Herramientas fila 4. coincide con una compra del 15 sep 2025; verificar que no se cuente dos veces',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'SEG-006', 'Tapas bocas',
       (select id from categorias where nombre = 'Seguridad'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Máquina y Herramientas fila 14. cantidad marcada como ''-'' o vacía',
       true, false
on conflict (sku) do nothing;
insert into productos (sku, nombre, categoria_id, unidad_id, requiere_revision, nota_import, es_retornable, es_consumible)
select 'SEG-007', 'Yanas',
       (select id from categorias where nombre = 'Seguridad'),
       (select id from unidades  where codigo = 'UND'),
       true, 'Máquina y Herramientas fila 13. cantidad marcada como ''-'' o vacía',
       true, false
on conflict (sku) do nothing;

-- Carga del stock inicial como movimientos ENTRADA (trazable y reconstruible).
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-001'), 1,
  p_client_uuid => '40019654-3589-95b2-b8ec-767707cbda74'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 7');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-002'), 1,
  p_client_uuid => '5aa8c773-510a-157f-d117-3ab3c8edae69'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 12');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-003'), 1,
  p_client_uuid => '5d84f194-1eee-b6a2-3929-4dff01427603'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 15');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-004'), 1,
  p_client_uuid => 'bdb45648-4873-f910-8cae-ea1fe52265d7'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 8');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-005'), 1,
  p_client_uuid => 'ca4ec290-628a-cd7b-4323-f1de4d78bd45'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 15');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-006'), 2,
  p_client_uuid => '048cf969-3062-035a-a006-b9d85e893595'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 7');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-007'), 4,
  p_client_uuid => 'aa66d246-a499-492e-b514-08fbd9fa5b01'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 19');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-008'), 1,
  p_client_uuid => '0ca4c0d2-bc38-d1c8-98b9-de6ca5ef968e'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 26');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-009'), 1,
  p_client_uuid => 'a458b519-f30f-23a8-0817-4a707bd4db5a'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 22');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-010'), 1,
  p_client_uuid => 'bf07b04f-a65b-f201-acab-c1250164de09'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 25');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-011'), 1,
  p_client_uuid => 'da2be9a0-044a-6393-3060-e66a0b3e5677'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 17');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-012'), 2,
  p_client_uuid => '34f8b540-8afc-6682-791f-be823c307e51'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 6');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-013'), 2,
  p_client_uuid => 'dd01fcff-c071-137e-3de2-7a1bb72faa45'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Cont. fila 16');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-014'), 1,
  p_client_uuid => 'e61a45b8-ab5b-4498-fa67-0c2cca7ba8b0'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 14');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-015'), 2,
  p_client_uuid => 'd649ea63-5f79-ad6e-d8bd-eb8efbbb0a7f'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 25');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-016'), 1,
  p_client_uuid => '18c2bd06-b7ac-99e2-77be-6ce9c5937f82'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 13');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-017'), 2,
  p_client_uuid => '907dc422-449a-9ddb-915d-a137ff590745'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 30');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-018'), 3,
  p_client_uuid => '3ace6f3a-92f2-4091-9608-4b32df8e3daf'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 11');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-019'), 2,
  p_client_uuid => '60b48633-dfae-7e25-52b8-1763cf2a1b6b'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 19');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-020'), 10,
  p_client_uuid => '3ce831d5-3377-84c6-4517-4fa344b5ae32'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 10');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-021'), 3,
  p_client_uuid => '729d02a8-27ea-28d6-fa6c-3dac63318058'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 28');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-022'), 1,
  p_client_uuid => 'a680d7f3-2810-0fe3-b4d0-9577bfc7f8af'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 9');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-023'), 2,
  p_client_uuid => 'eda359a2-28fa-f77c-7e4e-70acf217c4e8'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 29');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-024'), 1,
  p_client_uuid => '619ef538-caf5-bd19-79e8-ab2370ce0f24'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 18');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-025'), 2,
  p_client_uuid => 'f4b27f98-a11f-0d93-9bc5-39436daf2579'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 3');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-026'), 1,
  p_client_uuid => '378bad42-5010-f31f-0247-9e043d0fc705'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 23');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-027'), 1,
  p_client_uuid => '1de9bb35-371e-1a0d-5ee4-ecfe55ead598'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 24');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-028'), 2,
  p_client_uuid => '8d840d2f-eb9a-3cb2-3cae-f666149c8750'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 10');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-029'), 2,
  p_client_uuid => '4ce6ce6e-bb25-d133-b416-e8ee7427b636'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 6');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-030'), 3,
  p_client_uuid => '6e8e1fec-77b2-19d2-a562-431c3f886f49'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 20');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-031'), 2,
  p_client_uuid => '65d2c583-c969-66fc-a045-c1a740471800'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Máquina y Herramientas fila 5');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-032'), 2,
  p_client_uuid => '3f421104-f6ee-1f8b-da1f-8e324e27d9ed'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 5');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-033'), 1,
  p_client_uuid => 'c34d78a7-dd23-1119-2f00-bfe57fb02509'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 16');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-034'), 2,
  p_client_uuid => '98c812b1-64ed-1218-6135-375d6b351f16'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 13');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-035'), 1,
  p_client_uuid => '5d604226-2d81-7bcf-ce57-f47daae55efa'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Máquina y Herramientas fila 20');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-036'), 1,
  p_client_uuid => '8d3916f4-8235-77e7-1946-58c549236139'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 5');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-037'), 1,
  p_client_uuid => '8b54f8e3-ca20-9bb6-e5a5-cabecce5169d'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 23');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-038'), 1,
  p_client_uuid => 'b4b198c5-8d31-1b76-e5a9-1d529468eaf2'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 22');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-039'), 1,
  p_client_uuid => '9702f7a0-122d-b997-98b5-e610fa57fb39'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 26');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-040'), 3,
  p_client_uuid => 'dd789462-7246-899a-5f24-07ea48094e2c'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Cont. fila 7');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-041'), 3,
  p_client_uuid => '9eaad065-5fda-e6a8-9dd1-b7ae1101127b'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 27');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-042'), 24,
  p_client_uuid => 'ec8f8c07-dc73-7f58-3761-b6c2ca7621a6'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 27');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'CON-043'), 3,
  p_client_uuid => '7b285d10-8539-204e-4c75-90c7099de6ae'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 9');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'EQU-001'), 1,
  p_client_uuid => '6d3a6f1b-9260-df8b-e48d-42bad63edcde'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 20');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'EQU-002'), 2,
  p_client_uuid => '94ac2ed6-125c-63aa-921b-1e1db23e8f98'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 31');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'EQU-003'), 4,
  p_client_uuid => 'cc31cdd5-1dca-f69d-9a9d-58bde84b56f0'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 28');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'EQU-004'), 4,
  p_client_uuid => '1c0a97aa-a1ff-bcda-4dec-ff1c65c97c77'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 14');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'EQU-005'), 1,
  p_client_uuid => '943deaae-1498-9461-01ff-b2dfa0425226'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 16');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'EQU-006'), 2,
  p_client_uuid => 'ff47e86b-6e08-b733-2428-42a3d3604312'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 3');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'EQU-007'), 1,
  p_client_uuid => 'a0e3e5d4-c14d-6c23-b70b-5649697237d8'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Máquina y Herramientas fila 21');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'EQU-008'), 1,
  p_client_uuid => 'ddfe7525-5aa7-0c7b-ab9c-bd0649ac38d2'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Máquina y Herramientas fila 17');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-001'), 58,
  p_client_uuid => '77083e89-1906-c92b-150c-af060f19eec8'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Máquina y Herramientas fila 18');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-002'), 1,
  p_client_uuid => 'dc82100d-98ce-58c6-8a48-694027f1752b'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 20');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-003'), 1,
  p_client_uuid => '6b9aa57e-ee87-8537-9445-5db299480a7f'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 21');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-004'), 1,
  p_client_uuid => '89d8e3d1-ca88-67b4-8fd9-c0f79d0fee1c'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 8');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-006'), 1,
  p_client_uuid => '56d041b1-45cf-2fe5-e24b-fc22b95825bd'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 29');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-008'), 1,
  p_client_uuid => '1a68260a-8c68-9340-6e78-019c95ea037e'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 12');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-009'), 1,
  p_client_uuid => '4168810b-e1e4-8963-4835-2eb064469dfc'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 27');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-010'), 1,
  p_client_uuid => 'd33e4b00-06ea-0702-d023-78dbc64258e3'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 24');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-011'), 4,
  p_client_uuid => 'e016617d-809d-a024-a495-1d11916989b8'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 32');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-013'), 1,
  p_client_uuid => '21f2afc7-9d47-16d5-d42d-c7f1b3adedd8'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 25');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-014'), 1,
  p_client_uuid => '7848b4f9-a1df-138a-645f-51ed91465f15'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 26');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-015'), 1,
  p_client_uuid => '00e37a9e-9663-d122-090f-0526c31be9a1'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Cont. fila 3');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-016'), 2,
  p_client_uuid => '209b12df-f429-c2af-631e-2f98bbb83746'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 16');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-017'), 1,
  p_client_uuid => 'dd81e9eb-ea3a-81e1-07da-b7549062dd5e'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 17');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-019'), 1,
  p_client_uuid => 'd4d61dab-2118-eac2-fe15-fe2f8db8f53c'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 17');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-020'), 3,
  p_client_uuid => 'e8de68c1-bf8c-b5c5-ca7e-c924ebf27bc7'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Máquina y Herramientas fila 7');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-021'), 1,
  p_client_uuid => 'b7ffad80-3ac5-ab8f-5993-b3546ab6bcf7'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 5');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-022'), 1,
  p_client_uuid => 'eb7bfdfe-68ca-a733-894d-5c0ae07817a2'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 31');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-023'), 1,
  p_client_uuid => '849c89cf-63f7-7977-1681-4c5a6426f071'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 29');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-024'), 1,
  p_client_uuid => 'd5f18512-eb79-ad4b-b893-6457a02cf158'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 28');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-025'), 1,
  p_client_uuid => 'c21ce6ef-5463-2e11-21f2-9c6ed2da63d6'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 23');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-026'), 2,
  p_client_uuid => '3201706f-a880-dd39-dc5b-24c9c2f72c28'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 24');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'HER-027'), 1,
  p_client_uuid => 'd5f0c630-10ad-999c-de62-e798dd566e4c'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 14');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-001'), 12,
  p_client_uuid => '9d0e140f-cdcd-d371-ee14-38b944f6f8a7'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Cont. fila 17');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-002'), 50,
  p_client_uuid => '94905025-58d9-9bee-f555-6c291109286e'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Máquina y Herramientas fila 22');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-003'), 1,
  p_client_uuid => 'ef8a12d2-6839-b830-3abe-6a7681ab62a4'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Cont. fila 4');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-006'), 1,
  p_client_uuid => '4d25b79d-f463-d10f-e3b7-cdfd3ec29eeb'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Máquina y Herramientas fila 16');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-007'), 1,
  p_client_uuid => '28d52599-5f7f-ad34-cb86-c556b5b81baf'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Máquina y Herramientas fila 12');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-008'), 2,
  p_client_uuid => 'b24f064e-4303-bbf7-8eff-3ff408a3c935'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Máquina y Herramientas fila 11');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-009'), 8,
  p_client_uuid => 'ca5356c4-7340-2c46-cff9-ce6fd1eca163'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Cont. fila 15');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-010'), 2,
  p_client_uuid => '8beb0358-ad6e-0e2d-fe50-5751d40d6be6'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Máquina y Herramientas fila 19');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-011'), 2,
  p_client_uuid => 'bec4eb26-4ef1-78ef-a2bd-0acf72928b25'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Cont. fila 8');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-012'), 8,
  p_client_uuid => '1e090eb3-799c-9fe9-1107-b451a1eb6fd6'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Cont. fila 5');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-013'), 1,
  p_client_uuid => '4f0e34cb-c7f5-aee8-06f4-62d75305d88c'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 18');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-014'), 4,
  p_client_uuid => 'bf1e5e7a-a24d-c9a0-ed23-dc913e85f916'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Cont. fila 18');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-015'), 1,
  p_client_uuid => '03f33b5c-277c-b2c6-df9d-45f83da938ef'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Máquina y Herramientas fila 9');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-016'), 1,
  p_client_uuid => '99d7da50-8c96-d1b5-ca75-8dc906c7237c'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Máquina y Herramientas fila 15');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-017'), 2,
  p_client_uuid => '423fe47b-898f-447e-5d4c-fec45b3bba6a'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 21');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-018'), 2,
  p_client_uuid => '56ceaeba-8050-fba9-83f1-5d727fb8f016'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Cont. fila 9');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-019'), 2,
  p_client_uuid => 'be0bf322-ec8f-8f26-76c4-e34e537cc622'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Cont. fila 10');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-020'), 1,
  p_client_uuid => '96578443-c08f-eebc-b0ea-eaf129555fb4'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Cont. fila 11');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-021'), 1,
  p_client_uuid => '317a2128-fbe5-5695-8bdf-d2726d869891'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Tubos y Materiales fila 4');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-022'), 10,
  p_client_uuid => 'db2056a3-3a54-7a56-7710-d559effe3a37'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Tubos y Materiales fila 5');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-023'), 4,
  p_client_uuid => '80b4ad4c-3708-3cc4-e5b6-e77005e352e0'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Tubos y Materiales fila 6');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-024'), 4,
  p_client_uuid => '3470b249-3b0d-b5e2-e04b-773464c8b68c'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Tubos y Materiales fila 7');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-025'), 6,
  p_client_uuid => 'cf781d20-4dac-b808-dbbf-21f009aab162'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Tubos y Materiales fila 3');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-026'), 10,
  p_client_uuid => 'dd08f5dd-7654-24dd-bb12-11fd732344fb'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Cont. fila 12');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-027'), 4,
  p_client_uuid => '66a567a9-fa34-72dc-a27e-0900b5d3d3d7'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Cont. fila 14');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAT-028'), 4,
  p_client_uuid => '82237df3-6ecc-5c4e-5bd3-fdbeb6a09ab9'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Cont. fila 13');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAQ-001'), 1,
  p_client_uuid => '6f197a21-d8e3-7ff6-2eb8-cd52bad40f82'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 6');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAQ-002'), 1,
  p_client_uuid => 'b4870c40-f6b3-d75d-78e6-0952aa52b07c'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Máquina y Herramientas fila 3');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAQ-003'), 1,
  p_client_uuid => '750d1990-c9a3-ff49-2ca3-4789112f9dee'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 11');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAQ-004'), 1,
  p_client_uuid => '29a53e25-af82-e7e0-68b0-acf1be8a1dc9'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 13');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAQ-005'), 1,
  p_client_uuid => 'c746a52e-cd7a-68e2-fd52-986e39b77392'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 7');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAQ-006'), 2,
  p_client_uuid => 'a745e177-7292-7e7b-419d-b9ae8acc9005'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 10');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAQ-007'), 2,
  p_client_uuid => 'a696237c-999f-7a89-f112-24cf6c5080c4'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 22');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAQ-008'), 1,
  p_client_uuid => '22935f3b-bc73-df03-9536-34b156c922c8'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 18');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAQ-009'), 1,
  p_client_uuid => '833009e5-2220-ce12-f092-9a9b17a96ee1'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 21');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAQ-010'), 1,
  p_client_uuid => '348b793e-ea25-8c81-7433-559c582765db'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 9');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAQ-011'), 1,
  p_client_uuid => '1072dffc-ba49-5bb7-cdf5-7a30ef4875f4'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 12');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAQ-012'), 1,
  p_client_uuid => '50b1cacf-61f7-4932-2c20-58d1ea01e555'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 19');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAQ-013'), 1,
  p_client_uuid => '404f7312-02eb-ae72-9a14-fa9f01207538'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 8');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAQ-014'), 1,
  p_client_uuid => '3a7cc841-3c9c-7f9e-f3be-5b5df88e553b'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 4');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'MAQ-015'), 1,
  p_client_uuid => 'c96e0207-0b76-dbf7-f2e1-1b56c16de28d'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Equipo fila 15');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'SEG-001'), 2,
  p_client_uuid => '7140d9bc-b711-0a24-1237-0a96f4e4165c'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 3');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'SEG-002'), 1,
  p_client_uuid => 'd2d1266b-5f96-6921-b632-8262b6189db1'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 4');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'SEG-003'), 1,
  p_client_uuid => 'fc4b5088-3578-20c6-124c-f86685a1a02a'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario 5 Oct 2025 fila 11');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'SEG-004'), 1,
  p_client_uuid => 'fa19bbda-d55b-a15f-0b1b-9befb72edef9'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Máquina y Herramientas fila 23');
select registrar_movimiento('ENTRADA',
  (select id from productos where sku = 'SEG-005'), 2,
  p_client_uuid => '43ab928d-00ac-a04e-adcb-a5341a245e6d'::uuid,
  p_dispositivo_id => (select id from dispositivos where codigo = 'DEVICE-001'),
  p_nota => 'Carga inicial desde Excel — Inventario Herramientas fila 4');

commit;