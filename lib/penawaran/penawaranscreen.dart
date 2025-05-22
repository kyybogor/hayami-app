import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hayami_app/Penjualan/penjualanscreen.dart';
import 'package:hayami_app/penawaran/dipesansebagian.dart';
import 'package:hayami_app/penawaran/disetujuipelanggan.dart';
import 'package:hayami_app/penawaran/ditolakpelanggan.dart';
import 'package:hayami_app/penawaran/draft.dart';
import 'package:hayami_app/penawaran/selesaipenawaran.dart';
import 'package:hayami_app/penawaran/terkirim.dart';
import 'package:http/http.dart' as http;

// Import halaman-halaman

class PenawaranPage extends StatefulWidget {
  const PenawaranPage({super.key});

  @override
  State<PenawaranPage> createState() => _PenawaranPageState();
}

class _PenawaranPageState extends State<PenawaranPage> {
  Map<String, int> PenawaranCounts = {
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
      for (var key in PenawaranCounts.keys) key: 0,
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
        PenawaranCounts = newCounts;
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
        return const DraftPage();
      case "Terkirim":
        return const TerkirimPage();
      case "Dipesan Sebagian":
        return const DipesanSebagianPage();
      case "Ditolak Pelanggan":
        return const DitolakPelangganPage();
      case "Disetujui Pelanggan":
        return const DisetujuiPelangganPage();
      case "Selesai":
        return const SelesaiPenawaranPage();

      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusList = PenawaranCounts.keys.toList();

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
                      final count = PenawaranCounts[label]!;
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
