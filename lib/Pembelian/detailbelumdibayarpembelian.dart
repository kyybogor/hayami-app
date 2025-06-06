import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class DetailBelumDibayarPembelian extends StatefulWidget {
  final Map<String, dynamic> invoice;

  const DetailBelumDibayarPembelian({super.key, required this.invoice});

  @override
  State<DetailBelumDibayarPembelian> createState() => _DetailBelumDibayarPembelianState();
}

class _DetailBelumDibayarPembelianState extends State<DetailBelumDibayarPembelian> {
  List<dynamic> barang = [];
  int totalInvoice = 0;
  int sisaTagihan = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProduct();
  }

  Future<void> fetchProduct() async {
    setState(() {
      isLoading = true;
    });

    final invoiceId = widget.invoice['id']?.toString().trim() ?? '';
    final url = Uri.parse("http://192.168.1.8/nindo/stockin.php");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> allData = data['data'];

        final matchedInvoice = allData.firstWhere(
          (item) => item['id_po1'].toString().trim() == invoiceId,
          orElse: () => null,
        );

        if (matchedInvoice != null) {
          setState(() {
            totalInvoice = matchedInvoice['total'] ?? 0;
            sisaTagihan = matchedInvoice['sisa_hutang'] ?? 0;
            barang = (matchedInvoice['produk'] as List<dynamic>).map((produk) {
              final price = double.tryParse(produk['price'].toString()) ?? 0;
              final totalHarga = double.tryParse(produk['total_harga'].toString()) ?? 0;
              final qty = produk['qty'] ?? 0;

              return {
                'nama_barang': produk['nama_produk'] ?? 'Tidak Diketahui',
                'jumlah': totalHarga.toString(),
                'qty': qty,
                'harga': price.toString(),
                'total': totalHarga.toString(),
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
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatRupiah(double number) {
    final formatter = NumberFormat.currency(locale: "id_ID", symbol: "Rp ", decimalDigits: 0);
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
    final contactName = invoice['name'] ?? 'Tidak diketahui';
    final alamat = invoice['alamat'] ?? 'Tidak diketahui';
    final hp = invoice['hp'] ?? '-';
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
          _buildHeader(invoiceNumber, contactName, alamat, hp, date, dueDate, status, statusColor),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Barang Dibeli", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    ? const Center(child: Text("Tidak ada barang untuk invoice ini."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: barang.length,
                        itemBuilder: (context, index) {
                          final item = barang[index];
                          final harga = double.tryParse(item['harga'] ?? '0') ?? 0;
                          final total = double.tryParse(item['total'] ?? '0') ?? 0;
                          final qty = item['qty'] ?? 0;

                          return Card(
                            child: ListTile(
                              title: Text(item['nama_barang'] ?? 'Tidak Diketahui'),
                              subtitle: Text("$qty pcs x ${formatRupiah(harga)}"),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                      const Text("Total Semua", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(formatRupiah(totalInvoice.toDouble()), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                      const Text("Sisa Tagihan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(formatRupiah(sisaTagihan.toDouble()), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(String invoiceNumber, String contactName, String alamat, String hp,
      String date, String dueDate, String status, Color statusColor) {
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
          Text(invoiceNumber, style: const TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 16),
          Text(contactName, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(hp, style: const TextStyle(fontSize: 13, color: Colors.white)),
          const SizedBox(height: 2),
          Text(alamat, style: const TextStyle(fontSize: 13, color: Colors.white)),
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
                Text(status, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 5),
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