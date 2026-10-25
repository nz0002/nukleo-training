-- NUKLEO TRAINING — esquema inicial PostgreSQL/Supabase
create extension if not exists pgcrypto;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.admin_users enable row level security;
create policy "admins can read own authorization" on public.admin_users
 for select to authenticated using (user_id = auth.uid());

create or replace function public.is_admin()
returns boolean language sql stable security definer
set search_path = public
as $$ select exists(select 1 from public.admin_users where user_id = auth.uid()) $$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

create table if not exists public.categories (
 id uuid primary key default gen_random_uuid(),
 name text not null unique,
 slug text not null unique,
 sort_order int not null default 0,
 published boolean not null default true,
 created_at timestamptz not null default now()
);
create table if not exists public.products (
 id uuid primary key default gen_random_uuid(),
 name text not null,
 slug text unique,
 category text not null,
 technique text not null,
 description text not null default '',
 tiers jsonb not null default '[]'::jsonb,
 image text not null default '',
 alt text not null default '',
 gallery jsonb not null default '[]'::jsonb,
 sizes jsonb not null default '[]'::jsonb,
 colors jsonb not null default '[]'::jsonb,
 featured boolean not null default false,
 published boolean not null default false,
 sort_order int not null default 0,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 constraint products_tiers_array check (jsonb_typeof(tiers) = 'array')
);
create table if not exists public.site_content (
 key text primary key,
 draft jsonb not null default '{}'::jsonb,
 published jsonb not null default '{}'::jsonb,
 updated_at timestamptz not null default now(),
 published_at timestamptz
);
create table if not exists public.site_settings (
 key text primary key,
 value jsonb not null default '{}'::jsonb,
 updated_at timestamptz not null default now()
);
create table if not exists public.media_assets (
 id uuid primary key default gen_random_uuid(),
 path text not null unique,
 public_url text not null,
 alt text not null default '',
 mime_type text not null,
 size_bytes bigint not null check (size_bytes > 0 and size_bytes <= 10485760),
 created_by uuid references auth.users(id),
 created_at timestamptz not null default now()
);
create table if not exists public.pages (
 id uuid primary key default gen_random_uuid(),
 title text not null,
 slug text not null unique,
 draft jsonb not null default '{}'::jsonb,
 published jsonb not null default '{}'::jsonb,
 seo_title text not null default '',
 meta_description text not null default '',
 published_at timestamptz,
 updated_at timestamptz not null default now()
);
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.site_content enable row level security;
alter table public.site_settings enable row level security;
alter table public.media_assets enable row level security;
alter table public.pages enable row level security;

create policy "public read published categories" on public.categories for select to anon, authenticated using (published = true or public.is_admin());
create policy "admins manage categories" on public.categories for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "public read published products" on public.products for select to anon, authenticated using (published = true or public.is_admin());
create policy "admins manage products" on public.products for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "public read published content" on public.site_content for select to anon, authenticated using (true);
create policy "admins manage content" on public.site_content for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "public read settings" on public.site_settings for select to anon, authenticated using (true);
create policy "admins manage settings" on public.site_settings for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "public read published pages" on public.pages for select to anon, authenticated using (published <> '{}'::jsonb or public.is_admin());
create policy "admins manage pages" on public.pages for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admins manage media metadata" on public.media_assets for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- Storage bucket: crear desde Dashboard o ejecutar en SQL editor.
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('nukleo-media','nukleo-media',true,10485760,array['image/jpeg','image/png','image/webp','image/avif'])
on conflict (id) do nothing;
create policy "Public read NUKLEO media" on storage.objects for select using (bucket_id = 'nukleo-media');
create policy "Admins upload NUKLEO media" on storage.objects for insert to authenticated
 with check (bucket_id = 'nukleo-media' and public.is_admin());
create policy "Admins update NUKLEO media" on storage.objects for update to authenticated
 using (bucket_id = 'nukleo-media' and public.is_admin()) with check (bucket_id = 'nukleo-media' and public.is_admin());
create policy "Admins delete NUKLEO media" on storage.objects for delete to authenticated
 using (bucket_id = 'nukleo-media' and public.is_admin());

-- IMPORTANTE: tras crear el primer usuario desde Supabase Auth, añade SU UUID manualmente:
-- insert into public.admin_users(user_id) values ('UUID_REAL_DEL_USUARIO');
-- No habilitar el registro público de usuarios. Desactívalo en Authentication > Settings.
