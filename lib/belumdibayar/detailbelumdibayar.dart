import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Detailbelumdibayar extends StatefulWidget {
  final Map<String, dynamic> invoice;

  const Detailbelumdibayar({super.key, required this.invoice});

  @override
  State<Detailbelumdibayar> createState() => _DetailbelumdibayarState();
}

class _DetailbelumdibayarState extends State<Detailbelumdibayar> {
  List<dynamic> barang = [];
  int totalInvoice = 0;
  int sisaTagihan = 0;
  bool isLoading = true;

  double discPersen = 0;
  double discNominal = 0; // ✅ Tambahan
  double ppnPersen = 0;
  int ongkir = 0;

  // ✅ Tambahan variabel untuk telepon
  String telepon = '-';
  String? idUser;

  @override
  void initState() {
    super.initState();
    telepon =
        widget.invoice['telepon'] ?? '-'; // ✅ Simpan telepon di variabel state
    _loadUser();
    fetchProduct();
  }

  void showPembayaranDialog(BuildContext context, int sisaTagihan) {
    final TextEditingController nominalController = TextEditingController();
    final TextEditingController keteranganController = TextEditingController();

    final formatter = NumberFormat("#,###", "id_ID");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Pembayaran",
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
                  // ✅ Info sisa tagihan
                  Container(
                    padding: const EdgeInsets.all(12),
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
                  const SizedBox(height: 20),

                  // ✅ Input nominal dengan format rupiah
                  TextField(
                    controller: nominalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Nominal Dibayar",
                      prefixText: "Rp ",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      String newValue =
                          value.replaceAll(".", "").replaceAll(",", "");

                      if (newValue.isEmpty) {
                        setState(() {
                          nominalController.text = "";
                        });
                        return;
                      }

                      int number = int.parse(newValue);

                      // ✅ Batasi ke sisaTagihan jika melebihi
                      if (number > sisaTagihan) {
                        number = sisaTagihan;
                      }

                      final formatted = formatter.format(number);

                      setState(() {
                        nominalController.text = formatted;
                        nominalController.selection =
                            TextSelection.fromPosition(
                          TextPosition(offset: formatted.length),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // ✅ Input keterangan
                  TextField(
                    controller: keteranganController,
                    decoration: const InputDecoration(
                      labelText: "Keterangan",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text(
                "Bayar",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                final nominalStr = nominalController.text
                    .replaceAll(".", "")
                    .replaceAll(",", "");
                final ket = keteranganController.text.trim();

                if (nominalStr.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nominal harus diisi")),
                  );
                  return;
                }

                final nominalInt = int.parse(nominalStr);

                Navigator.pop(context);

                prosesPembayaran(
                  widget.invoice['id'].toString(),
                  nominalInt,
                  ket,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> prosesPembayaran(
      String idSo1, int nominal, String keterangan) async {
    final prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getString('id_user');

    if (idUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User tidak ditemukan. Silakan login ulang.')),
      );
      return;
    }

    final url = Uri.parse("http://192.168.1.3/nindo/bayar_invoice.php");

    final response = await http.post(url, body: {
      'id_so1': idSo1,
      'nominal': nominal.toString(),
      'keterangan': keterangan,
      'id_user': idUser,
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        fetchProduct(); // reload data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: ${data['message']}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menghubungi server")),
      );
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idUser = prefs.getString('id_user');
    });
  }

  Future<void> fetchProduct() async {
    setState(() {
      isLoading = true;
    });

    final invoiceId = widget.invoice['id']?.toString().trim() ?? '';
    //print('InvoiceId: $invoiceId');

    final url = Uri.parse("http://192.168.1.3/nindo/barang_keluar.php");

    try {
      final response = await http.get(url);
      //print('Raw Response: ${response.body}');

      dynamic data = json.decode(response.body);

      // Jika data berupa String, decode ulang
      if (data is String) {
        data = json.decode(data);
      }

      //print('Decoded data type: ${data.runtimeType}');

      if (data is List) {
        final matchedInvoice = data.firstWhere(
          (item) => item['id_so1'].toString().trim() == invoiceId,
          orElse: () => null,
        );

        //print('Matched Invoice: $matchedInvoice');

        if (matchedInvoice != null) {
          final totalRaw = matchedInvoice['total'];
          final hutangRaw = matchedInvoice['hutang'];

          setState(() {
            totalInvoice = int.tryParse('$totalRaw') ?? 0;
            sisaTagihan = int.tryParse('$hutangRaw') ?? 0;
            ongkir = int.tryParse('${matchedInvoice['ongkir']}') ?? 0;

            discPersen =
                double.tryParse('${matchedInvoice['disc_persen']}') ?? 0;
            discNominal =
                double.tryParse('${matchedInvoice['disc_nominal']}') ??
                    0; // ✅ dari so1
            ppnPersen = double.tryParse('${matchedInvoice['ppn']}') ?? 0;

            // ✅ Mapping produk + hitung total diskon nominal
            barang = (matchedInvoice['produk'] as List<dynamic>).map((produk) {
              return {
                'nama_barang': produk['nm_product'] ?? 'Tidak Diketahui',
                'harga': double.tryParse('${produk['price']}') ?? 0,
                'qty': int.tryParse('${produk['qty']}') ?? 0,
                'total': double.tryParse('${produk['total_harga']}') ?? 0,
                'disc_nominal':
                    double.tryParse('${produk['disc_nominal']}') ?? 0,
                'disc_persen': double.tryParse('${produk['disc_persen']}') ??
                    0, // ✅ ambil disc_persen
              };
            }).toList();

            isLoading = false;
          });
        } else {
          setState(() {
            barang = [];
            totalInvoice = 0;
            sisaTagihan = 0;
            isLoading = false;
          });
        }
      } else {
        //print('Format JSON tidak dikenali');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      //print('Error fetching product: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _printPdf() async {
    final pdf = pw.Document();
    final invoice = widget.invoice;

    // Ambil data customer
    final customer = invoice['customer'] ?? 'Tidak diketahui';
    final alamat = invoice['alamat'] ?? 'Tidak diketahui';
    final hp = invoice['telepon'] ?? '-';
    final invoiceNumber = invoice['invoice'] ?? invoice['id'] ?? '-';
    final date =
        invoice['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Text('Id Transaksi: $invoiceNumber',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Customer: $customer'),
          pw.Text('HP: $hp'),
          pw.Text('Alamat: $alamat'),
          pw.Text('Tanggal: $date'),
          pw.SizedBox(height: 20),

          pw.Text('Barang Dibeli:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Table.fromTextArray(
            headers: ['Nama', 'Qty', 'Harga per Item', 'Total'],
            data: barang.map((item) {
              final nama = item['nama_barang'] ?? 'Tidak Diketahui';
              final qty = item['qty'].toString();
              final harga = formatRupiah(
                (item['harga'] is num)
                    ? item['harga'].toDouble()
                    : double.tryParse('${item['harga']}') ?? 0,
              );
              final total = formatRupiah(
                (item['total'] is num)
                    ? item['total'].toDouble()
                    : double.tryParse('${item['total']}') ?? 0,
              );
              return [nama, qty, harga, total];
            }).toList(),
          ),

          pw.SizedBox(height: 20),

          // Diskon, PPN, dll.
          if (discNominal > 0 || discPersen > 0 || ppnPersen > 0)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (discNominal > 0)
                  pw.Text('Diskon (Rp): ${formatRupiah(discNominal)}'),
                if (discPersen > 0)
                  pw.Text('Diskon (%): ${discPersen.toStringAsFixed(0)}%'),
                if (ppnPersen > 0)
                  pw.Text('PPN (%): ${ppnPersen.toStringAsFixed(0)}%'),
                if (ongkir > 0) pw.Text('Ongkir: ${formatRupiah(ongkir)}'),
                pw.SizedBox(height: 10),
              ],
            ),

          // Total Semua
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Semua:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(formatRupiah(totalInvoice.toDouble()),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 10),

          // Sisa Tagihan
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Sisa Tagihan:',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
              pw.Text(formatRupiah(sisaTagihan.toDouble()),
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
        return Colors.red;
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
    final customer = invoice['customer'] ?? 'Tidak diketahui';
    final alamat = invoice['alamat'] ?? 'Tidak diketahui';
    final invoiceNumber = invoice['invoice'] ?? invoice['id'] ?? '-';
    final date = invoice['date'] ?? '-';
    final dueDate = invoice['due'] ?? '-';
    final status = invoice['status'] ?? 'belum dibayar';
    final statusColor = _getStatusColor(status);

    return Scaffold(
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
            title: const Text('Tagihan',
                style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(invoiceNumber, customer, alamat, telepon, date, dueDate,
              status, statusColor),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Barang Dibeli",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text("Mohon tunggu sebentar, sedang mencari produk"),
                      ],
                    ),
                  )
                : barang.isEmpty
                    ? const Center(
                        child: Text("Tidak ada barang untuk invoice ini."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: barang.length,
                        itemBuilder: (context, index) {
                          final item = barang[index];

                          final harga = (item['harga'] is String)
                              ? double.tryParse(item['harga']) ?? 0
                              : (item['harga'] is num)
                                  ? item['harga'].toDouble()
                                  : 0;

                          final total = (item['total'] is String)
                              ? double.tryParse(item['total']) ?? 0
                              : (item['total'] is num)
                                  ? item['total'].toDouble()
                                  : 0;

                          final qty = (item['qty'] is String)
                              ? int.tryParse(item['qty']) ?? 0
                              : (item['qty'] is int)
                                  ? item['qty']
                                  : 0;

                          return Card(
                            child: ListTile(
                              title: Text(
                                  item['nama_barang'] ?? 'Tidak Diketahui'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("$qty pcs x ${formatRupiah(harga)}"),
                                  if ((item['disc_persen'] ?? 0) > 0 ||
                                      (item['disc_nominal'] ?? 0) > 0)
                                    Text(
                                      "Diskon: ${(item['disc_persen'] ?? 0).toStringAsFixed(0)}% - ${formatRupiah(item['disc_nominal'] ?? 0)}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red,
                                      ),
                                    ),
                                ],
                              ),
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
          if (!isLoading && barang.isNotEmpty)
            Column(
              children: [
                // Rincian Diskon, PPN, Ongkir
                if (discNominal > 0 ||
                    discPersen > 0 ||
                    ppnPersen > 0 ||
                    ongkir > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (discNominal > 0)
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Diskon (Rp): '),
                                    TextSpan(
                                      text: formatRupiah(discNominal),
                                      style:
                                          const TextStyle(color: Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                            if (discPersen > 0)
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Diskon (%): '),
                                    TextSpan(
                                      text: "${discPersen.toStringAsFixed(0)}%",
                                      style:
                                          const TextStyle(color: Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (ppnPersen > 0)
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  children: [
                                    const TextSpan(text: 'PPN (%): '),
                                    TextSpan(
                                      text: "${ppnPersen.toStringAsFixed(0)}%",
                                      style:
                                          const TextStyle(color: Colors.orange),
                                    ),
                                  ],
                                ),
                              ),
                            if (ongkir > 0)
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Ongkir: '),
                                    TextSpan(
                                      text: formatRupiah(ongkir),
                                      style:
                                          const TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Total Semua
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Semua",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formatRupiah(totalInvoice.toDouble()),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                // Sisa Tagihan
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Sisa Tagihan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        formatRupiah(sisaTagihan.toDouble()),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
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
                          onPressed: () {
                            showPembayaranDialog(context, sisaTagihan);
                          },
                          icon: const Icon(Icons.payment),
                          label: const Text(
                            "Bayar",
                            style: TextStyle(fontWeight: FontWeight.bold),
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
            )
        ],
      ),
    );
  }

  Widget _buildHeader(
      String invoiceNumber,
      String customer,
      String alamat,
      String telepon,
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
          Text(customer,
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(telepon,
              style: const TextStyle(fontSize: 13, color: Colors.white)),
          const SizedBox(height: 2),
          Text(alamat,
              style: const TextStyle(fontSize: 13, color: Colors.white)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(status,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
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
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(dueDate, style: const TextStyle(color: Colors.white)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}