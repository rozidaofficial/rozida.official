# Panduan Setup — Rozida.Official

Ada 3 file:
- **index.html** → website pelanggan (form pesan buket, mahar, seserahan, paket prewedding, paket sinoman, hias/sewa mobil)
- **admin.html** → dashboard admin untuk melihat & mengelola semua pesanan
- **supabase-setup.sql** → skrip database

Karena datanya perlu tersambung dari HP pelanggan ke laptop admin, kedua halaman ini pakai **Supabase** (database gratis) sebagai penghubung. Ikuti langkah berikut sekali saja di awal.

## 1. Buat akun & proyek Supabase
1. Buka https://supabase.com → **Start your project** → daftar/login (bisa pakai akun Google).
2. Klik **New project**. Isi nama project (misal `rozida-official`), buat password database (simpan baik-baik), pilih region terdekat (Singapore).
3. Tunggu sampai project selesai dibuat (±1-2 menit).

## 2. Jalankan skrip database
1. Di dashboard project, buka menu **SQL Editor** (ikon di sidebar kiri).
2. Klik **New query**.
3. Buka file `supabase-setup.sql`, salin semua isinya, tempel ke editor.
4. Klik **Run**. Kalau berhasil akan muncul "Success. No rows returned".

## 3. Buat akun admin (untuk login di admin.html)
1. Di sidebar, buka **Authentication** → **Users**.
2. Klik **Add user** → **Create new user**.
3. Isi email dan password untuk admin (misal `admin@rozidaofficial.com`). Centang **Auto Confirm User**.
4. Klik **Create user**.
5. Ini email & password yang dipakai untuk login di halaman `admin.html`. Bisa buat lebih dari satu user kalau ada lebih dari satu admin.

## 4. Ambil kunci koneksi (URL & anon key)
1. Di sidebar, buka **Settings** (ikon gerigi) → **API**.
2. Salin nilai **Project URL** (bentuknya `https://xxxxxxxx.supabase.co`).
3. Salin nilai **anon public key** (kunci panjang di bagian "Project API keys").

## 5. Tempel ke kedua file HTML
Buka `index.html` dengan text editor (Notepad, VS Code, dll), cari bagian ini di dekat akhir file:

```js
const SUPABASE_URL = "https://YOUR-PROJECT.supabase.co";
const SUPABASE_ANON_KEY = "YOUR-ANON-PUBLIC-KEY";
```

Ganti dengan URL & key yang tadi disalin. Lakukan hal yang sama di `admin.html` (persis di bagian yang sama).

Nomor WhatsApp admin **tidak perlu diedit lewat kode lagi**. Nomor awal sudah diisi otomatis lewat `supabase-setup.sql` (0882-0065-50939). Untuk menggantinya kapan saja, login ke `admin.html` → klik tombol **Pengaturan** di pojok kanan atas → masukkan nomor baru → **Simpan Nomor**. Perubahan langsung berlaku untuk form pelanggan tanpa perlu upload ulang file.

## 6. Upload / hosting
File-file ini murni HTML, tidak butuh server khusus. Beberapa opsi termudah:
- **Netlify Drop** (https://app.netlify.com/drop): tinggal drag & drop folder ini, langsung online, gratis.
- **Vercel**: import folder sebagai static project.
- **Hosting cPanel biasa**: upload semua file via File Manager / FTP ke `public_html`.

Setelah online, alamat pelanggan misalnya `namadomain.com/index.html` (atau `namadomain.com` kalau di-rename jadi `index.html` di root), dan admin buka `namadomain.com/admin.html`.

## 7. Coba alur lengkap
1. Buka `index.html`, isi form, kirim pesanan percobaan.
2. Buka `admin.html`, login pakai akun admin dari langkah 3.
3. Pesanan percobaan tadi harus langsung muncul (real-time, tanpa refresh).
4. Klik baris pesanan → ubah status/harga → **Simpan Perubahan**.

## Catatan keamanan
- Pelanggan **hanya bisa mengirim** pesanan baru, tidak bisa melihat/mengubah data pesanan orang lain — ini diatur lewat *Row Level Security* di skrip SQL.
- Hanya akun yang berhasil login (dibuat lewat langkah 3) yang bisa melihat, mengubah, atau menghapus data di admin.
- Jangan bagikan password admin. Kalau ada admin yang keluar/resign, hapus usernya di Authentication → Users.
