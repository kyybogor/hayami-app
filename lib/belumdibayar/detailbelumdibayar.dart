import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

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

  // ✅ Tambahan variabel untuk telepon
  String telepon = '-';

  @override
  void initState() {
    super.initState();
    telepon =
        widget.invoice['telepon'] ?? '-'; // ✅ Simpan telepon di variabel state
    fetchProduct();
  }

  Future<void> fetchProduct() async {
    setState(() {
      isLoading = true;
    });

    final invoiceId = widget.invoice['id']?.toString().trim() ?? '';
    //print('InvoiceId: $invoiceId');

    final url = Uri.parse("http://192.168.1.10/nindo/barang_keluar.php");

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

            barang = (matchedInvoice['produk'] as List<dynamic>).map((produk) {
              return {
                'nama_barang': produk['nm_product'] ?? 'Tidak Diketahui',
                'harga': double.tryParse('${produk['price']}') ?? 0,
                'qty': int.tryParse('${produk['qty']}') ?? 0,
                'total': double.tryParse('${produk['total_harga']}') ?? 0,
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

  String formatRupiah(double number) {
    final formatter =
        NumberFormat.currency(locale: "id_ID", symbol: "Rp ", decimalDigits: 0);
    return formatter.format(number);
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
          if (!isLoading && barang.isNotEmpty)
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Semua",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(formatRupiah(totalInvoice.toDouble()),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
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
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(formatRupiah(sisaTagihan.toDouble()),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
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
