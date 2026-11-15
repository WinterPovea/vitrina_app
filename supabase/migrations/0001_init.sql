-- =====================================================================
-- 0001_init.sql — Esquema base multi-organización (Supabase / Postgres)
-- Ejecutar en: Supabase Dashboard > SQL Editor (o `supabase db push`).
-- Todas las tablas de negocio llevan organization_id => la misma base
-- sirve a varias organizaciones sin tocar código.
-- =====================================================================

create extension if not exists btree_gist;

-- ---------- Tipos ----------
create type public.user_role as enum ('client', 'specialist', 'admin');
create type public.appointment_status as enum ('pending', 'confirmed', 'completed', 'cancelled');

-- ---------- Organización y perfiles ----------
create table public.organizations (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  tagline     text,
  logo_url    text,
  whatsapp    text,                         -- internacional sin '+', ej: 593999999999
  currency    text not null default 'USD',
  timezone    text not null default 'America/Guayaquil',
  created_at  timestamptz not null default now()
);

create table public.profiles (
  id               uuid primary key references auth.users(id) on delete cascade,
  organization_id  uuid not null references public.organizations(id),
  full_name        text,
  phone            text,
  role             public.user_role not null default 'client',
  created_at       timestamptz not null default now()
);
create index on public.profiles (organization_id);

-- Funciones auxiliares para RLS (security definer evita recursión de políticas)
create function public.current_org_id() returns uuid
language sql stable security definer set search_path = public as
$$ select organization_id from public.profiles where id = auth.uid() $$;

create function public.current_user_role() returns public.user_role
language sql stable security definer set search_path = public as
$$ select role from public.profiles where id = auth.uid() $$;

-- ---------- Catálogo ----------
create table public.categories (
  id               uuid primary key default gen_random_uuid(),
  organization_id  uuid not null references public.organizations(id) on delete cascade,
  name             text not null,
  sort_order       int  not null default 0
);
create index on public.categories (organization_id);

-- MAESTRA 1: especialistas (trabajadores que ofrecen servicios)
create table public.specialists (
  id                uuid primary key default gen_random_uuid(),
  organization_id   uuid not null references public.organizations(id) on delete cascade,
  profile_id        uuid references public.profiles(id) on delete set null, -- login opcional
  display_name      text not null,
  title             text,
  bio               text,
  avatar_url        text,
  years_experience  int,
  phone             text,
  whatsapp          text,
  is_active         boolean not null default true,
  created_at        timestamptz not null default now()
);
create index on public.specialists (organization_id);

-- MAESTRA 2: servicios (catálogo de la organización)
create table public.services (
  id                uuid primary key default gen_random_uuid(),
  organization_id   uuid not null references public.organizations(id) on delete cascade,
  category_id       uuid references public.categories(id) on delete set null,
  name              text not null,
  description       text,
  duration_minutes  int  not null check (duration_minutes > 0),
  price             numeric(10,2) not null check (price >= 0),
  image_url         text,
  is_active         boolean not null default true,
  created_at        timestamptz not null default now()
);
create index on public.services (organization_id);

-- Qué servicios ofrece cada especialista (precio propio opcional)
create table public.specialist_services (
  specialist_id  uuid not null references public.specialists(id) on delete cascade,
  service_id     uuid not null references public.services(id) on delete cascade,
  price_override numeric(10,2) check (price_override >= 0),
  primary key (specialist_id, service_id)
);

-- Horario semanal (1 = lunes ... 7 = domingo, ISO)
create table public.specialist_schedules (
  id             uuid primary key default gen_random_uuid(),
  specialist_id  uuid not null references public.specialists(id) on delete cascade,
  weekday        int  not null check (weekday between 1 and 7),
  start_time     time not null,
  end_time       time not null,
  check (end_time > start_time)
);
create index on public.specialist_schedules (specialist_id);

-- ---------- TRANSACCIONAL: turnos ----------
create table public.appointments (
  id                 uuid primary key default gen_random_uuid(),
  organization_id    uuid not null default public.current_org_id(),
  client_id          uuid not null default auth.uid() references public.profiles(id),
  specialist_id      uuid not null references public.specialists(id),
  service_id         uuid not null references public.services(id),
  start_at           timestamptz not null,
  end_at             timestamptz not null,       -- lo calcula el trigger
  price_at_booking   numeric(10,2),              -- lo fija el trigger
  status             public.appointment_status not null default 'pending',
  notes              text,
  created_at         timestamptz not null default now(),
  check (end_at > start_at),
  -- Imposible tener dos turnos activos solapados con el mismo especialista
  constraint no_double_booking exclude using gist (
    specialist_id with =,
    tstzrange(start_at, end_at, '[)') with &&
  ) where (status in ('pending', 'confirmed'))
);
create index on public.appointments (client_id);
create index on public.appointments (specialist_id, start_at);

create function public.appointments_before_insert() returns trigger
language plpgsql security definer set search_path = public as $$
declare v_duration int; v_price numeric(10,2); v_org uuid; v_spec_org uuid;
begin
  select duration_minutes, price, organization_id into v_duration, v_price, v_org
    from public.services where id = new.service_id and is_active;
  if v_duration is null then raise exception 'Servicio no disponible'; end if;
  select organization_id into v_spec_org from public.specialists
    where id = new.specialist_id and is_active;
  if v_spec_org is null or v_spec_org <> v_org or v_org <> new.organization_id then
    raise exception 'Especialista o servicio no pertenecen a tu organización';
  end if;
  if new.start_at <= now() then raise exception 'La hora del turno ya pasó'; end if;
  new.end_at := new.start_at + make_interval(mins => v_duration);
  select coalesce(ss.price_override, v_price) into new.price_at_booking
    from public.specialist_services ss
    where ss.specialist_id = new.specialist_id and ss.service_id = new.service_id;
  if not found then raise exception 'El especialista no ofrece ese servicio'; end if;
  new.status := 'pending';
  return new;
end $$;
create trigger trg_appointments_before_insert
  before insert on public.appointments
  for each row execute function public.appointments_before_insert();

-- ---------- Reseñas ----------
create table public.reviews (
  id               uuid primary key default gen_random_uuid(),
  organization_id  uuid not null default public.current_org_id(),
  appointment_id   uuid not null unique references public.appointments(id) on delete cascade,
  specialist_id    uuid not null references public.specialists(id),
  client_id        uuid not null default auth.uid() references public.profiles(id),
  author_name      text,                           -- lo llena el trigger
  rating           int  not null check (rating between 1 and 5),
  comment          text,
  created_at       timestamptz not null default now()
);
create index on public.reviews (specialist_id);

create function public.reviews_before_insert() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  perform 1 from public.appointments a
    where a.id = new.appointment_id and a.client_id = new.client_id
      and a.specialist_id = new.specialist_id and a.status = 'completed';
  if not found then raise exception 'Solo puedes reseñar turnos completados tuyos'; end if;
  select full_name into new.author_name from public.profiles where id = new.client_id;
  return new;
end $$;
create trigger trg_reviews_before_insert
  before insert on public.reviews
  for each row execute function public.reviews_before_insert();

-- ---------- Vista: especialistas + calificación (la consume la app) ----------
create view public.specialist_overview with (security_invoker = true) as
select s.*,
       coalesce(round(avg(r.rating)::numeric, 1), 0) as avg_rating,
       count(r.id)::int                               as review_count
from public.specialists s
left join public.reviews r on r.specialist_id = s.id
group by s.id;

-- ---------- Disponibilidad: huecos libres para un día ----------
create function public.get_available_slots(p_specialist_id uuid, p_service_id uuid, p_date date)
returns table (slot_start timestamptz, slot_end timestamptz)
language sql stable security definer set search_path = public as $$
  with org as (
    select o.timezone as tz
    from public.specialists sp join public.organizations o on o.id = sp.organization_id
    where sp.id = p_specialist_id and sp.organization_id = public.current_org_id()
  ),
  svc as (select duration_minutes as d from public.services where id = p_service_id),
  windows as (
    select ((p_date + sc.start_time) at time zone org.tz) as w_start,
           ((p_date + sc.end_time)   at time zone org.tz) as w_end
    from public.specialist_schedules sc, org
    where sc.specialist_id = p_specialist_id
      and sc.weekday = extract(isodow from p_date)::int
  ),
  candidates as (
    select gs as s, gs + make_interval(mins => svc.d) as e, w.w_end
    from windows w, svc, generate_series(w.w_start, w.w_end, interval '30 minutes') gs
  )
  select c.s, c.e from candidates c
  where c.e <= c.w_end
    and c.s > now()
    and not exists (
      select 1 from public.appointments a
      where a.specialist_id = p_specialist_id
        and a.status in ('pending', 'confirmed')
        and tstzrange(a.start_at, a.end_at, '[)') && tstzrange(c.s, c.e, '[)')
    )
  order by c.s;
$$;

-- ---------- Alta automática de perfil al registrarse ----------
-- La app envía organization_id y full_name en user metadata.
-- El rol SIEMPRE es 'client': los roles se suben desde el panel/SQL.
create function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
declare v_org uuid;
begin
  v_org := nullif(new.raw_user_meta_data ->> 'organization_id', '')::uuid;
  if v_org is null or not exists (select 1 from public.organizations where id = v_org) then
    raise exception 'Organización inválida';
  end if;
  insert into public.profiles (id, organization_id, full_name, phone)
  values (new.id, v_org, new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'phone');
  return new;
end $$;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------- RLS ----------
alter table public.organizations        enable row level security;
alter table public.profiles             enable row level security;
alter table public.categories           enable row level security;
alter table public.specialists          enable row level security;
alter table public.services             enable row level security;
alter table public.specialist_services  enable row level security;
alter table public.specialist_schedules enable row level security;
alter table public.appointments         enable row level security;
alter table public.reviews              enable row level security;

-- Lectura del catálogo: cualquier usuario autenticado de la misma organización
create policy org_read on public.organizations for select to authenticated
  using (id = public.current_org_id());
create policy cat_read on public.categories for select to authenticated
  using (organization_id = public.current_org_id());
create policy spec_read on public.specialists for select to authenticated
  using (organization_id = public.current_org_id());
create policy svc_read on public.services for select to authenticated
  using (organization_id = public.current_org_id());
create policy specsvc_read on public.specialist_services for select to authenticated
  using (exists (select 1 from public.specialists s
                 where s.id = specialist_id and s.organization_id = public.current_org_id()));
create policy sched_read on public.specialist_schedules for select to authenticated
  using (exists (select 1 from public.specialists s
                 where s.id = specialist_id and s.organization_id = public.current_org_id()));
create policy rev_read on public.reviews for select to authenticated
  using (organization_id = public.current_org_id());

-- Escritura del catálogo: solo admin de la organización
create policy cat_admin on public.categories for all to authenticated
  using (organization_id = public.current_org_id() and public.current_user_role() = 'admin')
  with check (organization_id = public.current_org_id() and public.current_user_role() = 'admin');
create policy spec_admin on public.specialists for all to authenticated
  using (organization_id = public.current_org_id() and public.current_user_role() = 'admin')
  with check (organization_id = public.current_org_id() and public.current_user_role() = 'admin');
create policy svc_admin on public.services for all to authenticated
  using (organization_id = public.current_org_id() and public.current_user_role() = 'admin')
  with check (organization_id = public.current_org_id() and public.current_user_role() = 'admin');
create policy specsvc_admin on public.specialist_services for all to authenticated
  using (public.current_user_role() = 'admin' and exists (select 1 from public.specialists s
        where s.id = specialist_id and s.organization_id = public.current_org_id()))
  with check (public.current_user_role() = 'admin' and exists (select 1 from public.specialists s
        where s.id = specialist_id and s.organization_id = public.current_org_id()));
create policy sched_admin on public.specialist_schedules for all to authenticated
  using (public.current_user_role() = 'admin' and exists (select 1 from public.specialists s
        where s.id = specialist_id and s.organization_id = public.current_org_id()))
  with check (public.current_user_role() = 'admin' and exists (select 1 from public.specialists s
        where s.id = specialist_id and s.organization_id = public.current_org_id()));

-- Perfiles: cada quien ve y edita el suyo (sin poder cambiar su rol ni organización)
create policy prof_self_read on public.profiles for select to authenticated
  using (id = auth.uid());
create policy prof_admin_read on public.profiles for select to authenticated
  using (organization_id = public.current_org_id() and public.current_user_role() = 'admin');
create policy prof_self_update on public.profiles for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid()
              and role = public.current_user_role()
              and organization_id = public.current_org_id());

-- Turnos
create policy appt_client_read on public.appointments for select to authenticated
  using (client_id = auth.uid());
create policy appt_staff_read on public.appointments for select to authenticated
  using (organization_id = public.current_org_id()
         and (public.current_user_role() = 'admin'
              or exists (select 1 from public.specialists s
                         where s.id = specialist_id and s.profile_id = auth.uid())));
create policy appt_client_insert on public.appointments for insert to authenticated
  with check (client_id = auth.uid() and organization_id = public.current_org_id());
create policy appt_client_cancel on public.appointments for update to authenticated
  using (client_id = auth.uid())
  with check (client_id = auth.uid() and status = 'cancelled');
create policy appt_staff_update on public.appointments for update to authenticated
  using (organization_id = public.current_org_id()
         and (public.current_user_role() = 'admin'
              or exists (select 1 from public.specialists s
                         where s.id = specialist_id and s.profile_id = auth.uid())))
  with check (organization_id = public.current_org_id());

-- Reseñas: el cliente reseña turnos suyos completados (lo valida también el trigger)
create policy rev_client_insert on public.reviews for insert to authenticated
  with check (client_id = auth.uid() and organization_id = public.current_org_id());

-- Permisos de ejecución de RPC
grant execute on function public.get_available_slots(uuid, uuid, date) to authenticated;
