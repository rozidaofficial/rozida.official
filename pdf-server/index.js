require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');
const puppeteer = require('puppeteer');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in env');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' }));

async function renderInvoiceHtml(inv){
  // basic HTML template for invoice; customize as needed
  return `
  <html><head><meta charset="utf-8"><title>Invoice ${inv.id}</title>
  <style>body{font-family:Arial,Helvetica,sans-serif;color:#2B241D} .wrap{padding:28px;max-width:720px;margin:0 auto} table{width:100%;border-collapse:collapse} td{padding:8px 0}</style>
  </head><body>
  <div class="wrap">
    <h1>Rozida.Official</h1>
    <h3>Invoice</h3>
    <p><strong>Invoice ID:</strong> ${inv.id}</p>
    <table>
      <tr><td><strong>Nama</strong></td><td>${inv.customer_name}</td></tr>
      <tr><td><strong>WhatsApp</strong></td><td>${inv.phone}</td></tr>
      <tr><td><strong>Rincian</strong></td><td>${inv.description || ''}</td></tr>
      <tr><td><strong>Jumlah</strong></td><td>Rp ${Number(inv.amount||0).toLocaleString('id-ID')}</td></tr>
      <tr><td><strong>Status</strong></td><td>${inv.status}</td></tr>
    </table>
    <p>Terima kasih telah memesan di Rozida.Official 🌷</p>
  </div></body></html>`;
}

app.post('/generate-invoice', async (req, res) => {
  try {
    const { invoiceId } = req.body;
    if (!invoiceId) return res.status(400).json({ error: 'invoiceId required' });

    // fetch invoice using service role
    const { data: inv, error: invErr } = await supabase.from('invoices').select('*').eq('id', invoiceId).single();
    if (invErr) return res.status(500).json({ error: invErr.message });

    const html = await renderInvoiceHtml(inv);

    const browser = await puppeteer.launch({ args: ['--no-sandbox','--disable-setuid-sandbox'] });
    const page = await browser.newPage();
    await page.setContent(html, { waitUntil: 'networkidle0' });
    const pdfBuffer = await page.pdf({ format: 'A4', printBackground: true });
    await browser.close();

    const path = `invoices/${Date.now()}_${invoiceId}.pdf`;
    const { error: upErr } = await supabase.storage.from('invoices').upload(path, pdfBuffer, { contentType: 'application/pdf', upsert: false });
    if (upErr) return res.status(500).json({ error: upErr.message });

    const { data: pub } = supabase.storage.from('invoices').getPublicUrl(path);
    const publicUrl = pub?.publicUrl || (pub && pub.publicUrl) || null;

    await supabase.from('invoices').update({ pdf_url: publicUrl, storage_path: path }).eq('id', invoiceId);

    return res.json({ url: publicUrl, path });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: err.message || String(err) });
  }
});

const PORT = process.env.PORT || 3333;
app.listen(PORT, () => console.log('PDF server running on', PORT));
