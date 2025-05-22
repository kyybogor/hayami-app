import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    home: PembelianPerProdukPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class PembelianPerProdukPage extends StatefulWidget {
  const PembelianPerProdukPage({super.key});

  @override
  State<PembelianPerProdukPage> createState() => _PembelianPerProdukPageState();
}

class _PembelianPerProdukPageState extends State<PembelianPerProdukPage> {
  List<dynamic> pembelianProduk = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchPembelian();
  }

  Future<void> fetchPembelian() async {
    final response = await http.get(Uri.parse(
        "http://localhost/CONNNECT/JSON/get_pembelian_produk.php")); // Ganti sesuai IP/server kamu

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json["status"] == true) {
        setState(() {
          pembelianProduk = json["data"];
          loading = false;
        });
      }
    } else {
      throw Exception("Gagal mengambil data");
    }
  }

  String formatAngka(int value) {
    return value.toString().replaceAllMapped(
        RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (match) => "${match[1]}.");
  }

  @override
  Widget build(BuildContext context) {
    int jumlah =
        pembelianProduk.fold(0, (sum, item) => sum + item["jumlah"] as int);
    int total =
        pembelianProduk.fold(0, (sum, item) => sum + item["total"] as int);
    int rataRata = pembelianProduk.isEmpty ? 0 : (total / jumlah).round();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Pembelian per Produk',
            style: TextStyle(color: Colors.blue)),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {},
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ...pembelianProduk.map((item) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(item['nama_produk']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade600,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                formatAngka(item['total']),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailPembelianProdukPage(
                                namaProduk: item['nama_produk'],
                                harga: item['harga'],
                                jumlah: item['jumlah'],
                                total: item['total'],
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                    ],
                  );
                }).toList(),
                const Divider(thickness: 1),
                _buildSummary("Jumlah Dibeli", jumlah.toString()),
                _buildSummary("Total", formatAngka(total)),
                _buildSummary("Rata-rata", formatAngka(rataRata)),
                const SizedBox(height: 80),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'share',
            mini: true,
            backgroundColor: Colors.blue.shade400,
            onPressed: () {},
            child: const Icon(Icons.share),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'download',
            backgroundColor: Colors.blue,
            onPressed: () {},
            child: const Icon(Icons.download),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}

class DetailPembelianProdukPage extends StatelessWidget {
  final String namaProduk;
  final int harga;
  final int jumlah;
  final int total;

  const DetailPembelianProdukPage({
    super.key,
    required this.namaProduk,
    required this.harga,
    required this.jumlah,
    required this.total,
  });

  String formatAngka(int value) {
    return value.toString().replaceAllMapped(
        RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (match) => "${match[1]}.");
  }

  @override
  Widget build(BuildContext context) {
    final double rataRata = total / jumlah;

    return Scaffold(
      appBar: AppBar(
        title: Text(namaProduk, style: const TextStyle(color: Colors.blue)),
        leading: const BackButton(),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.all(12),
            child: const Text(
              'Pembelian',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _buildRow('Harga Saat Ini', formatAngka(harga)),
          const Divider(height: 1),
          _buildRow('Jumlah Terjual', jumlah.toString()),
          const Divider(height: 1),
          _buildRow('Total', formatAngka(total), bold: true),
          const Divider(height: 1),
          _buildRow('Rata-rata', formatAngka(rataRata.round())),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
