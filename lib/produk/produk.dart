import 'package:flutter/material.dart';
import 'package:hayami_app/produk/tambahproduk.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:hayami_app/Dashboard/dashboardscreen.dart';
import 'package:hayami_app/produk/produkdetail.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  bool _showChart = true;
  List<Map<String, dynamic>> _produkList = [];
  List<Map<String, dynamic>> _filteredProdukList = [];
  int totalProduk = 0;
  int produkHampirHabis = 0;
  int produkHabis = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchProduk();
  }

  String formatRupiah(dynamic amount) {
    try {
      final value = double.tryParse(amount.toString()) ?? 0;
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(value);
    } catch (e) {
      return 'Rp 0';
    }
  }

  Future<void> _fetchProduk() async {
    final url = Uri.parse('http://192.168.1.8/nindo/produk.php');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _produkList = data.map((e) => Map<String, dynamic>.from(e)).toList();
          _filteredProdukList = _produkList;
          _calculateProduk();
        });
      } else {
        print('Failed to load produk');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _searchProduk(String query) {
    final filtered = _produkList.where((produk) {
      final name = produk['nm_product'].toLowerCase();
      final searchTerm = query.toLowerCase();
      return name.contains(searchTerm);
    }).toList();

    setState(() {
      _searchQuery = query;
      _filteredProdukList = filtered;
    });
  }

  void _calculateProduk() {
    int total = 0;
    int hampirHabis = 0;
    int habis = 0;

    for (var produk in _produkList) {
      int stok = int.tryParse(produk['qty'].toString()) ?? 0;
      total++;

      if (stok == 0) {
        habis++;
      } else if (stok < 10) {
        hampirHabis++;
      }
    }

    setState(() {
      totalProduk = total;
      produkHampirHabis = hampirHabis;
      produkHabis = habis;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: const KledoDrawer(),
      appBar: AppBar(
        title: const Text('Produk'),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahProdukPage()),
          );

          if (result == true) {
            _fetchProduk();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: EdgeInsets.zero, // Full width list
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cari',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: _searchProduk,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildStatusCard('Produk Tersedia',
                      (totalProduk - produkHampirHabis - produkHabis).toString(), Colors.green),
                  _buildStatusCard('Produk Hampir Habis',
                      produkHampirHabis.toString(), Colors.orange),
                  _buildStatusCard('Produk Habis', produkHabis.toString(), Colors.red),
                  _buildStatusCard('Total Produk', totalProduk.toString(), Colors.blue),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () {
                setState(() {
                  _showChart = !_showChart;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _showChart ? 'Sembunyikan' : 'Lihat Selengkapnya',
                    style: const TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  Icon(_showChart ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_showChart)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  _buildChartPlaceholder('Pergerakan Stok', screenWidth),
                  _buildChartPlaceholder('Jenis Produk', screenWidth),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // List produk (tanpa padding)
          ..._filteredProdukList.map((produk) => _buildProductItem(produk)).toList(),
        ],
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> produk) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: ListTile(
            title: Text(produk['nm_product'] ?? ''),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${formatRupiah(produk['price'])}'),
                Text('${produk['nm_kategori'] ?? '-'}'),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(product: produk),
                ),
              );
              if (result == true) {
                _fetchProduk();
              }
            },
          ),
        ),
        const Divider(height: 1, color: Colors.black12),
      ],
    );
  }

  Widget _buildStatusCard(String title, String count, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.65,
      height: 80,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  count,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder(String title, double width) {
    return Container(
      width: width - 90,
      height: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
