-- ============================================================
-- SOLO PARA PRUEBAS LOCALES — no ejecutar en Supabase.
-- Reproduce lo mínimo de Supabase: schema auth, auth.uid(),
-- y los roles anon / authenticated / service_role.
-- ============================================================
create schema if not exists auth;

create table if not exists auth.users (
  id    uuid primary key default gen_random_uuid(),
  email text unique
);

-- auth.uid() de Supabase lee el claim `sub` del JWT.
create or replace function auth.uid()
returns uuid language sql stable as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
$$;

do $$ begin create role anon;          exception when duplicate_object then null; end $$;
do $$ begin create role authenticated; exception when duplicate_object then null; end $$;
do $$ begin create role service_role;  exception when duplicate_object then null; end $$;

grant usage on schema public to anon, authenticated, service_role;
alter default privileges in schema public
  grant select, insert, update, delete on tables to authenticated;
alter default privileges in schema public grant usage on sequences to authenticated;
