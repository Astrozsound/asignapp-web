-- ============================================================
-- INVENTARIO HYCE — 002_rpc.sql
-- Toda escritura de stock pasa por aquí. El cliente NUNCA
-- actualiza la tabla `inventario` directamente.
-- ============================================================

-- ------------------------------------------------------------
-- registrar_movimiento()
-- Atómica, bloquea la fila de inventario (FOR UPDATE) => dos
-- tablets simultáneas se serializan, nunca se pisan.
-- Idempotente: si llega dos veces el mismo p_client_uuid
-- (reintento de sincronización offline) devuelve el original.
-- ------------------------------------------------------------
create or replace function registrar_movimiento(
  p_tipo            tipo_movimiento,
  p_producto_id     uuid,
  p_cantidad        numeric,
  p_client_uuid     uuid    default null,
  p_obra_id         uuid    default null,
  p_operario_id     uuid    default null,
  p_dispositivo_id  uuid    default null,
  p_estado_dev      estado_devolucion default null,
  p_nota            text    default null,
  p_forzar_negativo boolean default false
)
returns movimientos
language plpgsql
security definer
set search_path = public
as $$
declare
  v_rol         rol_app  := rol_actual();
  v_uid         uuid     := auth.uid();
  v_bodega      uuid;
  v_inv         inventario%rowtype;
  v_delta       numeric(14,3);
  v_delta_obra  numeric(14,3) := 0;
  v_mov         movimientos%rowtype;
  v_producto    productos%rowtype;
begin
  -- 0) Idempotencia
  if p_client_uuid is not null then
    select * into v_mov from movimientos where client_uuid = p_client_uuid;
    if found then return v_mov; end if;
  end if;

  -- 1) Validaciones básicas
  -- AJUSTE es el único tipo que admite cantidad firmada (un conteo puede dar -4).
  if p_cantidad is null or p_cantidad = 0 then
    raise exception 'La cantidad debe ser distinta de cero.';
  end if;
  if p_cantidad < 0 and p_tipo <> 'AJUSTE' then
    raise exception 'La cantidad debe ser mayor que cero para %.', p_tipo;
  end if;

  select * into v_producto from productos where id = p_producto_id;
  if not found then raise exception 'Producto no encontrado.'; end if;
  if not v_producto.activo and p_tipo <> 'DEVOLUCION' then
    raise exception 'El producto "%" está desactivado.', v_producto.nombre;
  end if;

  -- 2) Permisos (el backend no confía en la interfaz)
  if v_rol is null then raise exception 'Sesión no válida.'; end if;

  if p_tipo in ('ENTRADA','AJUSTE') and v_rol = 'OPERARIO' then
    raise exception 'Su rol no permite registrar % .', p_tipo;
  end if;

  if p_tipo not in ('ENTRADA','SALIDA','DEVOLUCION','AJUSTE') then
    raise exception 'Use este RPC solo para ENTRADA, SALIDA, DEVOLUCION o AJUSTE.';
  end if;

  if p_forzar_negativo and v_rol = 'OPERARIO' then
    raise exception 'Solo un administrador puede autorizar stock negativo.';
  end if;

  -- 3) Reglas por tipo
  if p_tipo = 'SALIDA' and p_obra_id is null then
    raise exception 'Debe indicar la obra para registrar una salida.';
  end if;

  if p_obra_id is not null
     and not exists (select 1 from obras where id = p_obra_id and estado = 'ACTIVA') then
    raise exception 'La obra indicada no está activa.';
  end if;

  -- 4) Bloqueo de la fila de inventario (fuente única de verdad)
  select b.id into v_bodega from bodegas b where b.activo order by b.created_at limit 1;

  insert into inventario (producto_id, bodega_id, cantidad)
  values (p_producto_id, v_bodega, 0)
  on conflict do nothing;

  select * into v_inv
  from inventario
  where producto_id = p_producto_id and bodega_id = v_bodega
  for update;                                     -- <<< serializa concurrencia

  -- 5) Cálculo del efecto
  v_delta := case p_tipo
               when 'ENTRADA'    then  p_cantidad
               when 'SALIDA'     then -p_cantidad
               when 'DEVOLUCION' then  p_cantidad
               when 'AJUSTE'     then  p_cantidad   -- ya viene firmado
             end;

  -- Herramientas retornables: control de "en obra"
  if v_producto.es_retornable then
    if p_tipo = 'SALIDA'     then v_delta_obra :=  p_cantidad; end if;
    if p_tipo = 'DEVOLUCION' then v_delta_obra := -p_cantidad; end if;
  end if;

  if p_tipo = 'DEVOLUCION' and v_producto.es_retornable
     and v_inv.en_obra < p_cantidad then
    raise exception 'Devolución inválida: solo hay % unidad(es) pendientes de devolver.', v_inv.en_obra;
  end if;

  -- Devolución en mal estado: no vuelve a stock disponible
  if p_tipo = 'DEVOLUCION' and p_estado_dev in ('DANADO','MANTENIMIENTO') then
    v_delta := 0;
  end if;

  if v_inv.cantidad + v_delta < 0 and not p_forzar_negativo then
    raise exception 'Stock insuficiente de "%": disponible %, solicitado %.',
      v_producto.nombre, v_inv.cantidad, p_cantidad
      using errcode = 'check_violation';
  end if;

  -- 6) Aplicar
  update inventario
     set cantidad   = cantidad + v_delta,
         en_obra    = greatest(en_obra + v_delta_obra, 0),
         updated_at = now()
   where producto_id = p_producto_id and bodega_id = v_bodega;

  -- 7) Registrar en el libro mayor
  insert into movimientos (
    client_uuid, tipo, producto_id, bodega_id, cantidad, delta,
    stock_anterior, stock_posterior, obra_id, operario_id, usuario_id,
    dispositivo_id, estado_dev, nota
  ) values (
    p_client_uuid, p_tipo, p_producto_id, v_bodega, abs(p_cantidad), v_delta,
    v_inv.cantidad, v_inv.cantidad + v_delta, p_obra_id,
    coalesce(p_operario_id, v_uid), v_uid,
    p_dispositivo_id, p_estado_dev, p_nota
  ) returning * into v_mov;

  -- 8) Estado del producto tras devolución con novedad
  if p_tipo = 'DEVOLUCION' and p_estado_dev = 'DANADO' then
    update productos set estado = 'DANADO' where id = p_producto_id;
  elsif p_tipo = 'DEVOLUCION' and p_estado_dev = 'MANTENIMIENTO' then
    update productos set estado = 'MANTENIMIENTO' where id = p_producto_id;
  end if;

  return v_mov;
end $$;

-- ------------------------------------------------------------
-- buscar_por_codigo() — usado por el escáner
-- ------------------------------------------------------------
create or replace function buscar_por_codigo(p_codigo text)
returns setof vw_productos_stock
language sql stable as $$
  select * from vw_productos_stock
  where codigo_barras = p_codigo or sku = p_codigo
  limit 1;
$$;

-- ------------------------------------------------------------
-- registrar_conteo() — nunca modifica stock, solo deja la diferencia
-- ------------------------------------------------------------
create or replace function registrar_conteo(
  p_items          jsonb,              -- [{"producto_id":"...","cantidad_contada":96,"motivo":"..."}]
  p_client_uuid    uuid default null,
  p_dispositivo_id uuid default null,
  p_nota           text default null
)
returns conteos
language plpgsql security definer set search_path = public as $$
declare
  v_conteo conteos%rowtype;
  v_bodega uuid;
  v_item   jsonb;
  v_sist   numeric(14,3);
begin
  if p_client_uuid is not null then
    select * into v_conteo from conteos where client_uuid = p_client_uuid;
    if found then return v_conteo; end if;
  end if;

  select id into v_bodega from bodegas where activo order by created_at limit 1;

  insert into conteos (client_uuid, bodega_id, estado, usuario_id, dispositivo_id, nota)
  values (p_client_uuid, v_bodega, 'PENDIENTE', auth.uid(), p_dispositivo_id, p_nota)
  returning * into v_conteo;

  for v_item in select * from jsonb_array_elements(p_items) loop
    select cantidad into v_sist
      from inventario
     where producto_id = (v_item->>'producto_id')::uuid and bodega_id = v_bodega;

    insert into conteo_items (conteo_id, producto_id, cantidad_sistema, cantidad_contada, motivo)
    values (
      v_conteo.id,
      (v_item->>'producto_id')::uuid,
      coalesce(v_sist, 0),
      (v_item->>'cantidad_contada')::numeric,
      v_item->>'motivo'
    );
  end loop;

  return v_conteo;
end $$;

-- ------------------------------------------------------------
-- aprobar_conteo() — solo ADMIN/SUPERVISOR. Genera los AJUSTES.
-- ------------------------------------------------------------
create or replace function aprobar_conteo(p_conteo_id uuid)
returns integer
language plpgsql security definer set search_path = public as $$
declare
  v_item  conteo_items%rowtype;
  v_n     integer := 0;
begin
  if not es_supervisor_o_mas() then
    raise exception 'Solo un supervisor o administrador puede aprobar un conteo.';
  end if;

  if not exists (select 1 from conteos where id = p_conteo_id and estado = 'PENDIENTE') then
    raise exception 'El conteo no existe o ya fue procesado.';
  end if;

  for v_item in
    select * from conteo_items where conteo_id = p_conteo_id and not aplicado and diferencia <> 0
  loop
    perform registrar_movimiento(
      p_tipo            => 'AJUSTE',
      p_producto_id     => v_item.producto_id,
      p_cantidad        => v_item.diferencia,
      p_nota            => coalesce(v_item.motivo, 'Ajuste por conteo físico'),
      p_forzar_negativo => false
    );
    update conteo_items set aplicado = true where id = v_item.id;
    v_n := v_n + 1;
  end loop;

  update conteos
     set estado = 'APROBADO', aprobado_por = auth.uid(), aprobado_at = now()
   where id = p_conteo_id;

  return v_n;
end $$;

-- ------------------------------------------------------------
-- desactivar_producto() / eliminar_producto()
-- Aplica la regla: con historial => desactivar; sin historial => borrar.
-- ------------------------------------------------------------
create or replace function desactivar_producto(p_producto_id uuid, p_motivo text default null)
returns void
language plpgsql security definer set search_path = public as $$
begin
  if not es_supervisor_o_mas() then
    raise exception 'Su rol no permite desactivar productos.';
  end if;
  update productos set activo = false, estado = 'INACTIVO' where id = p_producto_id;
  insert into movimientos (tipo, producto_id, usuario_id, nota)
  values ('DESACTIVACION', p_producto_id, auth.uid(), p_motivo);
end $$;

create or replace function eliminar_producto(p_producto_id uuid)
returns void
language plpgsql security definer set search_path = public as $$
begin
  if not es_admin() then
    raise exception 'Solo un administrador puede eliminar productos.';
  end if;
  -- El trigger proteger_producto_con_historial() bloquea si hay movimientos.
  delete from productos where id = p_producto_id;
end $$;

-- ------------------------------------------------------------
-- reconstruir_stock() — verificación de integridad (auditoría)
-- Compara `inventario` contra la suma del libro mayor.
-- ------------------------------------------------------------
create or replace function reconstruir_stock()
returns table (producto_id uuid, nombre text, stock_actual numeric, stock_calculado numeric, ok boolean)
language sql stable as $$
  select
    p.id, p.nombre,
    coalesce(i.cantidad, 0),
    coalesce((select sum(m.delta) from movimientos m where m.producto_id = p.id), 0),
    coalesce(i.cantidad, 0) = coalesce((select sum(m.delta) from movimientos m where m.producto_id = p.id), 0)
  from productos p
  left join inventario i on i.producto_id = p.id;
$$;
