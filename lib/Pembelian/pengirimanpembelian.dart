import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hayami_app/Pembelian/pembelianscreen.dart';
import 'package:hayami_app/Pembelian/openpembelian.dart';
import 'package:hayami_app/Pembelian/selesaipembelian.dart';
import 'package:http/http.dart' as http;

class PengirimanPembelianPage extends StatefulWidget {
  const PengirimanPembelianPage({super.key});

  @override
  State<PengirimanPembelianPage> createState() => _PengirimanPembelianPageState();
}

class _PengirimanPembelianPageState extends State<PengirimanPembelianPage> {
  Map<String, int> pengirimanCounts = {
    "Open": 0,
    "Selesai": 0,
  };

  bool isLoading = true;

  final Map<String, Color> statusColors = {
    "Open": Colors.pink,
    "Selesai": Colors.green,
  };

  final Map<String, String> statusEndpoints = {
    "Open": 'https://gmp-system.com/api-hayami/pengiriman.php?sts=1',
    "Selesai": 'https://gmp-system.com/api-hayami/pengiriman.php?sts=3',
  };

  @override
  void initState() {
    super.initState();
    fetchPengirimanCounts();
  }

  Future<void> fetchPengirimanCounts() async {
    setState(() {
      isLoading = true;
    });

    Map<String, int> newCounts = {
      for (var key in pengirimanCounts.keys) key: 0,
    };

    try {
      for (var entry in statusEndpoints.entries) {
        final response = await http.get(Uri.parse(entry.value));
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          newCounts[entry.key] = data.length;
        }
      }

      setState(() {
        pengirimanCounts = newCounts;
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusList = pengirimanCounts.keys.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Pengiriman Pembelian", style: TextStyle(color: Colors.blue)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Pembelianscreen()),
              (Route<dynamic> route) => false,
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
                      final count = pengirimanCounts[label]!;
                      final color = statusColors[label] ?? Colors.grey;

                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color,
                              radius: 10,
                            ),
                            title: Text(label),
                            trailing: Text("$count"),
                            onTap: () {
                              if (label == "Open") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const OpenPembelian(),
                                  ),
                                );
                              } else if (label == "Selesai") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SelesaiPembelian(),
                                  ),
                                );
                              }
                            },
                          ),
                          const Divider(height: 1),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
