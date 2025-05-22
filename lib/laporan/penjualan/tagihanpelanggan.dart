import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TagihanPelangganPage(),
    );
  }
}

class TagihanPelangganPage extends StatefulWidget {
  const TagihanPelangganPage({super.key});

  @override
  _TagihanPelangganPageState createState() => _TagihanPelangganPageState();
}

class _TagihanPelangganPageState extends State<TagihanPelangganPage> {
  late Future<List<Map<String, String>>> _tagihanFuture;

  @override
  void initState() {
    super.initState();
    _tagihanFuture = fetchTagihanData();
  }

  Future<List<Map<String, String>>> fetchTagihanData() async {
    final response = await http.get(Uri.parse('https://gmp-system.com/api-hayami/daftar_tagihan.php?sts=2'));

    if (response.statusCode == 200) {
      List<Map<String, String>> tagihanList = [];
      List<dynamic> jsonData = json.decode(response.body);

      for (var item in jsonData) {
        tagihanList.add({
          'id': item['id'] ?? '',
          'invoice': item['invoice'] ?? '',
          'nama': item['nama'] ?? '',
          'date': item['date'] ?? '',
          'amount': item['amount'] ?? '',
        });
      }
      return tagihanList;
    } else {
      throw Exception('Gagal memuat data tagihan');
    }
  }

  // Fungsi untuk format Rupiah
  String formatRupiah(String amount) {
    final number = double.tryParse(amount.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatCurrency.format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.blueAccent,
        title: const Text('Tagihan Pelanggan', style: TextStyle(color: Colors.blueAccent, fontSize: 20),),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _tagihanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data tagihan.'));
          }

          final tagihanList = snapshot.data!;
          return ListView(
            children: [
              ..._buildGroupedList(tagihanList),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildGroupedList(List<Map<String, String>> tagihanList) {
    List<Widget> widgets = [];
    tagihanList.sort((a, b) => b['date']!.compareTo(a['date']!));

    for (int i = 0; i < tagihanList.length; i++) {
      final item = tagihanList[i];

      if (i == 0 || item['date'] != tagihanList[i - 1]['date']) {
        widgets.add(Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[300],
          child: Text(item['date']!),
        ));
      }

      widgets.add(ListTile(
        title: Text(item['nama']!),
        subtitle: Text(item['invoice']!),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                formatRupiah(item['amount']!),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TagihanDetailPage(
                customerName: item['nama']!,
                invoiceNumber: item['invoice']!,
                totalTagihan: item['amount']!,
                dibayar: '0',
                belumDibayar: item['amount']!,
                referensi: '-',
                tanggal: item['date']!,
                jatuhTempo: '23/04/2025',
              ),
            ),
          );
        },
      ));
      widgets.add(const Divider());
    }

    return widgets;
  }
}

class TagihanDetailPage extends StatelessWidget {
  final String customerName;
  final String invoiceNumber;
  final String totalTagihan;
  final String dibayar;
  final String belumDibayar;
  final String referensi;
  final String tanggal;
  final String jatuhTempo;

  const TagihanDetailPage({
    super.key,
    required this.customerName,
    required this.invoiceNumber,
    required this.totalTagihan,
    required this.dibayar,
    required this.belumDibayar,
    required this.referensi,
    required this.tanggal,
    required this.jatuhTempo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customerName),
        leading: const BackButton(),
      ),
      body: ListView(
        children: [
          _sectionHeader('Tagihan Pelanggan'),
          _buildRow('Total Tagihan', formatRupiah(totalTagihan)),
          _buildRow('Dibayar', formatRupiah(dibayar)),
          _buildRow('Belum Dibayar', formatRupiah(belumDibayar), bold: true),
          _sectionHeader('Detil'),
          _buildIconRow(Icons.qr_code, 'Nomor', invoiceNumber),
          _buildIconRow(Icons.chat_bubble_outline, 'Referensi', referensi),
          _buildIconRow(Icons.calendar_today, 'Tanggal', tanggal),
          _buildIconRow(Icons.access_time, 'Jatuh Tempo', jatuhTempo),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
        ],
      ),
    );
  }

  Widget _buildIconRow(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }

  String formatRupiah(String amount) {
    final number = double.tryParse(amount.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatCurrency.format(number);
  }
}
