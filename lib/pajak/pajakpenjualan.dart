import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class PajakPenjualanPage extends StatefulWidget {
  const PajakPenjualanPage({super.key});

  @override
  _PajakPenjualanPageState createState() => _PajakPenjualanPageState();
}

class _PajakPenjualanPageState extends State<PajakPenjualanPage> {
  int penjualan = 0;
  int pembelian = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadTotals();
  }

  Future<void> _loadTotals() async {
    final penjualanUrls = [
      ApiUrls.penjualanUrl1,
      ApiUrls.penjualanUrl2,
    ];

    final pembelianUrls = [
      ApiUrls.pembelianUrl1,
      ApiUrls.pembelianUrl2,
    ];

    final penjualanList = await fetchTransaksi(penjualanUrls);
    final pembelianList = await fetchTransaksi(pembelianUrls);

    setState(() {
      penjualan = penjualanList.fold(0, (sum, item) => sum + item.amount);
      pembelian = pembelianList.fold(0, (sum, item) => sum + item.amount);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int subTotal = penjualan - pembelian;
    final int ppn = (subTotal * 11 ~/ 100);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pajak Penjualan', style: TextStyle(color: Colors.blueAccent, fontSize: 20),),
        foregroundColor: Colors.blueAccent,
        centerTitle: true,
        leading: const BackButton(),
        actions: const [Icon(Icons.filter_list)],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.download),
        onPressed: () {},
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                ListTile(
                  title: const Text('PPN (11%)'),
                  tileColor: Colors.grey[300],
                ),
                ListTile(
                  title: const Text('Penjualan'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_formatCurrency(penjualan)),
                      const Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailTransaksiPage(
                            jenis: 'Penjualan', urls: ApiUrls.penjualanUrls),
                      ),
                    );
                  },
                ),
                const Divider(
                  height: 5,
                ),
                ListTile(
                  title: const Text('Pembelian'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_formatCurrency(pembelian)),
                      const Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailTransaksiPage(
                            jenis: 'Pembelian', urls: ApiUrls.pembelianUrls),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Sub Total',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text(_formatCurrency(subTotal)),
                ),
                ListTile(
                  title: const Text('Total (PPN)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text(
                    _formatCurrency(ppn),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
    );
  }

  String _formatCurrency(int number) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(number);
  }
}

class DetailTransaksiPage extends StatelessWidget {
  final String jenis;
  final List<String> urls;

  const DetailTransaksiPage(
      {super.key, required this.jenis, required this.urls});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(jenis),
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: FutureBuilder<List<Transaksi>>(
        future: fetchTransaksi(urls),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final transaksi = snapshot.data!;
          int total = transaksi.fold(0, (sum, item) => sum + item.amount);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: transaksi.length,
                  itemBuilder: (context, index) {
                    final item = transaksi[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        ListTile(
                          title: const Text('Tanggal'),
                          subtitle: Text(item.date),
                        ),
                        ListTile(
                          title: const Text('Transaksi'),
                          subtitle: Text(item.invoice),
                        ),
                        ListTile(
                          title: const Text('Nama'),
                          subtitle: Text(item.nama),
                        ),
                        ListTile(
                          title: const Text('Total'),
                          subtitle: Text(_formatCurrency(item.amount)),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }

  String _formatCurrency(int number) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(number);
  }
}

class Transaksi {
  final String id;
  final String invoice;
  final String nama;
  final String date;
  final int amount;

  Transaksi({
    required this.id,
    required this.invoice,
    required this.nama,
    required this.date,
    required this.amount,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      id: json['id'],
      invoice: json['invoice'],
      nama: json['nama'],
      date: json['date'],
      amount: double.parse(json['amount']).toInt(),
    );
  }
}

class ApiUrls {
  // Api Penjualan
  static const String penjualanUrl1 =
      'https://gmp-system.com/api-hayami/daftar_tagihan.php?sts=1';
  static const String penjualanUrl2 =
      'https://gmp-system.com/api-hayami/daftar_tagihan.php?sts=2';

  // Api Pembelian
  static const String pembelianUrl1 =
      'https://gmp-system.com/api-hayami/daftar_tagihan.php?sts=3';
  static const String pembelianUrl2 =
      'https://gmp-system.com/api-hayami/daftar_tagihan.php?sts=4';

  static List<String> get penjualanUrls => [penjualanUrl1, penjualanUrl2];
  static List<String> get pembelianUrls => [pembelianUrl1, pembelianUrl2];
}

Future<List<Transaksi>> fetchTransaksi(List<String> urls) async {
  final responses =
      await Future.wait(urls.map((url) => http.get(Uri.parse(url))));

  List<Transaksi> allTransaksi = [];
  for (var response in responses) {
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      allTransaksi
          .addAll(data.map((json) => Transaksi.fromJson(json)).toList());
    } else {
      throw Exception('Gagal mengambil data');
    }
  }
  return allTransaksi;
}
