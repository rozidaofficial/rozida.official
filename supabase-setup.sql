-- =========================================================
-- ROZIDA.OFFICIAL — Setup Database Supabase
-- Jalankan seluruh isi file ini di: Supabase Dashboard
-- > SQL Editor > New query > paste semua > Run
-- =========================================================

-- 1. Tabel utama untuk menyimpan pesanan
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  customer_name text not null,
  phone text not null,
  address text,

  service_type text not null,       -- Buket, Mahar, Seserahan, Paket Prewedding, Paket Sinoman, Hias Mobil, Sewa + Hias Mobil
  package_detail text,              -- detail permintaan: warna, ukuran, tema, jumlah, dll
  event_date date,
  budget_range text,
  notes text,

  status text not null default 'Baru',  -- Baru, Diproses, Siap, Selesai, Dibatalkan
  price numeric,
  admin_notes text
);

-- 2. Trigger otomatis update kolom updated_at
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_orders_updated_at on public.orders;
create trigger trg_orders_updated_at
before update on public.orders
for each row execute function public.set_updated_at();

-- 3. Aktifkan Row Level Security
alter table public.orders enable row level security;

-- 4. Kebijakan akses:
--    - Siapa saja (pelanggan, tanpa login) BOLEH membuat pesanan baru
--    - Hanya admin yang login (authenticated) BOLEH membaca, mengubah, menghapus
drop policy if exists "public can insert orders" on public.orders;
create policy "public can insert orders"
on public.orders for insert
to anon
with check (true);

drop policy if exists "admin can read orders" on public.orders;
create policy "admin can read orders"
on public.orders for select
to authenticated
using (true);

drop policy if exists "admin can update orders" on public.orders;
create policy "admin can update orders"
on public.orders for update
to authenticated
using (true)
with check (true);

drop policy if exists "admin can delete orders" on public.orders;
create policy "admin can delete orders"
on public.orders for delete
to authenticated
using (true);

-- =========================================================
-- SELESAI. Langkah selanjutnya (lihat PANDUAN-SETUP.md):
-- 1. Buat akun admin di Authentication > Users > Add user
-- 2. Salin Project URL & anon public key dari Settings > API
-- 3. Tempel ke index.html dan admin.html (bagian SUPABASE_URL / SUPABASE_ANON_KEY)
-- =========================================================

-- =========================================================
-- 5. Tabel pengaturan (untuk nomor WhatsApp admin yang bisa
--    diubah langsung dari halaman admin, tanpa edit kode)
-- =========================================================
create table if not exists public.settings (
  key text primary key,
  value text
);

alter table public.settings enable row level security;

drop policy if exists "public can read settings" on public.settings;
create policy "public can read settings"
on public.settings for select
to anon, authenticated
using (true);

drop policy if exists "admin can update settings" on public.settings;
create policy "admin can update settings"
on public.settings for update
to authenticated
using (true)
with check (true);

drop policy if exists "admin can insert settings" on public.settings;
create policy "admin can insert settings"
on public.settings for insert
to authenticated
with check (true);

-- Isi nilai awal nomor WhatsApp admin (format 62xxxxxxxxxx, tanpa +/spasi/strip)
insert into public.settings (key, value)
values ('admin_whatsapp', '62882006550939')
on conflict (key) do nothing;
-- =========================================================
