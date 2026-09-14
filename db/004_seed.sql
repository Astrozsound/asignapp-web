-- ============================================================
-- INVENTARIO HYCE — 004_seed.sql
-- Catálogos base. NO contiene productos: esos entran por el
-- importador del Excel (no se inventan datos de inventario).
-- ============================================================

insert into categorias (nombre) values
  ('Herramientas'), ('Equipos'), ('Máquinas'),
  ('Materiales'), ('Seguridad'), ('Consumibles')
on conflict (nombre) do nothing;

insert into unidades (codigo, nombre, decimales) values
  ('UND',  'Unidad',      false),
  ('PAR',  'Par',         false),
  ('CAJA', 'Caja',        false),
  ('PAQ',  'Paquete',     false),
  ('M',    'Metro',       true),
  ('KG',   'Kilogramo',   true),
  ('L',    'Litro',       true),
  ('GAL',  'Galón',       true),
  ('OTRO', 'Otro',        true)
on conflict (codigo) do nothing;

insert into bodegas (nombre, direccion) values
  ('Bodega Principal', 'Container — sede Constructora HYCE')
on conflict (nombre) do nothing;

insert into ubicaciones (bodega_id, nombre)
select b.id, u.nombre
from bodegas b
cross join (values
  ('Container'), ('Estante 1'), ('Estante 2'), ('Estante 3'),
  ('Área exterior'), ('Otro')
) as u(nombre)
where b.nombre = 'Bodega Principal'
on conflict (bodega_id, nombre) do nothing;

insert into dispositivos (codigo, nombre, tipo) values
  ('DEVICE-001', 'Bodega principal (tablet fija)', 'BODEGA'),
  ('DEVICE-002', 'Operario A',                      'OPERARIO'),
  ('DEVICE-003', 'Operario B',                      'OPERARIO')
on conflict (codigo) do nothing;

-- Obra de prueba para validar el flujo de salida/devolución.
insert into obras (nombre, codigo, estado) values
  ('Obra de prueba', 'OBRA-000', 'ACTIVA')
on conflict (codigo) do nothing;
