import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Tambahkan ini untuk format angka

class ArusKasPage extends StatefulWidget {
  @override
  _ArusKasPageState createState() => _ArusKasPageState();
}

class _ArusKasPageState extends State<ArusKasPage> {
  List<dynamic> arusKasData = [];

  @override
  void initState() {
    super.initState();
    fetchArusKas();
  }

  Future<void> fetchArusKas() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.10/connect/JSON/arus_kas.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          setState(() {
            arusKasData = data;
          });
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching arus kas: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data: $e')),
        );
      }
    }
  }

  String formatCurrency(dynamic number) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    try {
      return formatter.format(double.parse(number.toString()));
    } catch (e) {
      return 'Rp 0';
    }
  }

  Widget buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      color: Colors.grey[200],
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildItem(String label, String value, {bool isBold = false, bool isNegative = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 1,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: isNegative ? Colors.red : (isBold ? Colors.black : Colors.blue),
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedData = {};
    double totalSaldo = 0;

    for (var item in arusKasData) {
      String kategori = (item['kategori'] ?? 'Lainnya').toString();
      if (!groupedData.containsKey(kategori)) {
        groupedData[kategori] = [];
      }
      groupedData[kategori]!.add(Map<String, dynamic>.from(item));

      // Hitung total saldo untuk semua nilai
      double nilai = double.tryParse(item['nilai']?.toString() ?? '0') ?? 0;
      totalSaldo += nilai;
    }

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.blueAccent,
        title: const Text('Arus Kas', style: TextStyle(color: Colors.blueAccent, fontSize: 20),),
        centerTitle: true,
      ),
      body: SafeArea(
        child: arusKasData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: groupedData.entries.expand((entry) {
                        String kategori = entry.key;
                        List<Map<String, dynamic>> items = entry.value;

                        return [
                          buildSectionHeader(kategori),
                          ...items.map((item) {
                            final label = (item['label'] ?? '').toString();
                            final nilaiRaw = item['nilai'] ?? 0;
                            final nilaiFormatted = formatCurrency(nilaiRaw);
                            final isBold = (item['is_bold'] ?? 0) == 1;
                            final isNegative = (double.tryParse(nilaiRaw.toString()) ?? 0) < 0;

                            return buildItem(label, nilaiFormatted, isBold: isBold, isNegative: isNegative);
                          }).toList(),
                        ];
                      }).toList(),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[300],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Saldo',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formatCurrency(totalSaldo),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: totalSaldo < 0 ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
