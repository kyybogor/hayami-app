import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

// Root App
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Aplikasi Pajak',
      debugShowCheckedModeBanner: false,
    );
  }
}

// Fungsi Ambil Data
Future<List<Map<String, dynamic>>> fetchData() async {
  final response = await http.get(
    Uri.parse('https://gmp-system.com/api-hayami/daftar_tagihan.php?sts=2'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((item) {
      return {
        'invoice': item['invoice'],
        'date': item['date'],
        'amount': item['amount'],
      };
    }).toList();
  } else {
    throw Exception('Gagal memuat data');
  }
}

// Format Rupiah
String formatCurrency(int amount) {
  final formatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  return formatter.format(amount);
}

// Halaman Pajak
class PajakPemotonganPage extends StatefulWidget {
  const PajakPemotonganPage({super.key});

  @override
  State<PajakPemotonganPage> createState() => _PajakPemotonganPageState();
}

class _PajakPemotonganPageState extends State<PajakPemotonganPage> {
  late Future<List<Map<String, dynamic>>> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pajak Pemotongan', style: TextStyle(color: Colors.blueAccent, fontSize: 20),),
        foregroundColor: Colors.blueAccent,
        centerTitle: true,
        leading: const BackButton(),
        actions: const [
          Icon(Icons.filter_alt_outlined),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          int totalAmount = 0;

          for (var item in data) {
            final rawAmount = item['amount'].toString();
            final cleanedAmount = rawAmount.split('.').first;
            totalAmount += int.tryParse(cleanedAmount) ?? 0;
          }

          int pph10 = (totalAmount * 10) ~/ 100;

          final formattedAmount = formatCurrency(totalAmount);
          final formattedPph10 = formatCurrency(pph10);

          return Column(
            children: [
              const Divider(
                height: 1,
              ),
              Container(
                color: Colors.grey[300],
                child: const ListTile(
                  title: Text('PPH (10%)'),
                ),
              ),
              const Divider(
                height: 1,
              ),
              ListTile(
                title: const Text('Hutang'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('($formattedAmount)'),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailHutangPage(data: data),
                    ),
                  ); 
                },
              ),
              const Divider(
                height: 5,
              ),
              ListTile(
                title: const Text('Sub Total',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text('($formattedAmount)',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                title: const Text('Total',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text('($formattedPph10)',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.download),
      ),
    );
  }
}

int parseAmount(String rawAmount) {
  final cleanedAmount = rawAmount.split('.').first;
  return int.tryParse(cleanedAmount) ?? 0;
}

// Halaman Detail Hutang
class DetailHutangPage extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const DetailHutangPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hutang'),
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          final amount = parseAmount(item['amount']);
          final formattedAmount = formatCurrency(amount);

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tanggal'),
                    Text(item['date']),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Transaksi'),
                    Text('Transaksi ${item['invoice']}'),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Nomor'),
                    Text(
                      item['invoice'],
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Jumlah'),
                    Text(formattedAmount),
                  ],
                ),
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}
