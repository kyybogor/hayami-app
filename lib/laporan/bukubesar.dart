import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Untuk format angka

class BukuBesarScreen extends StatefulWidget {
  @override
  _BukuBesarScreenState createState() => _BukuBesarScreenState();
}

class _BukuBesarScreenState extends State<BukuBesarScreen> {
  List<dynamic> dataBukuBesar = [];

  @override
  void initState() {
    super.initState();
    fetchBukuBesar();
  }

  Future<void> fetchBukuBesar() async {
    final response = await http.get(
      Uri.parse("http://192.168.1.10/connect/JSON/buku_besar.php"),
    );

    if (response.statusCode == 200) {
      setState(() {
        dataBukuBesar = json.decode(response.body);
      });
    } else {
      print("Failed to load data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.blueAccent,
        title: Text(
          'Buku Besar',
          style: TextStyle(
            color: Colors.blueAccent,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: dataBukuBesar.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: dataBukuBesar.length,
              separatorBuilder: (context, index) => Divider(
                height: 0.5,
                thickness: 0.5,
                color: Colors.grey[300],
              ),
              itemBuilder: (context, index) {
                var item = dataBukuBesar[index];
                return ListTile(
                  title: Text("${item['nama_transaksi']} (${item['kode']})"),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailBukuBesar(
                          nama_transaksi: item['nama_transaksi'],
                          kode: item['kode'],
                          debit: int.tryParse(item['debit'].toString()) ?? 0,
                          kredit: int.tryParse(item['kredit'].toString()) ?? 0,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class DetailBukuBesar extends StatelessWidget {
  final String nama_transaksi;
  final String kode;
  final int debit;
  final int kredit;

  DetailBukuBesar({
    required this.nama_transaksi,
    required this.kode,
    required this.debit,
    required this.kredit,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat("#,##0", "id_ID");

    Widget buildRow(String label, int value) {
      return Column(
        children: [
          Divider(height: 0.5, thickness: 0.5, color: Colors.grey[300]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // dipersempit
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: TextStyle(fontSize: 16)),
                Text(formatCurrency.format(value), style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("$nama_transaksi ($kode)"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Column(
        children: [
          buildRow("Debit", debit),
          buildRow("Kredit", kredit),
          Divider(height: 0.5, thickness: 0.5, color: Colors.grey[300]),
        ],
      ),
    );
  }
}
