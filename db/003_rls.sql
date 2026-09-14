-- ============================================================
-- INVENTARIO HYCE — 003_rls.sql
-- Principio: aunque el operario no vea el botón, el backend
-- tiene que impedir la acción igualmente.
-- ============================================================

alter table perfiles      enable row level security;
alter table dispositivos  enable row level security;
alter table categorias    enable row level security;
alter table unidades      enable row level security;
alter table bodegas       enable row level security;
alter table ubicaciones   enable row level security;
alter table obras         enable row level security;
alter table productos     enable row level security;
alter table inventario    enable row level security;
alter table movimientos   enable row level security;
alter table conteos       enable row level security;
alter table conteo_items  enable row level security;
alter table auditoria     enable row level security;

-- ---------- PERFILES ----------
create policy perfiles_ver_propio on perfiles
  for select using (id = auth.uid() or es_supervisor_o_mas());
create policy perfiles_admin_todo on perfiles
  for all using (es_admin()) with check (es_admin());

-- ---------- CATÁLOGOS: todos leen, solo supervisor+ escribe ----------
do $$
declare t text;
begin
  foreach t in array array['categorias','unidades','bodegas','ubicaciones','dispositivos','obras']
  loop
    execute format(
      'create policy %1$s_select on %1$s for select using (auth.uid() is not null)', t);
    execute format(
      'create policy %1$s_write on %1$s for all using (es_supervisor_o_mas()) with check (es_supervisor_o_mas())', t);
  end loop;
end $$;

-- ---------- PRODUCTOS ----------
-- Operarios ven solo productos activos; supervisores ven todo.
create policy productos_select on productos
  for select using (activo or es_supervisor_o_mas());

create policy productos_insert on productos
  for insert with check (es_supervisor_o_mas());

create policy productos_update on productos
  for update using (es_supervisor_o_mas()) with check (es_supervisor_o_mas());

-- Borrado: solo ADMIN, y aun así el trigger exige que no haya historial.
create policy productos_delete on productos
  for delete using (es_admin());

-- ---------- INVENTARIO ----------
-- Lectura para todos; escritura SOLO a través de los RPC (security definer).
create policy inventario_select on inventario
  for select using (auth.uid() is not null);
-- (sin políticas de insert/update/delete => nadie escribe directamente)

-- ---------- MOVIMIENTOS ----------
-- Operario ve su propio historial; supervisor+ ve todo.
create policy movimientos_select on movimientos
  for select using (
    es_supervisor_o_mas() or operario_id = auth.uid() or usuario_id = auth.uid()
  );
-- Sin insert/update/delete directos: todo pasa por registrar_movimiento().

-- ---------- CONTEOS ----------
create policy conteos_select on conteos
  for select using (es_supervisor_o_mas() or usuario_id = auth.uid());
create policy conteos_insert on conteos
  for insert with check (auth.uid() is not null);
create policy conteos_update on conteos
  for update using (es_supervisor_o_mas()) with check (es_supervisor_o_mas());

create policy conteo_items_select on conteo_items
  for select using (
    exists (select 1 from conteos c where c.id = conteo_id
            and (es_supervisor_o_mas() or c.usuario_id = auth.uid()))
  );
create policy conteo_items_insert on conteo_items
  for insert with check (auth.uid() is not null);

-- ---------- AUDITORÍA ----------
create policy auditoria_select on auditoria
  for select using (es_admin());

-- ---------- PERMISOS DE EJECUCIÓN ----------
revoke all on function registrar_movimiento from public;
grant execute on function registrar_movimiento  to authenticated;
grant execute on function registrar_conteo      to authenticated;
grant execute on function aprobar_conteo        to authenticated;
grant execute on function desactivar_producto   to authenticated;
grant execute on function eliminar_producto     to authenticated;
grant execute on function buscar_por_codigo     to authenticated;
grant execute on function reconstruir_stock     to authenticated;
