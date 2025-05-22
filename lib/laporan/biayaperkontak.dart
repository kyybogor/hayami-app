import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Biayaperkontak extends StatefulWidget {
  const Biayaperkontak({super.key});

  @override
  State<Biayaperkontak> createState() => _BiayaperkontakState();
}

class _BiayaperkontakState extends State<Biayaperkontak> {
  List<Map<String, dynamic>> _data = [];
  bool _loading = true;
  final NumberFormat formatter = NumberFormat("#,##0", "id_ID");

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final url = Uri.parse('http://192.168.1.10/connect/JSON/kontak.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          _data = jsonData
              .map((item) => {
                    "nama": item["nama"],
                    "amount": double.tryParse(item["amount"] ?? "0") ?? 0.0,
                  })
              .toList();
          _loading = false;
        });
      } else {
        throw Exception("Gagal memuat data");
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.blue[800]), // Warna ikon Back
        titleTextStyle: TextStyle(
          color: Colors.blue[800], // Warna teks title
          fontSize: 20,
        ),
        title: const Text("Biaya per Kontak"),
        centerTitle: true,
        leading: const BackButton(),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.filter_alt_outlined,
                color: Colors.black), // Ikon filter tetap hitam
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(
            // Garis atas (full width)
            height: 0.5,
            thickness: 0.5,
            color: Colors.grey,
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: _data.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: Colors.grey, // Garis separator full width
                    ),
                    itemBuilder: (context, index) {
                      final item = _data[index];
                      return ListTile(
                        title: Text(item["nama"]),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber[800],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            formatter.format(item["amount"]),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(
            // Garis bawah (full width)
            height: 0.5,
            thickness: 0.5,
            color: Colors.grey,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aksi tombol download atau lainnya
        },
        child: const Icon(Icons.download),
        backgroundColor: Colors.blue,
      ),
    );
  }
}