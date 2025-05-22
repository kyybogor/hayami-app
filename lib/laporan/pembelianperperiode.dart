import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PembelianPerPeriodePage extends StatefulWidget {
  const PembelianPerPeriodePage({super.key});

  @override
  State<PembelianPerPeriodePage> createState() =>
      _PembelianPerPeriodePageState();
}

class _PembelianPerPeriodePageState extends State<PembelianPerPeriodePage> {
  List<Map<String, dynamic>> data = [];
  int totalKuantitas = 0;
  int totalHarga = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'http://localhost/CONNNECT/JSON/get_pembelian_periode.php')); // ganti URL sesuai hosting-mu

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success']) {
        setState(() {
          data = List<Map<String, dynamic>>.from(result['data']);
          totalKuantitas =
              data.fold(0, (sum, item) => sum + item['kuantitas'] as int);
          totalHarga = data.fold(0, (sum, item) => sum + item['total'] as int);
        });
      }
    } else {
      // Error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Pembelian per Periode",
          style: TextStyle(color: Colors.blue),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {},
          ),
        ],
      ),
      body: data.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 8),
                ...data.map((item) => Column(
                      children: [
                        _periodeItem(
                            item['periode'], item['kuantitas'], item['total']),
                        _shortDivider(),
                      ],
                    )),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Kuantitas",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_formatNumber(totalKuantitas),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                _shortDivider(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_formatNumber(totalHarga),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                _shortDivider(),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "share",
            backgroundColor: Colors.blue[200],
            onPressed: () {},
            child: const Icon(Icons.share),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "download",
            backgroundColor: Colors.blue[800],
            onPressed: () {},
            child: const Icon(Icons.download),
          ),
        ],
      ),
    );
  }

  Widget _periodeItem(String month, int quantity, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$month (${_formatNumber(quantity)})"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _formatNumber(total),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shortDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Divider(
        height: 1,
        thickness: 2,
        color: Colors.grey[300],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
  }
}
