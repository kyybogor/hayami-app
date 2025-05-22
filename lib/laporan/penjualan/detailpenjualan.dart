import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() => runApp(const MaterialApp(home: DetailPenjualanPage()));

class DetailPenjualanPage extends StatefulWidget {
  const DetailPenjualanPage({super.key});

  @override
  _DetailPenjualanPageState createState() => _DetailPenjualanPageState();
}

class _DetailPenjualanPageState extends State<DetailPenjualanPage> {
  List<Map<String, dynamic>> invoiceList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInvoiceData();
  }

  Future<void> fetchInvoiceData() async {
    final urls = [
      Uri.parse('https://gmp-system.com/api-hayami/daftar_tagihan.php?sts=1'),
      Uri.parse('https://gmp-system.com/api-hayami/daftar_tagihan.php?sts=2'),
      Uri.parse('https://gmp-system.com/api-hayami/daftar_tagihan.php?sts=3'),
      Uri.parse('https://gmp-system.com/api-hayami/daftar_tagihan.php?sts=4'),
    ];

    try {
      final responses = await Future.wait(urls.map((url) => http.get(url)));

      List<Map<String, dynamic>> allInvoices = [];

      for (final response in responses) {
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          final List<Map<String, dynamic>> parsed =
              data.map<Map<String, dynamic>>((item) {
            return {
              'id': item['id'],
              'invoice': item['invoice'],
              'date': item['date'],
              'nama': item['nama'],
              'amount': item['amount'],
            };
          }).toList();

          allInvoices.addAll(parsed);
        } else {
          print(
              'Gagal mengambil data dari salah satu API. Status code: ${response.statusCode}');
        }
      }

      setState(() {
        invoiceList = allInvoices;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Terjadi kesalahan saat mengambil data: $e');
    }
  }

  String formatCurrency(String amount) {
    final number = double.tryParse(amount) ?? 0;
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(number);
  }

  void showRingkasanPopup() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final totalAmount = invoiceList.fold<double>(
          0,
          (prev, el) => prev + (double.tryParse(el['amount']) ?? 0),
        );
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300,
          child: Column(
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const Text('Ringkasan Penjualan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      title: const Text('Total Invoice'),
                      trailing: Text('${invoiceList.length}'),
                    ),
                    ListTile(
                      title: const Text('Total Nilai'),
                      trailing: Text(formatCurrency(totalAmount.toString())),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.blueAccent,
        title: const Text('Detail Penjualan', style: TextStyle(color: Colors.blueAccent, fontSize: 20),),
        leading: const BackButton(),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.filter_alt_outlined), onPressed: () {}),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : invoiceList.isEmpty
              ? const Center(child: Text('Tidak ada data'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: invoiceList.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final invoice = invoiceList[index];
                          return ListTile(
                            title: Text(invoice['invoice']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 110,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    formatCurrency(invoice['amount']),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right,
                                    color: Colors.grey),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailInvoicePage(invoiceData: invoice),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: "share",
              mini: true,
              onPressed: () {}, // Share action
              child: const Icon(Icons.share),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: "download",
              onPressed: () {}, // Download action
              child: const Icon(Icons.download),
            ),
          ],
        ),
      ),
      bottomSheet: GestureDetector(
        onTap: showRingkasanPopup,
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! < -10) {
            showRingkasanPopup();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 60,
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 8,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ringkasan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_up, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailInvoicePage extends StatelessWidget {
  final Map<String, dynamic> invoiceData;

  const DetailInvoicePage({super.key, required this.invoiceData});

  String formatCurrency(String amount) {
    final number = double.tryParse(amount) ?? 0;
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(invoiceData['invoice'],
            style: const TextStyle(color: Colors.blue)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildItem('Nomor', invoiceData['invoice']),
          buildItem('Tanggal', invoiceData['date']),
          buildItem('Nama Kontak', invoiceData['nama']),
          buildItem('Total', formatCurrency(invoiceData['amount'])),
          const Spacer(),
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Buka Detail',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Icon(Icons.keyboard_arrow_up),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildItem(String title, String? value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: Text(title)),
              Expanded(
                flex: 5,
                child: Text(
                  value ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
