import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hayami_app/Pembelian/penawaran_pembelian/dipesansebagianpembelian.dart';
import 'package:hayami_app/Pembelian/penawaran_pembelian/disetujuipembelian.dart';
import 'package:hayami_app/Pembelian/penawaran_pembelian/ditolakpelangganpembelian.dart';
import 'package:hayami_app/Pembelian/penawaran_pembelian/draftpembelian.dart';
import 'package:hayami_app/Pembelian/penawaran_pembelian/terkirimpembelian.dart';
import 'package:hayami_app/Pembelian/selesaipembelian.dart';
import 'package:hayami_app/Penjualan/penjualanscreen.dart';

import 'package:http/http.dart' as http;

// Import halaman-halaman

class PenawaranPembelianPage extends StatefulWidget {
  const PenawaranPembelianPage({super.key});

  @override
  State<PenawaranPembelianPage> createState() => _PenawaranPembelianPageState();
}

class _PenawaranPembelianPageState extends State<PenawaranPembelianPage> {
  Map<String, int> PenawaranPembelianCounts = {
    "Draft": 0,
    "Terkirim": 0,
    "Ditolak Pelanggan": 0,
    "Disetujui Pelanggan": 0,
    "Selesai": 0,
    "Dipesan Sebagian" : 0
  };

  bool isLoading = true;

  final Map<String, Color> statusColors = {
    "Draft": Colors.blue,
    "Terkirim": Colors.redAccent,
    "Ditolak Pelanggan": Colors.pinkAccent,
    "Disetujui Pelanggan": Colors.lightBlueAccent,
    "Selesai": Colors.greenAccent,
    "Dipesan Sebagian" : Colors.black
  };

  final Map<String, String> nilaiData = {
    // "Selesai": 'https://gmp-system.com/api-hayami/daftar_tagihan.php?sts=1',
  };

  @override
  void initState() {
    super.initState();
    fetchPenawaranCounts();
  }

  Future<void> fetchPenawaranCounts() async {
    setState(() {
      isLoading = true;
    });

    Map<String, int> newCounts = {
      for (var key in PenawaranPembelianCounts.keys) key: 0,
    };

    try {
      for (var entry in nilaiData.entries) {
        final response = await http.get(Uri.parse(entry.value));
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          newCounts[entry.key] = data.length;
        }
      }

      setState(() {
        PenawaranPembelianCounts = newCounts;
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget? getTargetPage(String label) {
    switch (label) {
      case "Draft":
        return const DraftPembelianPage();
      case "Terkirim":
        return const TerkirimPembelianPage();
      case "Dipesan Sebagian":
        return const DipesanSebagianPembelianPage();
      case "Ditolak Pelanggan":
        return const DitolakPelangganPembelianPage();
      case "Disetujui Pelanggan":
        return const DisetujuiPembelianPage();
      case "Selesai":
        return const SelesaiPembelian();

      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusList = PenawaranPembelianCounts.keys.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Penawaran", style: TextStyle(color: Colors.blue)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Penjualanscreen()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: statusList.length,
                    itemBuilder: (context, index) {
                      final label = statusList[index];
                      final count = PenawaranPembelianCounts[label]!;
                      final color = statusColors[label] ?? Colors.grey;
                      final page = getTargetPage(label);

                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color,
                              radius: 10,
                            ),
                            title: Text(label),
                            trailing: Text("$count"),
                            onTap: page != null
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => page),
                                    );
                                  }
                                : null,
                          ),
                          const Divider(height: 1),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          // Tambahkan aksi jika diperlukan
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
