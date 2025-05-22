import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hayami_app/Dashboard/dashboardscreen.dart';
import 'package:hayami_app/akun/akunfromscreen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Akunscreen extends StatefulWidget {
  const Akunscreen({super.key});

  @override
  State<Akunscreen> createState() => _AkunscreenState();
}

class _AkunscreenState extends State<Akunscreen> {
  List<dynamic> kasBankData = [];
  List<dynamic> piutangData = [];
  List<dynamic> persediaanData = [];
  List<dynamic> aktivaLancarLainnyaData = [];

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    await fetchKasBank();
    await fetchPiutang();
    await fetchPersediaan();
    await fetchAktivaLancarLainnya();
  }

  Future<void> fetchKasBank() async {
    final url = Uri.parse('http://192.168.1.10/connect/JSON/kasdanbank.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          kasBankData = json.decode(response.body);
        });
      } else {
        throw Exception('Gagal memuat data Kas dan Bank');
      }
    } catch (e) {
      print('Error Kas & Bank: $e');
    }
  }

  Future<void> fetchPiutang() async {
    final url = Uri.parse('http://192.168.1.10/connect/JSON/piutang.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          piutangData = json.decode(response.body);
        });
      } else {
        throw Exception('Gagal memuat data Piutang');
      }
    } catch (e) {
      print('Error Piutang: $e');
    }
  }

  Future<void> fetchPersediaan() async {
    final url = Uri.parse('http://192.168.1.10/connect/JSON/persediaan.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          persediaanData = json.decode(response.body);
        });
      } else {
        throw Exception('Gagal memuat data Persediaan');
      }
    } catch (e) {
      print('Error Persediaan: $e');
    }
  }

  Future<void> fetchAktivaLancarLainnya() async {
    final url =
        Uri.parse('http://192.168.1.10/connect/JSON/aktivalancarlainnya.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          aktivaLancarLainnyaData = json.decode(response.body);
        });
      } else {
        throw Exception('Gagal memuat data aktiva lancar lainnya');
      }
    } catch (e) {
      print('Error Aktiva Lancar Lainnya: $e');
    }
  }

  String formatRupiah(String nominal) {
    final number = double.tryParse(nominal) ?? 0;
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(number);
  }

  Widget buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: Colors.grey[300],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Column(children: items),
      ],
    );
  }

  Widget buildAccountItem(String name, String value,
      {String? kode, Color? valueColor, String? kategori}) {
    return Column(
      children: [
        ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AkunFormScreen(
                  nama: name,
                  kode: kode ?? '',
                  kategori: kategori ?? '',
                ),
              ),
            );
          },
          title: Text(name),
          subtitle: kode != null
              ? Text(kode, style: const TextStyle(fontSize: 12))
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: valueColor ?? Colors.green[400],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(value, style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
        const Divider(height: 0.5, thickness: 0.5),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const KledoDrawer(),
      appBar: AppBar(title: const Text('Akun')),
      body: ListView(
        children: [
          buildSection(
              'Kas & Bank',
              kasBankData.map((item) {
                return buildAccountItem(
                  item['nama'],
                  formatRupiah(item['nominal']),
                  kode: item['kode'],
                  kategori: 'Kas & Bank',
                );
              }).toList()),
          buildSection(
              'Akun Piutang',
              piutangData.map((item) {
                return buildAccountItem(
                  item['nama'],
                  formatRupiah(item['nominal']),
                  kode: item['kode'],
                  kategori: 'Akun Piutang',
                  valueColor:
                      item['nama'].toString().toLowerCase().contains('belum')
                          ? Colors.red[200]
                          : null,
                );
              }).toList()),
          buildSection(
              'Persediaan',
              persediaanData.map((item) {
                return buildAccountItem(
                  item['nama'],
                  formatRupiah(item['nominal']),
                  kode: item['kode'],
                  kategori: 'Persediaan',
                );
              }).toList()),
          buildSection(
              'Aktiva Lancar Lainnya',
              aktivaLancarLainnyaData.map((item) {
                return buildAccountItem(
                  item['nama'],
                  formatRupiah(item['nominal']),
                  kode: item['kode'],
                  kategori: 'Aktiva Lancar Lainnya',
                );
              }).toList()),
        ],
      ),
    );
  }
}
