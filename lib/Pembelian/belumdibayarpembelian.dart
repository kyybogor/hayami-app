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
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

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

    _startDateController.addListener(() => setState(() {}));
    _endDateController.addListener(() => setState(() {}));

    fetchInvoices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> fetchInvoices() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.20/nindo/stockin%20-%20Copy.php?action=po'),
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
            "due": item["tanggal"],
            "amount": item["total"].toString(),
            "status": "Belum Dibayar",
            "total": item["total"],
            "id_po1": item["id_po1"]
          };
        }).toList();

        setState(() {
          filteredInvoices = invoices;
          isLoading = false;
        });
        filterByDateRange();
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

  void filterByDateRange() {
    setState(() {
      filteredInvoices = invoices.where((invoice) {
        try {
          final invoiceDate = DateFormat('yyyy-MM-dd').parse(invoice["date"]);

          bool matchesStart =
              startDate == null || !invoiceDate.isBefore(startDate!);
          bool matchesEnd = endDate == null || !invoiceDate.isAfter(endDate!);

          return matchesStart && matchesEnd;
        } catch (e) {
          return false;
        }
      }).toList();

      _onSearchChanged();
    });
  }

  void _onSearchChanged() {
    String keyword = _searchController.text.toLowerCase();

    setState(() {
      filteredInvoices = filteredInvoices.where((invoice) {
        final name = invoice["name"].toString().toLowerCase();
        final invoiceId = invoice["invoice"].toString().toLowerCase();

        return name.contains(keyword) || invoiceId.contains(keyword);
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

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime? tempPickedDate = isStart ? startDate : endDate;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(
                  isStart ? 'Pilih Tanggal Mulai' : 'Pilih Tanggal Selesai'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: CalendarDatePicker(
                  initialDate: tempPickedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  onDateChanged: (DateTime date) {
                    setModalState(() {
                      tempPickedDate = date;
                    });
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      if (isStart) {
                        startDate = null;
                        _startDateController.clear();
                      } else {
                        endDate = null;
                        _endDateController.clear();
                      }
                      filterByDateRange();
                    });
                  },
                  child: const Text("Clear"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Batal"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (tempPickedDate != null) {
                      setState(() {
                        if (isStart) {
                          startDate = tempPickedDate;
                          _startDateController.text =
                              DateFormat('yyyy-MM-dd').format(tempPickedDate!);
                        } else {
                          endDate = tempPickedDate;
                          _endDateController.text =
                              DateFormat('yyyy-MM-dd').format(tempPickedDate!);
                        }
                        filterByDateRange();
                      });
                    }
                  },
                  child: const Text("Pilih"),
                ),
              ],
            );
          },
        );
      },
    );
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
  padding: const EdgeInsets.symmetric(horizontal: 12.0),
  child: Row(
    children: [
      Expanded(
        child: InkWell(
          onTap: () => _selectDate(context, true),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
                const Icon(Icons.calendar_today, color: Colors.blue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    startDate == null
                        ? "Pilih Tanggal Awal"
                        : DateFormat('dd-MM-yyyy').format(startDate!),
                    style: TextStyle(
                      color: startDate == null ? Colors.grey : Colors.blue.shade800,
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
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
                const Icon(Icons.event, color: Colors.blue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    endDate == null
                        ? "Pilih Tanggal Akhir"
                        : DateFormat('dd-MM-yyyy').format(endDate!),
                    style: TextStyle(
                      color: endDate == null ? Colors.grey : Colors.blue.shade800,
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
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await fetchInvoices();
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
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TambahTagihanPage(),
              ),
            );

            if (result == true) {
              setState(() {
                isLoading = true;
              });
              await fetchInvoices();
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
