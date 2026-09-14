-- ============================================================
-- INVENTARIO HYCE — 001_schema.sql
-- PostgreSQL 15 / Supabase
-- Fuente única de verdad del inventario.
-- ============================================================

create extension if not exists "pgcrypto";

-- ------------------------------------------------------------
-- TIPOS
-- ------------------------------------------------------------
do $$ begin
  create type rol_app as enum ('ADMIN','SUPERVISOR','OPERARIO');
exception when duplicate_object then null; end $$;

do $$ begin
  create type estado_producto as enum (
    'DISPONIBLE','EN_USO','EN_OBRA','DANADO','PERDIDO','MANTENIMIENTO','INACTIVO'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type tipo_movimiento as enum (
    'ENTRADA','SALIDA','DEVOLUCION','AJUSTE','CONTEO',
    'CAMBIO_ESTADO','CREACION','EDICION','DESACTIVACION','TRANSFERENCIA'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type estado_devolucion as enum ('BUENO','DANADO','MANTENIMIENTO');
exception when duplicate_object then null; end $$;

do $$ begin
  create type estado_obra as enum ('ACTIVA','FINALIZADA','CANCELADA');
exception when duplicate_object then null; end $$;

do $$ begin
  create type estado_conteo as enum ('BORRADOR','PENDIENTE','APROBADO','RECHAZADO');
exception when duplicate_object then null; end $$;

do $$ begin
  create type tipo_dispositivo as enum ('BODEGA','OPERARIO');
exception when duplicate_object then null; end $$;

-- ------------------------------------------------------------
-- UTILIDADES
-- ------------------------------------------------------------
create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

-- ------------------------------------------------------------
-- USUARIOS / PERFILES
-- Extiende auth.users de Supabase. El rol vive aquí, nunca en el cliente.
-- ------------------------------------------------------------
create table if not exists perfiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  nombre       text not null,
  rol          rol_app not null default 'OPERARIO',
  telefono     text,
  activo       boolean not null default true,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
create trigger trg_perfiles_updated before update on perfiles
  for each row execute function set_updated_at();

-- Helpers de rol: SECURITY DEFINER para no recursar sobre RLS de perfiles.
create or replace function rol_actual()
returns rol_app language sql stable security definer set search_path = public as $$
  select rol from perfiles where id = auth.uid()
$$;

create or replace function es_admin() returns boolean
language sql stable as $$ select rol_actual() = 'ADMIN' $$;

create or replace function es_supervisor_o_mas() returns boolean
language sql stable as $$ select rol_actual() in ('ADMIN','SUPERVISOR') $$;

-- ------------------------------------------------------------
-- DISPOSITIVOS (las 3 tablets)
-- ------------------------------------------------------------
create table if not exists dispositivos (
  id          uuid primary key default gen_random_uuid(),
  codigo      text not null unique,            -- DEVICE-001
  nombre      text not null,                   -- "Bodega principal"
  tipo        tipo_dispositivo not null default 'OPERARIO',
  activo      boolean not null default true,
  created_at  timestamptz not null default now()
);

-- ------------------------------------------------------------
-- CATÁLOGOS
-- ------------------------------------------------------------
create table if not exists categorias (
  id          uuid primary key default gen_random_uuid(),
  nombre      text not null unique,
  color       text,
  activo      boolean not null default true,
  created_at  timestamptz not null default now()
);

create table if not exists unidades (
  id          uuid primary key default gen_random_uuid(),
  codigo      text not null unique,            -- UND, PAR, CAJA...
  nombre      text not null,
  decimales   boolean not null default false,  -- KG, L, M admiten decimales
  activo      boolean not null default true
);

create table if not exists bodegas (
  id          uuid primary key default gen_random_uuid(),
  nombre      text not null unique,
  direccion   text,
  activo      boolean not null default true,
  created_at  timestamptz not null default now()
);

create table if not exists ubicaciones (
  id          uuid primary key default gen_random_uuid(),
  bodega_id   uuid not null references bodegas(id) on delete restrict,
  nombre      text not null,                   -- Estante 1, Área exterior...
  activo      boolean not null default true,
  unique (bodega_id, nombre)
);

-- ------------------------------------------------------------
-- OBRAS / PROYECTOS
-- ------------------------------------------------------------
create table if not exists obras (
  id          uuid primary key default gen_random_uuid(),
  nombre      text not null,
  codigo      text unique,
  cliente     text,
  direccion   text,
  estado      estado_obra not null default 'ACTIVA',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create trigger trg_obras_updated before update on obras
  for each row execute function set_updated_at();
create index if not exists idx_obras_estado on obras(estado);

-- ------------------------------------------------------------
-- PRODUCTOS (datos maestros — sin stock)
-- ------------------------------------------------------------
create table if not exists productos (
  id               uuid primary key default gen_random_uuid(),
  sku              text unique,
  nombre           text not null,
  categoria_id     uuid references categorias(id) on delete restrict,
  descripcion      text,
  unidad_id        uuid references unidades(id) on delete restrict,
  codigo_barras    text unique,
  stock_minimo     numeric(14,3) not null default 0,
  ubicacion_id     uuid references ubicaciones(id) on delete set null,
  estado           estado_producto not null default 'DISPONIBLE',
  es_consumible    boolean not null default false,
  es_retornable    boolean not null default true,   -- herramientas/equipos
  activo           boolean not null default true,   -- false = desactivado
  requiere_revision boolean not null default false, -- datos ambiguos del Excel
  nota_import      text,                            -- rastro del origen
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  created_by       uuid references perfiles(id)
);
create trigger trg_productos_updated before update on productos
  for each row execute function set_updated_at();

create index if not exists idx_productos_nombre  on productos using gin (to_tsvector('spanish', nombre));
create index if not exists idx_productos_cat     on productos(categoria_id);
create index if not exists idx_productos_activo  on productos(activo);
create index if not exists idx_productos_barras  on productos(codigo_barras);
create index if not exists idx_productos_revision on productos(requiere_revision) where requiere_revision;

-- ------------------------------------------------------------
-- INVENTARIO (estado actual — una fila por producto+bodega)
-- Esta tabla NUNCA se edita a mano: solo vía RPC registrar_movimiento().
-- ------------------------------------------------------------
create table if not exists inventario (
  producto_id  uuid not null references productos(id) on delete cascade,
  bodega_id    uuid not null references bodegas(id)  on delete restrict,
  cantidad     numeric(14,3) not null default 0,   -- disponible en bodega
  en_obra      numeric(14,3) not null default 0,   -- fuera, pendiente de devolución
  updated_at   timestamptz not null default now(),
  primary key (producto_id, bodega_id),
  constraint chk_cantidad_no_negativa check (cantidad >= 0),
  constraint chk_en_obra_no_negativa  check (en_obra  >= 0)
);
create index if not exists idx_inventario_bodega on inventario(bodega_id);

-- Alta automática de la fila de inventario al crear un producto.
create or replace function crear_inventario_producto()
returns trigger language plpgsql security definer set search_path = public as $$
declare v_bodega uuid;
begin
  select id into v_bodega from bodegas where activo order by created_at limit 1;
  if v_bodega is not null then
    insert into inventario (producto_id, bodega_id, cantidad)
    values (new.id, v_bodega, 0)
    on conflict do nothing;
  end if;
  return new;
end $$;

create trigger trg_producto_inventario after insert on productos
  for each row execute function crear_inventario_producto();

-- ------------------------------------------------------------
-- MOVIMIENTOS (libro mayor inmutable)
-- El stock siempre debe poder reconstruirse sumando esta tabla.
-- ------------------------------------------------------------
create table if not exists movimientos (
  id                uuid primary key default gen_random_uuid(),
  client_uuid       uuid unique,              -- idempotencia offline
  tipo              tipo_movimiento not null,
  producto_id       uuid references productos(id) on delete restrict,
  bodega_id         uuid references bodegas(id)  on delete restrict,
  cantidad          numeric(14,3) not null default 0 check (cantidad >= 0),
  delta             numeric(14,3) not null default 0,  -- efecto real en stock
  stock_anterior    numeric(14,3),
  stock_posterior   numeric(14,3),
  obra_id           uuid references obras(id)   on delete set null,
  operario_id       uuid references perfiles(id),      -- quién se lo lleva
  usuario_id        uuid references perfiles(id),      -- quién lo registra
  dispositivo_id    uuid references dispositivos(id),
  estado_dev        estado_devolucion,
  movimiento_origen uuid references movimientos(id),   -- devolución -> salida
  nota              text,
  datos             jsonb,                    -- para CREACION/EDICION/etc.
  created_at        timestamptz not null default now()
);
create index if not exists idx_mov_producto on movimientos(producto_id, created_at desc);
create index if not exists idx_mov_fecha    on movimientos(created_at desc);
create index if not exists idx_mov_obra     on movimientos(obra_id);
create index if not exists idx_mov_operario on movimientos(operario_id, created_at desc);
create index if not exists idx_mov_tipo     on movimientos(tipo);

-- Inmutabilidad: nunca se edita ni se borra un movimiento.
create or replace function bloquear_mutacion_movimientos()
returns trigger language plpgsql as $$
begin
  raise exception 'Los movimientos son inmutables. Registre un movimiento correctivo (AJUSTE).';
end $$;

create trigger trg_mov_no_update before update on movimientos
  for each row execute function bloquear_mutacion_movimientos();
create trigger trg_mov_no_delete before delete on movimientos
  for each row execute function bloquear_mutacion_movimientos();

-- ------------------------------------------------------------
-- REGLA CRÍTICA: no borrar productos con historial
-- ------------------------------------------------------------
create or replace function proteger_producto_con_historial()
returns trigger language plpgsql as $$
begin
  if exists (select 1 from movimientos where producto_id = old.id) then
    raise exception
      'El producto "%" tiene historial de movimientos. Desactívelo en lugar de eliminarlo.', old.nombre
      using errcode = 'restrict_violation';
  end if;
  return old;
end $$;

create trigger trg_producto_no_borrar before delete on productos
  for each row execute function proteger_producto_con_historial();

-- ------------------------------------------------------------
-- CONTEOS FÍSICOS
-- ------------------------------------------------------------
create table if not exists conteos (
  id             uuid primary key default gen_random_uuid(),
  client_uuid    uuid unique,
  bodega_id      uuid not null references bodegas(id) on delete restrict,
  estado         estado_conteo not null default 'PENDIENTE',
  usuario_id     uuid references perfiles(id),
  dispositivo_id uuid references dispositivos(id),
  nota           text,
  aprobado_por   uuid references perfiles(id),
  aprobado_at    timestamptz,
  created_at     timestamptz not null default now()
);

create table if not exists conteo_items (
  id                uuid primary key default gen_random_uuid(),
  conteo_id         uuid not null references conteos(id) on delete cascade,
  producto_id       uuid not null references productos(id) on delete restrict,
  cantidad_sistema  numeric(14,3) not null,
  cantidad_contada  numeric(14,3) not null,
  diferencia        numeric(14,3) generated always as (cantidad_contada - cantidad_sistema) stored,
  motivo            text,
  aplicado          boolean not null default false,
  unique (conteo_id, producto_id)
);
create index if not exists idx_conteo_items_conteo on conteo_items(conteo_id);

-- ------------------------------------------------------------
-- AUDITORÍA
-- ------------------------------------------------------------
create table if not exists auditoria (
  id             bigserial primary key,
  tabla          text not null,
  registro_id    text,
  accion         text not null,          -- INSERT / UPDATE / DELETE / RPC
  usuario_id     uuid,
  dispositivo_id uuid,
  antes          jsonb,
  despues        jsonb,
  created_at     timestamptz not null default now()
);
create index if not exists idx_auditoria_tabla on auditoria(tabla, created_at desc);

create or replace function auditar()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into auditoria (tabla, registro_id, accion, usuario_id, antes, despues)
  values (
    tg_table_name,
    coalesce((to_jsonb(new)->>'id'), (to_jsonb(old)->>'id')),
    tg_op,
    auth.uid(),
    case when tg_op in ('UPDATE','DELETE') then to_jsonb(old) end,
    case when tg_op in ('INSERT','UPDATE') then to_jsonb(new) end
  );
  return coalesce(new, old);
end $$;

create trigger trg_aud_productos after insert or update or delete on productos
  for each row execute function auditar();
create trigger trg_aud_perfiles  after insert or update or delete on perfiles
  for each row execute function auditar();
create trigger trg_aud_obras     after insert or update or delete on obras
  for each row execute function auditar();
create trigger trg_aud_conteos   after insert or update on conteos
  for each row execute function auditar();

-- ------------------------------------------------------------
-- VISTAS (dashboard y alertas se calculan, no se almacenan)
-- ------------------------------------------------------------
create or replace view vw_productos_stock as
select
  p.id, p.sku, p.nombre, p.codigo_barras, p.estado, p.activo,
  p.stock_minimo, p.es_consumible, p.es_retornable, p.requiere_revision,
  c.nombre as categoria, u.codigo as unidad,
  ub.nombre as ubicacion, b.nombre as bodega,
  coalesce(i.cantidad, 0) as disponible,
  coalesce(i.en_obra, 0)  as en_obra,
  coalesce(i.cantidad, 0) + coalesce(i.en_obra, 0) as total,
  i.updated_at as stock_actualizado
from productos p
left join inventario i  on i.producto_id = p.id
left join bodegas b     on b.id = i.bodega_id
left join categorias c  on c.id = p.categoria_id
left join unidades u    on u.id = p.unidad_id
left join ubicaciones ub on ub.id = p.ubicacion_id;

create or replace view vw_alertas as
  select 'STOCK_AGOTADO' as tipo, 'ALTA' as severidad, id as producto_id, nombre,
         'Sin existencias en bodega' as detalle
  from vw_productos_stock where activo and disponible = 0 and not es_retornable
union all
  select 'STOCK_BAJO', 'MEDIA', id, nombre,
         'Disponible ' || disponible || ' / mínimo ' || stock_minimo
  from vw_productos_stock
  where activo and stock_minimo > 0 and disponible > 0 and disponible <= stock_minimo
union all
  select 'PRODUCTO_PERDIDO', 'ALTA', id, nombre, 'Marcado como perdido'
  from vw_productos_stock where activo and estado = 'PERDIDO'
union all
  select 'PRODUCTO_DANADO', 'MEDIA', id, nombre, 'Marcado como dañado'
  from vw_productos_stock where activo and estado = 'DANADO'
union all
  select 'REQUIERE_REVISION', 'BAJA', id, nombre, 'Dato importado ambiguo'
  from vw_productos_stock where activo and requiere_revision;

-- Herramientas que llevan >7 días en obra sin devolverse
create or replace view vw_herramientas_en_obra as
select
  p.id as producto_id, p.nombre, i.en_obra,
  m.obra_id, o.nombre as obra,
  m.operario_id, pf.nombre as operario,
  m.created_at as salida_at,
  (now() - m.created_at) as tiempo_fuera
from inventario i
join productos p on p.id = i.producto_id
join lateral (
  select * from movimientos mm
  where mm.producto_id = i.producto_id and mm.tipo = 'SALIDA'
  order by mm.created_at desc limit 1
) m on true
left join obras o    on o.id = m.obra_id
left join perfiles pf on pf.id = m.operario_id
where i.en_obra > 0;

create or replace view vw_dashboard as
select
  (select count(*) from productos where activo)                                as total_productos,
  (select coalesce(sum(cantidad + en_obra),0) from inventario)                 as total_unidades,
  (select count(*) from vw_productos_stock
     where activo and stock_minimo > 0 and disponible <= stock_minimo
       and disponible > 0)                                                     as stock_bajo,
  (select count(*) from vw_productos_stock where activo and disponible = 0)    as agotados,
  (select coalesce(sum(en_obra),0) from inventario)                            as unidades_en_obra,
  (select count(*) from movimientos where created_at::date = current_date)     as movimientos_hoy,
  (select count(*) from movimientos
     where tipo='SALIDA' and created_at::date = current_date)                  as salidas_hoy,
  (select count(*) from movimientos
     where tipo='DEVOLUCION' and created_at::date = current_date)              as devoluciones_hoy,
  (select count(*) from conteos where estado = 'PENDIENTE')                    as conteos_pendientes;
