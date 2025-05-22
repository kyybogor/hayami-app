import 'package:flutter/material.dart';

class DetailItem extends StatelessWidget {
  final String produk;
  final String deskripsi;
  final String satuan;
  final int kuantitas;
  final int harga;

  const DetailItem({
    super.key,
    required this.produk,
    required this.deskripsi,
    required this.satuan,
    required this.kuantitas,
    required this.harga,
  });

  @override
  Widget build(BuildContext context) {
    int total = harga * kuantitas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detil Item'),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _itemRow(Icons.shopping_bag, 'Produk', produk),
            const SizedBox(height: 16),
            _itemRow(Icons.chat, 'Deskripsi', deskripsi),
            const SizedBox(height: 16),
            _itemRow(Icons.scale, 'Satuan', satuan),
            const SizedBox(height: 24),
            _labelValue('Kuantitas', '$kuantitas'),
            const SizedBox(height: 16),
            _labelValue('Harga', 'Rp${harga.toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            _labelValue('Total', 'Rp${total.toStringAsFixed(0)}'),
          ],
        ),
      ),
    );
  }

  Widget _itemRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _labelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
