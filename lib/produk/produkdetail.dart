import 'package:flutter/material.dart';
import 'package:hayami_app/produk/updateproduk.dart';
import 'package:intl/intl.dart';

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

String displayValue(dynamic value) {
  if (value == null ||
      value.toString().toLowerCase() == 'null' ||
      value.toString().trim().isEmpty) {
    return '-';
  }
  return value.toString();
}

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20), // Warna latar hijau tua
        foregroundColor: Colors.white, // Warna teks, ikon jadi putih
        title: Column(
          children: [
            Text(displayValue(product['nm_product']),
                style: const TextStyle(fontSize: 20)),
            Text(displayValue(product['id_product']),
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert), // Ikon menu putih
            color: Colors.white, // Warna background popup
            onSelected: (value) async {
              if (value == 'ubah') {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProductPage(product: product),
                  ),
                );
                if (result == true) {
                  Navigator.pop(context, true);
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'ubah',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Ubah'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Gambar produk di tengah
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                    'http://192.168.1.20/nindo/${product['gambar']}'),
              ),
            ),

            const SizedBox(height: 16),

            // Info Produk
            Center(
              child: Column(
                children: [
                  Text(
                    displayValue(product['nm_product']),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Kategori: ${displayValue(product['nm_kategori'])}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Harga Jual: ${product['price'] == null ? '-' : formatRupiah(product['price'])}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Info Card 1 Baris Per Card
            _buildInfoCard(Icons.inventory_2, 'Stok Tersedia',
                displayValue(product['qty']), Colors.green),
            const SizedBox(height: 12),
            _buildInfoCard(Icons.warning_amber, 'Minimal Stok',
                displayValue(product['minim']), Colors.orange),
            const SizedBox(height: 12),
            _buildInfoCard(Icons.trending_up, 'Maksimal Stok',
                displayValue(product['maxim']), Colors.blue),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      IconData icon, String title, String value, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(fontSize: 13, color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
