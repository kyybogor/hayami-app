import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hayami_app/Pembelian/detailbelumdibayarpembelian.dart';
import 'package:hayami_app/Pembelian/tambahbelumdibayarpembelian.dart';
import 'package:hayami_app/tagihan/tambahtagihan.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BelumDibayarPembelian extends StatefulWidget {
  const BelumDibayarPembelian({super.key});

  @override
  State<BelumDibayarPembelian> createState() => _BelumDibayarPembelianState();
}

class _BelumDibayarPembelianState extends State<BelumDibayarPembelian> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> invoices = [];
  List<Map<String, dynamic>> filteredInvoices = [];
  bool isLoading = true;
  bool dataChanged = false;

  String selectedMonth = DateFormat('MM').format(DateTime.now());
  String selectedYear = DateFormat('yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    fetchInvoices();
  }

Future<void> fetchInvoices() async {
  try {
    final response = await http.get(
      Uri.parse('http://192.168.1.10/nindo/stockin%20-%20Copy.php?action=po'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.body);
      final List<dynamic> data = result['data'];

      invoices = data.map<Map<String, dynamic>>((item) {
        return {
          "id": item["id_po1"],
          "name": item["supplier"]["nama"],
          "alamat": item["supplier"]["alamat"],
          "hp": item["supplier"]["hp"],
          "invoice": item["id_po1"],
          "date": item["tanggal"],
          "due": item["tanggal"], // ganti jika punya field due_date
          "amount": item["total"].toString(),
          "status": "Belum Dibayar",
          "total": item["total"],
          // Jika detail ingin dipanggil nanti, bisa simpan ID di sini
          "id_po1": item["id_po1"]
        };
      }).toList();

      setState(() {
        filteredInvoices = invoices;
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

  void filterByMonthYear() {
    setState(() {
      filteredInvoices = invoices.where((invoice) {
        try {
          final invoiceDate = DateFormat('yyyy-MM-dd').parse(invoice["date"]);
          final matchMonth = selectedMonth == 'Semua' ||
              invoiceDate.month.toString().padLeft(2, '0') == selectedMonth;
          final matchYear = selectedYear == 'Semua' ||
              invoiceDate.year.toString() == selectedYear;
          return matchMonth && matchYear;
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
        final matchMonth = selectedMonth == 'Semua' ||
            invoiceDate.month.toString().padLeft(2, '0') == selectedMonth;
        final matchYear = selectedYear == 'Semua' ||
            invoiceDate.year.toString() == selectedYear;
        return invoice["name"].toString().toLowerCase().contains(keyword) &&
            matchMonth &&
            matchYear;
      }).toList();
    });
  }

  String formatRupiah(String amount) {
    try {
      final double value = double.parse(amount);
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(value);
    } catch (e) {
      return amount;
    }
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
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Cari",
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
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
              child: Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: selectedMonth,
                      isExpanded: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.calendar_today),
                        labelText: "Bulan",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.blue.shade50,
                      ),
                      items: [
                        'Semua',
                        ...List.generate(12, (index) {
                          final month = (index + 1).toString().padLeft(2, '0');
                          return month;
                        })
                      ].map((month) {
                        return DropdownMenuItem(
                          value: month,
                          child: Text(
                            month == 'Semua'
                                ? 'Semua Bulan'
                                : DateFormat('MMMM')
                                    .format(DateTime(0, int.parse(month))),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedMonth = value;
                          });
                          filterByMonthYear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: selectedYear,
                      isExpanded: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.date_range),
                        labelText: "Tahun",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.blue.shade50,
                      ),
                      items: ['Semua', '2023', '2024', '2025'].map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year == 'Semua' ? 'Semua Tahun' : year),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedYear = value;
                          });
                          filterByMonthYear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
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
                              title: Text(invoice["name"]),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(invoice["invoice"]),
                                  Text(invoice["date"]),
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
                                        DetailBelumDibayarPembelian(
                                            invoice: invoice),
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
              MaterialPageRoute(
                  builder: (context) => const TambahTagihanPage()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
