# Rozida PDF Generation Server

Server kecil ini membuat PDF invoice secara server-side menggunakan Puppeteer, mengunggahnya ke Supabase Storage, dan memperbarui baris `invoices` dengan `pdf_url` dan `storage_path`.

Variabel lingkungan yang wajib diisi:

- `SUPABASE_URL` — URL proyek Supabase Anda (mis. https://xyz.supabase.co)
- `SUPABASE_SERVICE_ROLE_KEY` — Service Role Key Supabase (rahasia, jangan bagikan)
- `PORT` — (opsional) port server, default `3333`

Menjalankan secara lokal:

```bash
cd pdf-server
npm install
SUPABASE_URL="https://<project>.supabase.co" SUPABASE_SERVICE_ROLE_KEY="<service-role-key>" npm start
```

Contoh panggilan dari `admin.html` (AJAX):

```bash
curl -X POST https://pdf-server-anda.example.com/generate-invoice \
  -H "Content-Type: application/json" \
  -d '{"invoiceId":"<INVOICE_UUID>"}'
```

Response sukses:

```json
{ "url": "https://.../invoices/123.pdf", "path": "invoices/123.pdf" }
```

Langkah deployment cepat dengan Docker:

```bash
cd pdf-server
docker build -t rozida-pdf-server .
docker run -e SUPABASE_URL="https://<project>.supabase.co" \
  -e SUPABASE_SERVICE_ROLE_KEY="<service-role-key>" \
  -p 3333:3333 rozida-pdf-server
```

Catatan penting:
- Gunakan `SUPABASE_SERVICE_ROLE_KEY` hanya pada server aman (tidak di frontend). Kunci ini memiliki hak penuh terhadap database dan storage.
- Jika host Docker Anda (mis. beberapa PaaS) memerlukan opsi tambahan untuk menjalankan Puppeteer (dependensi sistem), gunakan image yang sudah menyiapkan dependensi Chrome/Chromium.
- Pastikan bucket `invoices` sudah dibuat dan bersifat publik (atau gunakan metode private + signed URL jika diperlukan).

Integrasi di frontend (`admin.html`):
- Set `PDF_SERVICE_URL` ke alamat server Anda. Skrip frontend akan memanggil endpoint `/generate-invoice` untuk menghasilkan PDF sebelum mengirim WA.
