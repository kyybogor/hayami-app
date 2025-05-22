import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RingkasanEksekutif extends StatefulWidget {
  const RingkasanEksekutif({super.key});

  @override
  State<RingkasanEksekutif> createState() => _RingkasanEksekutifState();
}

class _RingkasanEksekutifState extends State<RingkasanEksekutif> {
  Map<String, dynamic> data = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'http://192.168.1.10/connect/JSON/ringkasan_eksekutif.php'));

    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Gagal memuat data');
    }
  }

  int parse(dynamic val) => int.tryParse(val?.toString() ?? '0') ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.blueAccent,
        title: const Text('Ringkasan Eksekutif', style: TextStyle(color: Colors.blueAccent, fontSize: 20),),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SizedBox(height: 10),
                buildSection('Kas', data['Kas'], [
                  'Kas masuk',
                  'Kas keluar',
                  'Perubahan kas',
                  'Saldo penutupan',
                ]),
                const SizedBox(height: 10),
                buildSection('Profitabilitas', data['Profitabilitas'], [
                  'Pendapatan',
                  'Biaya penjualan',
                  'Laba kotor',
                  'Biaya',
                  'Laba bersih',
                ]),
                const SizedBox(height: 10),
                buildSection('Neraca', data['Neraca'], [
                  'Aset',
                  'Liabilitas',
                  'Modal pemilik',
                ]),
                const SizedBox(height: 10),
                buildSection('Pendapatan', data['Pendapatan'], [
                  'Jumlah tagihan diterbitkan', 
                  'Rata-rata nilai tagihan',
                ]),
                const SizedBox(height: 10),
                buildSection('Peforma', data['Peforma'], [
                  'Margin laba kotor',
                  'Margin laba bersih',
                  'Pengembalian investasi / ROI (p.a.)',
                ]),
                const SizedBox(height: 10),
                buildSection('Posisi', data['Posisi'], [
                  'Rata-rata lama konversi piutang',
                  'Rata-rata lama konversi hutang',
                  'Rasio hutang terhadap ekuitas',
                  'Rasio aset terhadap liabilitas',
                ]),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {},
            heroTag: 'share',
            child: const Icon(Icons.share),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {},
            heroTag: 'download',
            child: const Icon(Icons.download),
          ),
        ],
      ),
    );
  }

  Widget buildSection(String title, dynamic sectionData, List<String> keys) {
    if (sectionData == null || sectionData is! Map) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(title),
        for (var key in keys) buildRow(key, parse(sectionData[key])),
      ],
    );
  }

  Widget buildRow(String title, int value) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        value.toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.'),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Container(
      width: double.infinity,
      color: Colors.grey[300],
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
