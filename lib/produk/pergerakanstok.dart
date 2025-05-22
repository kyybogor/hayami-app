import 'package:flutter/material.dart';

class PergerakanstokPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const PergerakanstokPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Mengambil data 'kontaks' dari produk
    final List<dynamic> kontaks = product['kontaks'] ?? [];

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Pergerakan Stok'),
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
                final invoiceDate =
                    trx['kontak_date'] ?? 'Tanggal tidak tersedia';
                final invoiceAmount = trx['barang_kontak']?['jumlah'] ?? 0;

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Transaksi ' + invoiceCode,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child:
                        Text(invoiceDate, style: const TextStyle(fontSize: 12)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Stack(
                          alignment: Alignment
                              .center, // Menempatkan teks di tengah lingkaran
                          children: [
                            // Lingkaran dengan latar belakang samar
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50, // Latar belakang lingkaran yang samar
                                shape: BoxShape.circle,
                              ),
                            ),
                            // Teks yang jelas dan tidak terpengaruh oleh latar belakang
                            Text(
                              invoiceAmount.toString(),
                              style: const TextStyle(
                                color:
                                    Colors.black, // Teks tetap putih dan jelas
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
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
