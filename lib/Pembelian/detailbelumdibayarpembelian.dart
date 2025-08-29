import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailBelumDibayarPembelian extends StatefulWidget {
  final Map<String, dynamic> invoice;

  const DetailBelumDibayarPembelian({super.key, required this.invoice});

  @override
  State<DetailBelumDibayarPembelian> createState() =>
      _DetailBelumDibayarPembelianState();
}

class _DetailBelumDibayarPembelianState
    extends State<DetailBelumDibayarPembelian> {
  List<dynamic> barang = [];
  int totalInvoice = 0;
  int sisaTagihan = 0;
  bool isLoading = true;
  String? idUser;

  @override
  void initState() {
    super.initState();
    fetchDetail();

    _loadIdUser();
  }

  Future<void> fetchDetail() async {
    final idPo1 = widget.invoice['id_po1'] ?? widget.invoice['id'];
    final url =
        'http://192.168.1.20/nindo/stockin%20-%20Copy.php?action=detail&id_po1=$idPo1';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);

        if (result['status'] == 'success' && result['data'].isNotEmpty) {
          final data = result['data'][0];

          setState(() {
            barang = data['produk'] ?? [];
            totalInvoice = (data['total'] as num?)?.toInt() ?? 0;
            sisaTagihan = (data['sisa_hutang'] as num?)?.toInt() ?? 0;
            widget.invoice['disc_nominal'] = data['disc_nominal'];
            widget.invoice['disc_persen'] = data['disc_persen'];
          });
        }
      } else {
        throw Exception('Gagal mengambil detail PO');
      }
    } catch (e) {
      print("Error fetchDetail: $e");
      setState(() {
        barang = [];
        totalInvoice = 0;
        sisaTagihan = 0;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadIdUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idUser = prefs.getString('id_user'); // ambil id_user dari shared pref
    });
  }

  Future<void> _printPdf() async {
    final pdf = pw.Document();

    final invoice = widget.invoice;
    final contactName = invoice['name'] ?? 'Tidak diketahui';
    final alamat = invoice['alamat'] ?? 'Tidak diketahui';
    final hp = invoice['hp'] ?? '-';
    final invoiceNumber = invoice['invoice'] ?? invoice['id'] ?? '-';
    final date = invoice['date'] ?? '-';

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Text('Id Transaksi: $invoiceNumber',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Supplier: $contactName'),
          pw.Text('HP: $hp'),
          pw.Text('Alamat: $alamat'),
          pw.Text('Tanggal: $date'),
          pw.SizedBox(height: 20),
          pw.Text('Barang Dibeli:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Table.fromTextArray(
            headers: ['Nama', 'Qty', 'Harga per Item', 'Total'],
            data: barang.map((item) {
              final nama = item['nama_produk'] ?? 'Tidak Diketahui';
              final qty = item['qty'].toString();
              final harga = formatRupiah(item['price']);
              final total = formatRupiah(item['total_harga']);
              return [nama, qty, harga, total];
            }).toList(),
          ),
          pw.SizedBox(height: 20),
          if ((invoice['disc_nominal'] ?? 0) > 0 ||
              (invoice['disc_persen'] ?? 0) > 0)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if ((invoice['disc_nominal'] ?? 0) > 0)
                  pw.Text(
                      'Diskon (Rp): ${formatRupiah(invoice['disc_nominal'])}'),
                if ((invoice['disc_persen'] ?? 0) > 0)
                  pw.Text('Diskon (%): ${invoice['disc_persen']}%'),
                pw.SizedBox(height: 10),
              ],
            ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Semua:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(formatRupiah(totalInvoice),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Sisa Tagihan:',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
              pw.Text(formatRupiah(sisaTagihan),
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

Future<void> _updatePO(int nominal, String keterangan) async {
  final idPo1 = widget.invoice['id_po1'] ?? widget.invoice['id'];
  final prefs = await SharedPreferences.getInstance();
  final idUser = prefs.getString('id_user') ?? '';


  final url = Uri.parse("http://192.168.1.20/nindo/tambahstock.php?action=update_po");

  try {
final response = await http.post(
  url,
  headers: {"Content-Type": "application/json"},
  body: jsonEncode({
    "id_po": idPo1,
    "nominal": nominal,
    "ket": keterangan,
    "id_user": idUser,
  }),
);

print('Response status: ${response.statusCode}');
print('Response body: ${response.body}');

final data = jsonDecode(response.body);


    if (response.statusCode == 200 && data['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran berhasil disimpan.'),
          duration: Duration(milliseconds: 300),
        ),
      );

      await fetchDetail(); // untuk refresh data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['error'] ?? 'Gagal memperbarui PO')),
      );
    }
  } catch (e) {
    print("Error update_po: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terjadi kesalahan jaringan.')),
    );
  }
}

void _showBayarDialog() {
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();
  final formatter = NumberFormat("#,###", "id_ID");

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Pembayaran',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.indigo,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Sisa Tagihan tampil cantik
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Sisa Tagihan: Rp ${formatter.format(sisaTagihan)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),

                // ✅ Nominal Pembayaran
                TextField(
                  controller: nominalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nominal Pembayaran',
                    hintText: 'Masukkan nominal',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    String newValue = value.replaceAll('.', '');
                    int number = int.tryParse(newValue) ?? 0;

                    if (number > sisaTagihan) {
                      number = sisaTagihan;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Nominal tidak boleh lebih dari sisa tagihan'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }

                    String formatted = formatter.format(number);
                    nominalController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // ✅ Keterangan
                TextField(
                  controller: keteranganController,
                  decoration: const InputDecoration(
                    labelText: 'Keterangan',
                    hintText: 'Contoh: Pembayaran sebagian',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text(
              'Bayar',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              String nominalStr = nominalController.text.replaceAll('.', '');
              int nominal = int.tryParse(nominalStr) ?? 0;

              if (nominal <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nominal harus lebih dari 0')),
                );
                return;
              }

              String keterangan = keteranganController.text;

              Navigator.of(context).pop();
              _updatePO(nominal, keterangan);
            },
          ),
        ],
      );
    },
  );
}

  String formatRupiah(dynamic number) {
    final double value = number is String
        ? double.tryParse(number) ?? 0
        : number is int
            ? number.toDouble()
            : number ?? 0;
    return NumberFormat.currency(
            locale: "id_ID", symbol: "Rp ", decimalDigits: 0)
        .format(value);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'belum dibayar':
        return Colors.pink;
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
    final contactName = invoice['name'] ?? 'Tidak diketahui';
    final alamat = invoice['alamat'] ?? 'Tidak diketahui';
    final hp = invoice['hp'] ?? '-';
    final invoiceNumber = invoice['invoice'] ?? invoice['id'] ?? '-';
    final date = invoice['date'] ?? '-';
    final dueDate = invoice['due'] ?? '-';
    final status = invoice['status'] ?? 'belum dibayar';
    final statusColor = _getStatusColor(status);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
              title: const Text(
                'Tagihan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildHeader(invoiceNumber, contactName, alamat, hp, date,
                      dueDate, status, statusColor),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Barang Dibeli",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    child: barang.isEmpty
                        ? const Center(
                            child: Text("Tidak ada barang untuk invoice ini."))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: barang.length,
                            itemBuilder: (context, index) {
                              final item = barang[index];
                              final harga =
                                  double.tryParse(item['price'].toString()) ??
                                      0;
                              final total = double.tryParse(
                                      item['total_harga'].toString()) ??
                                  0;
                              final qty = item['qty'] ?? 0;

                              return Card(
                                child: ListTile(
                                  title: Text(
                                      item['nama_produk'] ?? 'Tidak Diketahui'),
                                  subtitle:
                                      Text("$qty pcs x ${formatRupiah(harga)}"),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      formatRupiah(total),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
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
                        if ((widget.invoice['disc_nominal'] ?? 0) > 0 ||
                            (widget.invoice['disc_persen'] ?? 0) > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            width: double.infinity,
                            color: Colors.grey.shade100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if ((widget.invoice['disc_nominal'] ?? 0) > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 24),
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87),
                                        children: [
                                          const TextSpan(text: 'Diskon (Rp): '),
                                          TextSpan(
                                            text: formatRupiah(widget
                                                    .invoice['disc_nominal'] ??
                                                0),
                                            style: const TextStyle(
                                                color: Colors.green),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if ((widget.invoice['disc_persen'] ?? 0) > 0)
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87),
                                      children: [
                                        const TextSpan(text: 'Diskon (%): '),
                                        TextSpan(
                                          text:
                                              "${widget.invoice['disc_persen']}%",
                                          style: const TextStyle(
                                              color: Colors.green),
                                        ),
                                      ],
                                    ),
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
                              const Text("Total Semua",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text(formatRupiah(totalInvoice),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
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
                              const Text("Sisa Tagihan",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              Text(formatRupiah(sisaTagihan),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red)),
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
                              if (idUser == "sa") ...[
                                ElevatedButton.icon(
                                  onPressed: _showBayarDialog,
                                  icon: const Icon(Icons.payment),
                                  label: const Text(
                                    "Bayar",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              ElevatedButton.icon(
                                onPressed: _printPdf,
                                icon: const Icon(Icons.print),
                                label: const Text(
                                  "Print",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
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

  Widget _buildHeader(
      String invoiceNumber,
      String contactName,
      String alamat,
      String hp,
      String date,
      String dueDate,
      String status,
      Color statusColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(invoiceNumber,
              style: const TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 16),
          Text(contactName,
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(hp, style: const TextStyle(fontSize: 13, color: Colors.white)),
          const SizedBox(height: 2),
          Text(alamat,
              style: const TextStyle(fontSize: 13, color: Colors.white)),
          // const SizedBox(height: 16),
          // Container(
          //   padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(30),
          //   ),
          //   child: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Container(
          //         width: 25,
          //         height: 25,
          //         decoration: BoxDecoration(
          //           color: statusColor.withOpacity(0.6),
          //           shape: BoxShape.circle,
          //         ),
          //       ),
          //       const SizedBox(width: 8),
          //       Text(status,
          //           style: const TextStyle(
          //               color: Colors.black, fontWeight: FontWeight.w500)),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(date, style: const TextStyle(color: Colors.white)),
                ],
              ),
              // Row(
              //   children: [
              //     const Icon(Icons.access_time, size: 16, color: Colors.white),
              //     const SizedBox(width: 6),
              //     Text(dueDate, style: const TextStyle(color: Colors.white)),
              //   ],
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
