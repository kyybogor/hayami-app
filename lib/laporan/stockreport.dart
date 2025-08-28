import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StockReportPage extends StatefulWidget {
  const StockReportPage({super.key});

  @override
  State<StockReportPage> createState() => _StockReportPageState();
}

class _StockReportPageState extends State<StockReportPage> {
  final String apiUrl = "http://192.168.1.11/nindo/bank/stock_report_json.php";

  List<dynamic> allData = [];
  List<dynamic> filteredData = [];

  final TextEditingController idProductCtrl = TextEditingController();
  final TextEditingController namaProductCtrl = TextEditingController();

  final double col1 = 250;
  final double col2 = 300;
  final double col3 = 150;

  @override
  void initState() {
    super.initState();
    fetchData();

    // listener untuk update UI kalau ada perubahan text
    idProductCtrl.addListener(() => setState(() {}));
    namaProductCtrl.addListener(() => setState(() {}));
  }

  Future<void> fetchData() async {
    try {
      var res = await http.get(Uri.parse(apiUrl));
      if (res.statusCode == 200) {
        final jsonRes = json.decode(res.body);
        setState(() {
          allData = jsonRes["data"];
          filteredData = [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  void searchData() {
    setState(() {
      if (idProductCtrl.text.isEmpty && namaProductCtrl.text.isEmpty) {
        filteredData = allData;
      } else {
        filteredData = allData.where((item) {
          bool match = true;
          if (idProductCtrl.text.isNotEmpty) {
            match &= item["id_product"]
                .toString()
                .toLowerCase()
                .contains(idProductCtrl.text.toLowerCase());
          }
          if (namaProductCtrl.text.isNotEmpty) {
            match &= item["nm_product"]
                .toString()
                .toLowerCase()
                .contains(namaProductCtrl.text.toLowerCase());
          }
          return match;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final double col1 = screenWidth * 0.3; // 30%
    final double col2 = screenWidth * 0.45; // 45%
    final double col3 = screenWidth * 0.25; // 25%

    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock Report"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            /// Search Fields sejajar
            Row(
              children: [
                Expanded(
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      // langsung filter dari allData
                      return allData
                          .map((e) => e["id_product"].toString())
                          .where((option) => option
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()))
                          .toList();
                    },
                    onSelected: (String selection) {
                      idProductCtrl.text = selection;
                      namaProductCtrl.clear();
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onEditingComplete) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: "ID Product",
                          border: const OutlineInputBorder(),
                          suffixIcon: controller.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    controller.clear();
                                    idProductCtrl.clear();
                                  },
                                )
                              : null,
                        ),
                        onChanged: (val) {
                          // langsung update controller Flutter, tidak perlu setState
                          idProductCtrl.text = val;
                        },
                        onEditingComplete: onEditingComplete,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      if (idProductCtrl.text.isNotEmpty) {
                        return allData
                            .where((e) =>
                                e["id_product"].toString() ==
                                idProductCtrl.text)
                            .map((e) => e["nm_product"].toString())
                            .where((option) => option
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()))
                            .toList();
                      } else {
                        return allData
                            .map((e) => e["nm_product"].toString())
                            .where((option) => option
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()))
                            .toList();
                      }
                    },
                    onSelected: (String selection) {
                      namaProductCtrl.text = selection;
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onEditingComplete) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: "Nama Product",
                          border: const OutlineInputBorder(),
                          suffixIcon: controller.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    controller.clear();
                                    namaProductCtrl.clear();
                                  },
                                )
                              : null,
                        ),
                        onChanged: (val) {
                          namaProductCtrl.text = val;
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Button Cari full width
            SizedBox(
              width: 1250,
              height: 45,
              child: ElevatedButton(
                onPressed: searchData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text("Cari"),
              ),
            ),
            const SizedBox(height: 12),

            /// Tabel hasil search
            Expanded(
              child: filteredData.isEmpty
                  ? const Center(
                      child: Text("Silakan masukkan data lalu tekan Cari"))
                  : Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor:
                                MaterialStateProperty.all(Colors.indigo),
                            headingTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            border:
                                TableBorder.all(color: Colors.grey.shade300),
                            columns: [
                              DataColumn(
                                label: SizedBox(
                                  width: col1,
                                  child: const Center(
                                    child: Text("ID Product"),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: col2,
                                  child: const Center(
                                    child: Text("Nama Product"),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: col3,
                                  child: const Center(
                                    child: Text("Stock"),
                                  ),
                                ),
                              ),
                            ],
                            rows: filteredData.map((item) {
                              return DataRow(
                                cells: [
                                  DataCell(SizedBox(
                                    width: col1,
                                    child: Center(
                                        child: Text(
                                            item["id_product"].toString())),
                                  )),
                                  DataCell(SizedBox(
                                    width: col2,
                                    child: Center(
                                        child: Text(
                                            item["nm_product"].toString())),
                                  )),
                                  DataCell(SizedBox(
                                    width: col3,
                                    child: Center(
                                        child: Text(item["stock"].toString())),
                                  )),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
