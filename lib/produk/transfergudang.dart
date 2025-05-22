import 'package:flutter/material.dart';

class TransferGudangPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const TransferGudangPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> transfers = product['transfer'] ?? [];

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Transfer Gudang', style: TextStyle(color: Colors.blue[800])),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Tambahkan logika filter jika dibutuhkan
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blue[800]),
      ),
      body: transfers.isEmpty
          ? const Center(child: Text('Tidak ada data transfer gudang.'))
          : ListView.builder(
              itemCount: transfers.length,
              itemBuilder: (context, index) {
                final transfer = transfers[index];
                final kode = transfer['kode'] ?? 'N/A';
                final tanggal = transfer['tanggal'] ?? 'N/A';

                return ListTile(
                  title: Text(kode),
                  subtitle: Text(tanggal),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Tambahkan aksi jika diperlukan
                  },
                );
              },
            ),
    );
  }
}
