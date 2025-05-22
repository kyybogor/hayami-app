import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RingkasanBank extends StatefulWidget {
  const RingkasanBank({super.key});

  @override
  State<RingkasanBank> createState() => _RingkasanBankState();
}

class _RingkasanBankState extends State<RingkasanBank> {
  Map<String, dynamic> data = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'http://192.168.1.10/connect/JSON/ringkasan_bank.php'));

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
        title: const Text('Ringkasan Bank', style: TextStyle(color: Colors.blueAccent, fontSize: 20),),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SizedBox(height: 10),
                buildSection('Kas', data['Kas']),
                const SizedBox(height: 10),
                buildSection('Rekening Bank', data['Rekening Bank']),
                const SizedBox(height: 10),
                buildSection('Giro', data['Giro']),
                const SizedBox(height: 10),
                buildSection('Total', data['Total']),
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

  Widget buildSection(String title, dynamic sectionData) {
    if (sectionData == null || sectionData is! Map) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(title),
        buildRow('Saldo Awal', parse(sectionData['Saldo Awal'])),
        buildRow('Uang Diterima', parse(sectionData['Uang Diterima'])),
        buildRow('Uang Dibelanjakan', parse(sectionData['Uang Dibelanjakan'])),
        buildRow('Saldo Akhir', parse(sectionData['Saldo Akhir'])),
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
