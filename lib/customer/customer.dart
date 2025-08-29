import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hayami_app/Dashboard/dashboardscreen.dart';
import 'package:hayami_app/customer/detailcustomer.dart';
import 'package:hayami_app/customer/tambahcustomer.dart';
import 'package:http/http.dart' as http;

class Customerscreen extends StatefulWidget {
  const Customerscreen({super.key});

  @override
  State<Customerscreen> createState() => _CustomerscreenState();
}

class _CustomerscreenState extends State<Customerscreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filteredCustomers = [];
  bool isLoading = true;
  bool dataChanged = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.3/nindo/get_supplier.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        customers = data.map<Map<String, dynamic>>((item) {
          return {
            "id": item["id_supp"],
            "name": item["nm_supp"],
            "jenis": item["jenis"],
            "phone": item["hp"],
            "address": item["alamat"],
          };
        }).toList();

        setState(() {
          filteredCustomers = customers;
          isLoading = false;
        });
      } else {
        throw Exception('Gagal mengambil data');
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    String keyword = _searchController.text.toLowerCase();
    setState(() {
      filteredCustomers = customers.where((customer) {
        final name = customer["name"]?.toString().toLowerCase() ?? '';
        return name.contains(keyword);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, dataChanged);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Customer / Supplier",
              style: TextStyle(color: Colors.blue)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.blue),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const Dashboardscreen()));
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Cari Nama...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: fetchCustomers,
                      child: filteredCustomers.isEmpty
                          ? ListView(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 100),
                                Center(child: Text("Tidak ada data ditemukan")),
                              ],
                            )
                          : ListView.builder(
                              itemCount: filteredCustomers.length,
                              itemBuilder: (context, index) {
                                final customer = filteredCustomers[index];
                                return Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom:
                                          BorderSide(color: Colors.grey, width: 0.5),
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Text(customer["name"] ?? ''),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(customer["jenis"] ?? ''),
                                        Text(customer["phone"] ?? ''),
                                      ],
                                    ),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              Customerdetailscreen(
                                                  customer: customer),
                                        ),
                                      );

                                      if (result == 'deleted') {
                                        await fetchCustomers();
                                        setState(() {
                                          dataChanged = true;
                                        });
                                      } else if (result != null &&
                                          result is Map<String, dynamic>) {
                                        setState(() {
                                          int i = customers.indexWhere(
                                              (c) => c["id"] == result["id"]);
                                          if (i != -1) {
                                            customers[i] = result;
                                            _searchController.clear();
                                            filteredCustomers = customers;
                                            dataChanged = true;
                                          }
                                        });
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TambahCustomerScreen()),
            );
            if (result == true) {
              fetchCustomers(); // refresh data setelah tambah
              setState(() {
                dataChanged = true;
              });
            }
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add, color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
