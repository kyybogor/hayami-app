import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hayami_app/belumdibayar/detailbelumdibayar.dart';
import 'package:hayami_app/belumdibayar/tambahso.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BelumDibayar extends StatefulWidget {
  const BelumDibayar({super.key});

  @override
  State<BelumDibayar> createState() => _BelumDibayarState();
}

class _BelumDibayarState extends State<BelumDibayar> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> invoices = [];
  List<Map<String, dynamic>> filteredInvoices = [];
  bool isLoading = true;
  bool dataChanged = false;

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    fetchInvoices();
  }

  Future<void> fetchInvoices() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.11/nindo/bank/barang_keluar.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        invoices = data.map<Map<String, dynamic>>((item) {
          return {
            "id": item["id_so1"],
            "customer": item["customer"],
            "alamat": item["alamat"],
            "telepon": item["telepon"],
            "invoice": item["id_so1"],
            "date": item["tanggal"], // pastikan format "yyyy-MM-dd"
            "due": item["jatuh_tempo"],
            "amount": item["hutang"].toString(),
            "status": "Belum Dibayar",
          };
        }).toList();

        if (mounted) {
          setState(() {
            filteredInvoices = invoices;
            isLoading = false;
          });
        }
      } else {
        throw Exception('Gagal mengambil data');
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void filterByDateRange() {
    setState(() {
      filteredInvoices = invoices.where((invoice) {
        try {
          final invoiceDate = DateFormat('yyyy-MM-dd').parse(invoice["date"]);
          bool inRange = true;

          if (startDate != null) {
            inRange = invoiceDate
                .isAfter(startDate!.subtract(const Duration(days: 1)));
          }
          if (endDate != null) {
            inRange = inRange &&
                invoiceDate.isBefore(endDate!.add(const Duration(days: 1)));
          }
          return inRange;
        } catch (e) {
          return false;
        }
      }).toList();
    });
  }

  void _onSearchChanged() {
    String keyword = _searchController.text.toLowerCase();
    setState(() {
      filteredInvoices = invoices.where((invoice) {
        final invoiceDate = DateFormat('yyyy-MM-dd').parse(invoice["date"]);

        bool inRange = true;
        if (startDate != null) {
          inRange =
              invoiceDate.isAfter(startDate!.subtract(const Duration(days: 1)));
        }
        if (endDate != null) {
          inRange = inRange &&
              invoiceDate.isBefore(endDate!.add(const Duration(days: 1)));
        }

        return invoice["customer"].toString().toLowerCase().contains(keyword) &&
            inRange;
      }).toList();
    });
  }

  String formatRupiah(String amount) {
    try {
      final double value = double.parse(amount);
      return NumberFormat.currency(
              locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
          .format(value);
    } catch (e) {
      return amount;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isStart ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
      filterByDateRange();
    }
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
          title:
              const Text("Belum Dibayar", style: TextStyle(color: Colors.blue)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.blue),
            onPressed: () {
              Navigator.pop(context, dataChanged);
            },
          ),
        ),
        body: Column(
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Cari Customer",
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

            // Filter tanggal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: Colors.blue, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                startDate == null
                                    ? "Pilih Tanggal Awal"
                                    : DateFormat('dd-MM-yyyy')
                                        .format(startDate!),
                                style: TextStyle(
                                  color: startDate == null
                                      ? Colors.grey
                                      : Colors.blue.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event,
                                color: Colors.blue, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                endDate == null
                                    ? "Pilih Tanggal Akhir"
                                    : DateFormat('dd-MM-yyyy').format(endDate!),
                                style: TextStyle(
                                  color: endDate == null
                                      ? Colors.grey
                                      : Colors.blue.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // List Data
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredInvoices.isEmpty
                      ? const Center(child: Text("Tidak ada data ditemukan"))
                      : ListView.builder(
                          itemCount: filteredInvoices.length,
                          itemBuilder: (context, index) {
                            final invoice = filteredInvoices[index];
                            return ListTile(
                              title: Text(invoice["customer"]),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Invoice: ${invoice["invoice"]}"),
                                  Text("Tanggal: ${invoice["date"]}"),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.pink.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      formatRupiah(invoice["amount"]),
                                      style: const TextStyle(
                                        color: Colors.pink,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_ios,
                                      size: 16, color: Colors.grey),
                                ],
                              ),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        Detailbelumdibayar(invoice: invoice),
                                  ),
                                );
                                if (result == true) {
                                  fetchInvoices();
                                  dataChanged = true;
                                }
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SalesOrderPage()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
