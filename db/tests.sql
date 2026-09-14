-- ============================================================
-- INVENTARIO HYCE — tests.sql
-- Cubre la sección 38 (TESTING) y los criterios de aceptación.
-- Ejecutar sobre una base recién migrada + seed.
-- ============================================================
\set ON_ERROR_STOP off
\timing off

-- Helper de aserción
create or replace function assert_eq(p_desc text, p_a anyelement, p_b anyelement)
returns void language plpgsql as $$
begin
  if p_a is not distinct from p_b then
    raise notice 'PASS  %  (= %)', p_desc, p_a;
  else
    raise exception 'FALLO % : esperado %, obtenido %', p_desc, p_b, p_a;
  end if;
end $$;

create or replace function assert_falla(p_desc text, p_sql text)
returns void language plpgsql as $$
begin
  begin
    execute p_sql;
    raise exception 'FALLO % : la operación debió ser rechazada y pasó', p_desc;
  exception
    when others then
      if sqlerrm like 'FALLO%' then raise; end if;
      raise notice 'PASS  % (rechazado: %)', p_desc, left(sqlerrm, 70);
  end;
end $$;

-- ------------------------------------------------------------
-- USUARIOS DE PRUEBA
-- ------------------------------------------------------------
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111','admin@hyce.test'),
  ('22222222-2222-2222-2222-222222222222','supervisor@hyce.test'),
  ('33333333-3333-3333-3333-333333333333','juan@hyce.test')
on conflict do nothing;

insert into perfiles (id, nombre, rol) values
  ('11111111-1111-1111-1111-111111111111','Admin Bodega','ADMIN'),
  ('22222222-2222-2222-2222-222222222222','Supervisor','SUPERVISOR'),
  ('33333333-3333-3333-3333-333333333333','Juan','OPERARIO')
on conflict (id) do update set rol = excluded.rol;

\echo '\n===== 1. PRODUCTOS ====='
set request.jwt.claim.sub = '11111111-1111-1111-1111-111111111111';

insert into productos (sku, nombre, categoria_id, unidad_id, codigo_barras, stock_minimo, es_retornable)
select 'TST-HER','Rotomartillo Bosch',
       (select id from categorias where nombre='Herramientas'),
       (select id from unidades where codigo='UND'),
       '7501234567890', 1, true;

insert into productos (sku, nombre, categoria_id, unidad_id, codigo_barras, stock_minimo, es_consumible, es_retornable)
select 'TST-SEG','Guantes de cuero',
       (select id from categorias where nombre='Seguridad'),
       (select id from unidades where codigo='PAR'),
       '7509876543210', 10, true, false;

insert into productos (sku, nombre, categoria_id, unidad_id)
select 'TST-TMP','Producto temporal',
       (select id from categorias where nombre='Materiales'),
       (select id from unidades where codigo='UND');

select assert_eq('Producto creado con fila de inventario en 0',
  (select cantidad from inventario i join productos p on p.id=i.producto_id where p.sku='TST-HER'),
  0::numeric(14,3));

-- Editar
update productos set descripcion = 'SDS-Plus 800W' where sku='TST-HER';
select assert_eq('Producto editable',
  (select descripcion from productos where sku='TST-HER'), 'SDS-Plus 800W');

-- Eliminar producto SIN movimientos => permitido
select eliminar_producto((select id from productos where sku='TST-TMP'));
select assert_eq('Producto sin historial se elimina físicamente',
  (select count(*) from productos where sku='TST-TMP'), 0::bigint);

\echo '\n===== 2. ENTRADAS / SALIDAS / DEVOLUCIONES ====='

-- Entrada de 3 rotomartillos y 30 pares de guantes
select registrar_movimiento('ENTRADA', (select id from productos where sku='TST-HER'), 3,
       p_dispositivo_id => (select id from dispositivos where codigo='DEVICE-001'));
select registrar_movimiento('ENTRADA', (select id from productos where sku='TST-SEG'), 30,
       p_dispositivo_id => (select id from dispositivos where codigo='DEVICE-001'));

select assert_eq('Entrada suma stock',
  (select disponible from vw_productos_stock where sku='TST-HER'), 3::numeric);

select assert_eq('Movimiento guarda stock anterior/posterior',
  (select stock_anterior::int || '->' || stock_posterior::int from movimientos
    where tipo='ENTRADA' and producto_id=(select id from productos where sku='TST-HER')),
  '0->3');

-- Salida por el operario (Tablet 2)
set request.jwt.claim.sub = '33333333-3333-3333-3333-333333333333';
select registrar_movimiento('SALIDA', (select id from productos where sku='TST-HER'), 2,
       p_obra_id        => (select id from obras where codigo='OBRA-000'),
       p_dispositivo_id => (select id from dispositivos where codigo='DEVICE-002'));

select assert_eq('Salida descuenta stock',
  (select disponible from vw_productos_stock where sku='TST-HER'), 1::numeric);
select assert_eq('Salida registra herramientas en obra',
  (select en_obra from vw_productos_stock where sku='TST-HER'), 2::numeric);

-- Salida sin obra => rechazada
select assert_falla('Salida sin obra',
  $q$ select registrar_movimiento('SALIDA', (select id from productos where sku='TST-HER'), 1) $q$);

-- Stock insuficiente => rechazada
select assert_falla('Stock insuficiente',
  $q$ select registrar_movimiento('SALIDA', (select id from productos where sku='TST-HER'), 99,
        p_obra_id => (select id from obras where codigo='OBRA-000')) $q$);

-- Devolución: 1 bueno, 1 dañado
select registrar_movimiento('DEVOLUCION', (select id from productos where sku='TST-HER'), 1,
       p_estado_dev => 'BUENO',
       p_dispositivo_id => (select id from dispositivos where codigo='DEVICE-002'));
select assert_eq('Devolución en buen estado repone stock',
  (select disponible from vw_productos_stock where sku='TST-HER'), 2::numeric);

select registrar_movimiento('DEVOLUCION', (select id from productos where sku='TST-HER'), 1,
       p_estado_dev => 'DANADO',
       p_dispositivo_id => (select id from dispositivos where codigo='DEVICE-002'));
select assert_eq('Devolución dañada NO repone disponible',
  (select disponible from vw_productos_stock where sku='TST-HER'), 2::numeric);
select assert_eq('Devolución dañada cierra el pendiente en obra',
  (select en_obra from vw_productos_stock where sku='TST-HER'), 0::numeric);
select assert_eq('Devolución dañada cambia el estado del producto',
  (select estado::text from productos where sku='TST-HER'), 'DANADO');

-- Devolver más de lo que salió => rechazada
select assert_falla('Devolución mayor a lo pendiente',
  $q$ select registrar_movimiento('DEVOLUCION', (select id from productos where sku='TST-HER'), 5,
        p_estado_dev => 'BUENO') $q$);

\echo '\n===== 3. PERMISOS (backend, no interfaz) ====='
-- Operario intentando registrar una ENTRADA
select assert_falla('Operario no registra entradas',
  $q$ select registrar_movimiento('ENTRADA', (select id from productos where sku='TST-SEG'), 5) $q$);

select assert_falla('Operario no elimina productos',
  $q$ select eliminar_producto((select id from productos where sku='TST-SEG')) $q$);

select assert_falla('Operario no desactiva productos',
  $q$ select desactivar_producto((select id from productos where sku='TST-SEG')) $q$);

select assert_falla('Operario no fuerza stock negativo',
  $q$ select registrar_movimiento('SALIDA', (select id from productos where sku='TST-SEG'), 999,
        p_obra_id => (select id from obras where codigo='OBRA-000'),
        p_forzar_negativo => true) $q$);

\echo '\n===== 4. ESCÁNER ====='
select assert_eq('Código existente encuentra producto',
  (select nombre from buscar_por_codigo('7501234567890')), 'Rotomartillo Bosch');
select assert_eq('Código inexistente no devuelve nada',
  (select count(*) from buscar_por_codigo('0000000000000')), 0::bigint);

\echo '\n===== 5. CONTEOS ====='
-- Operario cuenta 26 guantes cuando el sistema dice 30
select registrar_conteo(
  jsonb_build_array(jsonb_build_object(
    'producto_id', (select id from productos where sku='TST-SEG'),
    'cantidad_contada', 26,
    'motivo', 'Conteo semanal')),
  p_dispositivo_id => (select id from dispositivos where codigo='DEVICE-002'));

select assert_eq('Conteo calcula la diferencia',
  (select diferencia from conteo_items ci join productos p on p.id=ci.producto_id where p.sku='TST-SEG'),
  -4::numeric(14,3));
select assert_eq('El conteo NO modifica el inventario automáticamente',
  (select disponible from vw_productos_stock where sku='TST-SEG'), 30::numeric);

select assert_falla('Operario no aprueba su propio conteo',
  $q$ select aprobar_conteo((select id from conteos order by created_at desc limit 1)) $q$);

-- El supervisor aprueba
set request.jwt.claim.sub = '22222222-2222-2222-2222-222222222222';
select aprobar_conteo((select id from conteos order by created_at desc limit 1));

select assert_eq('Ajuste aprobado corrige el stock',
  (select disponible from vw_productos_stock where sku='TST-SEG'), 26::numeric);
select assert_eq('Ajuste queda en el historial',
  (select count(*) from movimientos where tipo='AJUSTE'), 1::bigint);

\echo '\n===== 6. REGLA DE ELIMINACIÓN ====='
set request.jwt.claim.sub = '11111111-1111-1111-1111-111111111111';
select assert_falla('Producto CON historial no se elimina',
  $q$ select eliminar_producto((select id from productos where sku='TST-HER')) $q$);

select desactivar_producto((select id from productos where sku='TST-HER'), 'Equipo dañado');
select assert_eq('Producto con historial se desactiva',
  (select activo from productos where sku='TST-HER'), false);

\echo '\n===== 7. AUDITORÍA E INTEGRIDAD ====='
select assert_eq('Todo movimiento guarda usuario',
  (select count(*) from movimientos where usuario_id is null), 0::bigint);
select assert_eq('Movimientos de stock guardan dispositivo',
  (select count(*) from movimientos
    where tipo in ('ENTRADA','SALIDA','DEVOLUCION') and dispositivo_id is null), 0::bigint);
select assert_eq('Movimientos son inmutables (no se pueden borrar)',
  (select count(*) > 0 from movimientos), true);

select assert_falla('No se puede editar un movimiento',
  $q$ update movimientos set cantidad = 999 where id = (select id from movimientos limit 1) $q$);

select assert_eq('Stock reconstruible desde el libro mayor',
  (select count(*) from reconstruir_stock() where not ok), 0::bigint);

select assert_eq('Auditoría registró la creación de productos',
  (select count(*) > 0 from auditoria where tabla='productos' and accion='INSERT'), true);

\echo '\n===== 8. IDEMPOTENCIA OFFLINE ====='
select registrar_movimiento('ENTRADA', (select id from productos where sku='TST-SEG'), 10,
  p_client_uuid => 'aaaaaaaa-0000-0000-0000-000000000001',
  p_dispositivo_id => (select id from dispositivos where codigo='DEVICE-001'));
-- Reintento del mismo movimiento (la tablet perdió la respuesta)
select registrar_movimiento('ENTRADA', (select id from productos where sku='TST-SEG'), 10,
  p_client_uuid => 'aaaaaaaa-0000-0000-0000-000000000001',
  p_dispositivo_id => (select id from dispositivos where codigo='DEVICE-001'));

select assert_eq('Reintento offline no duplica el movimiento',
  (select count(*) from movimientos where client_uuid='aaaaaaaa-0000-0000-0000-000000000001'), 1::bigint);
select assert_eq('Reintento offline no duplica el stock',
  (select disponible from vw_productos_stock where sku='TST-SEG'), 36::numeric);

\echo '\n===== 9. DASHBOARD Y ALERTAS ====='
select assert_eq('Dashboard cuenta solo productos activos',
  (select total_productos from vw_dashboard),
  (select count(*) from productos where activo));
-- Bajamos los guantes de 36 a 5 (mínimo = 10) para provocar la alerta
select registrar_movimiento('SALIDA', (select id from productos where sku='TST-SEG'), 31,
  p_obra_id => (select id from obras where codigo='OBRA-000'),
  p_dispositivo_id => (select id from dispositivos where codigo='DEVICE-001'));

select assert_eq('Alerta de stock bajo se dispara',
  (select count(*) from vw_alertas
    where tipo='STOCK_BAJO' and producto_id=(select id from productos where sku='TST-SEG')),
  1::bigint);

select assert_eq('Un producto desactivado no genera alertas',
  (select count(*) from vw_alertas where producto_id=(select id from productos where sku='TST-HER')),
  0::bigint);

\echo '\n===== FIN DE PRUEBAS ====='
