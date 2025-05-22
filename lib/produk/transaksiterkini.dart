import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransaksiTerkiniPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const TransaksiTerkiniPage({super.key, required this.product});

  // Format ke dalam Rupiah
  String formatRupiah(String? amount) {
    try {
      final value = double.tryParse(amount ?? '0') ?? 0;
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(value);
    } catch (e) {
      return 'Rp 0';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data 'kontaks' dari produk
    final List<dynamic> kontaks = product['kontaks'] ?? [];

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Transaksi Terkini'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: kontaks.isEmpty
          ? const Center(child: Text('Tidak ada data transaksi'))
          : ListView.builder(
              itemCount: kontaks.length,
              itemBuilder: (context, index) {
                final trx = kontaks[index];
                final invoiceCode = trx['kontak_code'] ?? '-';
                final invoiceName = trx['kontak_name'] ?? 'Tanpa Nama';
                final invoiceDate = trx['kontak_date'] ?? 'Tanggal tidak tersedia';
                final invoiceAmount = formatRupiah(trx['kontak_amount']);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(invoiceCode, style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('- $invoiceName', style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(invoiceDate, style: const TextStyle(fontSize: 12)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(invoiceAmount,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () {
                    // Aksi jika ingin ditambahkan
                  },
                );
              },
            ),
    );
  }
}
