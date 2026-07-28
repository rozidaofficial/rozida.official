# Rozida.Official

Website statis untuk order pelanggan, admin dashboard, galeri, agenda, testimoni, invoice, dan pengaturan WhatsApp.

## Persiapan Supabase

1. Buka proyek Supabase Anda.
2. Salin URL project dan anon key dari Settings > API.
3. Buka SQL Editor dan jalankan semua isi file [supabase-setup.sql](supabase-setup.sql).
4. Pastikan bucket storage bernama `gallery` sudah dibuat dan bersifat publik.
5. Buka Auth > Users dan buat akun admin terlebih dahulu.

## Menjalankan lokal

Buka file [index.html](index.html) dan [admin.html](admin.html) dari browser, atau gunakan server statis sederhana.

## Fitur yang sudah terhubung

- Form order pelanggan -> tersimpan ke Supabase dan juga fallback ke localStorage
- Admin dashboard -> membaca pesanan dari Supabase + localStorage
- Pengaturan admin -> menyimpan nomor WhatsApp dan link sosial
- Upload galeri -> tampil ke halaman depan dan admin
- Login admin -> memakai Supabase Auth

## Catatan penting

- Jika Supabase belum siap, halaman tetap bisa bekerja memakai data lokal di browser.
- Untuk pengalaman penuh, pastikan SQL setup dan bucket storage sudah aktif.
