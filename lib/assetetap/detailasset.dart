import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AssetDetailPage extends StatelessWidget {
  final Map<String, dynamic> asset;

  const AssetDetailPage({Key? key, required this.asset}) : super(key: key);

  String formatRupiah(String amount) {
    try {
      final value = double.tryParse(amount) ?? 0;
      return NumberFormat.currency(
              locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
          .format(value);
    } catch (e) {
      return amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle = const TextStyle(fontSize: 13, color: Colors.grey);
    TextStyle valueStyle =
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);

    // Fungsi untuk menghindari null
    String getValue(String? value) {
      return value ?? 'Tidak tersedia';
    }

    Widget infoItem(String label, String value, {IconData? icon}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(icon, size: 20, color: Colors.grey),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: labelStyle),
                  const SizedBox(height: 4),
                  Text(value, style: valueStyle),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget sectionHeader(String title) {
      return Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              asset['name'] ?? 'Detail Aset',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              asset['code'] ?? 'Kode Tidak Tersedia',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        centerTitle: true,
        leading: const BackButton(),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            infoItem('Nama Aset', asset['name'] ?? '',
                icon: Icons.directions_car),
            infoItem('Nomor', asset['code'] ?? '', icon: Icons.qr_code_2),
            infoItem('Tanggal Pembelian', asset['date'] ?? '',
                icon: Icons.calendar_today),
            infoItem('Harga Beli', formatRupiah(asset['amount'].toString()),
                icon: Icons.shopping_cart),
            infoItem('Dikreditkan Dari Akun', asset['akun'],
                icon: Icons.account_balance),
            infoItem('Deskripsi', asset['name'] ?? '', icon: Icons.description),
            sectionHeader('Penyusutan'),
            if (asset['akun_akumulasi'] == null ||
                asset['akun_penyusutan'] == null ||
                asset['metode'] == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('Tidak ada penyusutan', style: valueStyle),
              )
            else ...[
              infoItem('Akun Akumulasi Penyusutan',
                  getValue(asset['akun_akumulasi'])),
              infoItem('Akun Penyusutan', getValue(asset['akun_penyusutan'])),
              infoItem('Metode Penyusutan', getValue(asset['metode']),
                  icon: Icons.build),
              infoItem('Masa Manfaat (tahun)',
                  getValue(asset['masa_manfaat'].toString()) + '%',
                  icon: Icons.speed),
              infoItem(
                  'Tanggal Pelepasan', getValue(asset['tanggal_pelepasan']),
                  icon: Icons.date_range),
              infoItem(
                  'Batas Biaya', formatRupiah(asset['batas_biaya'].toString()),
                  icon: Icons.receipt_long),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.history),
                label: const Text("Lihat Transaksi"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
