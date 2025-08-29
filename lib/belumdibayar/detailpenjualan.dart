import 'package:flutter/material.dart';
import 'package:hayami_app/Pembelian/tambahbelumdibayarpembelian.dart';
import 'package:hayami_app/belumdibayar/tambahso.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DetailPenjualan extends StatefulWidget {
  final Map<String, dynamic> invoice;

  const DetailPenjualan({super.key, required this.invoice});

  @override
  State<DetailPenjualan> createState() => _DetailPenjualanState();
}

class _DetailPenjualanState extends State<DetailPenjualan> {
  late List<dynamic> barang;
  late int totalInvoice;
  late int sisaTagihan;

  @override
  void initState() {
    super.initState();
    final invoice = widget.invoice;

    barang = invoice['produk'] ?? [];

    totalInvoice = _parseToInt(invoice['net_total']);
    sisaTagihan = _parseToInt(invoice['hutang']);
  }

  int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  String formatRupiah(dynamic number) {
    final double value = number is String
        ? double.tryParse(number) ?? 0
        : number is int
            ? number.toDouble()
            : number ?? 0;
    return NumberFormat.currency(locale: "id_ID", symbol: "Rp ", decimalDigits: 0)
        .format(value);
  }

  Future<void> _printPdf() async {
    final pdf = pw.Document();
    final invoice = widget.invoice;
    final customer = invoice['customer'] ?? {};
    final contactName = customer['nama_customer'] ?? 'Tidak diketahui';
    final alamat = customer['alamat'] ?? 'Tidak diketahui';
    final hp = customer['hp'] ?? '-';
    final invoiceNumber = invoice['id_so1'] ?? '-';
    final date = invoice['tgl_so'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Text('Id Transaksi: $invoiceNumber',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Customer: $contactName'),
          pw.Text('HP: $hp'),
          pw.Text('Alamat: $alamat'),
          pw.Text('Tanggal: $date'),
          pw.SizedBox(height: 20),
          pw.Text('Barang Dibeli:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Table.fromTextArray(
            headers: ['Nama', 'Qty', 'Harga per Item', 'Total'],
            data: barang.map((item) {
              final nama = item['nama_produk'] ?? 'Tidak Diketahui';
              final qty = item['qty'].toString();
              final harga = formatRupiah(item['harga']);
              final total = formatRupiah(item['total']);
              return [nama, qty, harga, total];
            }).toList(),
          ),
          pw.SizedBox(height: 20),
          if ((_parseToInt(invoice['disc_nominal']) > 0) || (_parseToInt(invoice['disc_persen']) > 0))
if ((_parseToInt(invoice['disc_nominal']) > 0) || (_parseToInt(invoice['disc_persen']) > 0) || (_parseToInt(invoice['ppn_persen']) > 0) || (_parseToInt(invoice['ongkir']) > 0))
  pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      if (_parseToInt(invoice['disc_nominal']) > 0)
        pw.Text('Diskon (Rp): ${formatRupiah(invoice['disc_nominal'])}'),
      if (_parseToInt(invoice['disc_persen']) > 0)
        pw.Text('Diskon (%): ${invoice['disc_persen']}%'),
      if (_parseToInt(invoice['ppn_persen']) > 0)
        pw.Text('PPN (%): ${invoice['ppn_persen']}%'),
      if (_parseToInt(invoice['ongkir']) > 0)
        pw.Text('Ongkir: ${formatRupiah(invoice['ongkir'])}'),
      pw.SizedBox(height: 10),
    ],
  ),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Semua:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(formatRupiah(totalInvoice), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Sisa Tagihan:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
              pw.Text(formatRupiah(sisaTagihan), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'belum dibayar':
        return Colors.black;
      case 'dibayar sebagian':
        return Colors.orange;
      case 'lunas':
        return Colors.green;
      case 'void':
        return Colors.grey;
      case 'jatuh tempo':
        return Colors.black;
      case 'retur':
        return Colors.deepOrange;
      case 'transaksi berulang':
        return Colors.blue;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;
    final customer = invoice['customer'] ?? {};
    final contactName = customer['nama_customer'] ?? 'Tidak diketahui';
    final alamat = customer['alamat'] ?? 'Tidak diketahui';
    final hp = customer['hp'] ?? '-';
    final invoiceNumber = invoice['id_so1'] ?? '-';
    final date = invoice['tgl_so'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    final status = invoice['status'] ?? 'belum dibayar';
    final statusColor = _getStatusColor(status);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SalesOrderPage()),
        );
        return false;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: AppBar(
              title: const Text('Tagihan', style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ),
        body: Column(
          children: [
            _buildHeader(invoiceNumber, contactName, alamat, hp, date, status, statusColor),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Barang Dibeli", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: barang.isEmpty
                  ? const Center(child: Text("Tidak ada barang untuk invoice ini."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: barang.length,
                      itemBuilder: (context, index) {
                        final item = barang[index];
                        final harga = double.tryParse(item['harga'].toString()) ?? 0;
                        final total = double.tryParse(item['total'].toString()) ?? 0;
                        final qty = item['qty'] ?? 0;

                        return Card(
                          child: ListTile(
                            title: Text(item['nama_produk'] ?? 'Tidak Diketahui'),
                            subtitle: Text("$qty pcs x ${formatRupiah(harga)}"),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                formatRupiah(total),
                                style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (barang.isNotEmpty)
              Column(
                children: [
if (
  (_parseToInt(widget.invoice['disc_nominal']) > 0) ||
  (_parseToInt(widget.invoice['disc_persen']) > 0) ||
  (_parseToInt(widget.invoice['ppn_persen']) > 0) ||
  (_parseToInt(widget.invoice['ongkir']) > 0)
)
Container(
  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  width: double.infinity,
  color: Colors.grey.shade100,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_parseToInt(widget.invoice['disc_nominal']) > 0)
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                children: [
                  const TextSpan(text: 'Diskon (Rp): '),
                  TextSpan(text: formatRupiah(widget.invoice['disc_nominal']), style: const TextStyle(color: Colors.green)),
                ],
              ),
            ),
          if (_parseToInt(widget.invoice['disc_persen']) > 0)
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                children: [
                  const TextSpan(text: 'Diskon (%): '),
                  TextSpan(text: "${widget.invoice['disc_persen']}%", style: const TextStyle(color: Colors.green)),
                ],
              ),
            ),
        ],
      ),
      const SizedBox(height: 6),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_parseToInt(widget.invoice['ppn_persen']) > 0)
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                children: [
                  const TextSpan(text: 'PPN (%): '),
                  TextSpan(text: "${widget.invoice['ppn_persen']}%", style: const TextStyle(color: Colors.orange)),
                ],
              ),
            ),
          if (_parseToInt(widget.invoice['ongkir']) > 0)
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                children: [
                  const TextSpan(text: 'Ongkir: '),
                  TextSpan(text: formatRupiah(widget.invoice['ongkir']), style: const TextStyle(color: Colors.blue)),
                ],
              ),
            ),
        ],
      ),
    ],
  ),
),
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Semua", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(formatRupiah(totalInvoice), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Sisa Tagihan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                        Text(formatRupiah(sisaTagihan), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _printPdf,
                          icon: const Icon(Icons.print),
                          label: const Text("Print", style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String invoiceNumber, String contactName, String alamat, String hp, String date, String status, Color statusColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(invoiceNumber, style: const TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 16),
          Text(contactName, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(hp, style: const TextStyle(fontSize: 13, color: Colors.white)),
          const SizedBox(height: 2),
          Text(alamat, style: const TextStyle(fontSize: 13, color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(date, style: const TextStyle(color: Colors.white)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
