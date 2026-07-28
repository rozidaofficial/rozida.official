-- =========================================================
-- Rozida.Official Supabase setup
-- Jalankan semua perintah ini di SQL Editor Supabase.
-- =========================================================

create extension if not exists pgcrypto;

-- 1) Tabel pesanan pelanggan
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  customer_name text not null,
  phone text not null,
  address text,
  service_type text not null,
  package_detail text,
  event_date date,
  notes text,
  status text not null default 'Baru' check (status in ('Baru','Diproses','Siap','Selesai','Dibatalkan')),
  admin_notes text,
  price numeric(12,2) default 0,
  payment_status text default 'Belum Bayar' check (payment_status in ('Belum Bayar','DP','Lunas'))
);

alter table public.orders enable row level security;

create policy "Public can insert orders"
  on public.orders for insert
  to anon
  with check (true);

create policy "Authenticated users can read orders"
  on public.orders for select
  to authenticated
  using (true);

create policy "Authenticated users can update orders"
  on public.orders for update
  to authenticated
  using (true)
  with check (true);

create policy "Authenticated users can delete orders"
  on public.orders for delete
  to authenticated
  using (true);

-- 2) Tabel pengaturan (nomor WA admin, link sosial, dll)
create table if not exists public.settings (
  key text primary key,
  value text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.settings enable row level security;

create policy "Settings public read"
  on public.settings for select
  to anon
  using (true);

create policy "Settings authenticated write"
  on public.settings for all
  to authenticated
  using (true)
  with check (true);

insert into public.settings (key, value)
values ('admin_whatsapp','62882006550939')
on conflict (key) do nothing;

-- 3) Agenda / kalender
create table if not exists public.agenda (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  event_date date not null,
  title text not null,
  note text
);

alter table public.agenda enable row level security;

create policy "Agenda public read"
  on public.agenda for select
  to anon
  using (true);

create policy "Agenda authenticated write"
  on public.agenda for all
  to authenticated
  using (true)
  with check (true);

-- 4) Testimoni
create table if not exists public.testimonials (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  customer_name text not null,
  message text not null,
  rating int not null default 5 check (rating between 1 and 5),
  published boolean not null default false
);

alter table public.testimonials enable row level security;

create policy "Testimonials public read"
  on public.testimonials for select
  to anon
  using (true);

create policy "Testimonials authenticated write"
  on public.testimonials for all
  to authenticated
  using (true)
  with check (true);

-- 5) Galeri
create table if not exists public.gallery (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  image_url text not null,
  caption text,
  storage_path text
);

alter table public.gallery enable row level security;

create policy "Gallery public read"
  on public.gallery for select
  to anon
  using (true);

create policy "Gallery authenticated write"
  on public.gallery for all
  to authenticated
  using (true)
  with check (true);

-- 6) Invoice (opsional, agar fitur invoice admin tetap jalan)
create table if not exists public.invoices (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  order_id uuid,
  customer_name text not null,
  phone text not null,
  description text,
  amount numeric(12,2) default 0,
  status text default 'draft' check (status in ('draft','sent','paid','cancelled')),
  due_date date
);

alter table public.invoices enable row level security;

create policy "Invoices authenticated read"
  on public.invoices for select
  to authenticated
  using (true);

create policy "Invoices authenticated write"
  on public.invoices for all
  to authenticated
  using (true)
  with check (true);

-- 7) Finance (opsional, agar fitur keuangan admin tetap jalan)
create table if not exists public.finance (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  date date not null,
  description text not null,
  amount numeric(12,2) not null default 0,
  type text not null default 'income' check (type in ('income','expense')),
  invoice_id uuid,
  source text default 'manual'
);

alter table public.finance enable row level security;

create policy "Finance authenticated read"
  on public.finance for select
  to authenticated
  using (true);

create policy "Finance authenticated write"
  on public.finance for all
  to authenticated
  using (true)
  with check (true);

-- 8) Bucket storage untuk galeri
insert into storage.buckets (id, name, public)
values ('gallery', 'gallery', true)
on conflict (id) do update set public = true;

-- 9) Policies storage untuk galeri
create policy "Gallery bucket public read"
  on storage.objects for select
  to public
  using (bucket_id = 'gallery');

create policy "Gallery bucket authenticated insert"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'gallery');

create policy "Gallery bucket authenticated update"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'gallery')
  with check (bucket_id = 'gallery');

create policy "Gallery bucket authenticated delete"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'gallery');
