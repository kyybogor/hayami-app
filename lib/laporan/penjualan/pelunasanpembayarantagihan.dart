import 'package:flutter/material.dart';
import 'package:hayami_app/belumdibayar/detailbelumdibayar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PelunasanListPage extends StatefulWidget {
  const PelunasanListPage({super.key});

  @override
  State<PelunasanListPage> createState() => _PelunasanListPageState();
}

class _PelunasanListPageState extends State<PelunasanListPage> {
  late Future<List<Map<String, dynamic>>> futureTagihan;

  @override
  void initState() {
    super.initState();
    futureTagihan = fetchTagihan();
  }

  Future<List<Map<String, dynamic>>> fetchTagihan() async {
    final response = await http.get(
      Uri.parse('https://gmp-system.com/api-hayami/daftar_tagihan.php?sts=2'),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData
          .map<Map<String, dynamic>>((item) => {
                'name': item['nama'],
                'invoice': item['invoice'],
                "amount": item["amount"],
                'date': item['date'],
                "due": item["due"],
                "alamat": item["alamat"],
                "status": item["status"],
              })
          .toList();
    } else {
      throw Exception('Gagal mengambil data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pelunasan Pembayaran', style: TextStyle(color: Colors.blueAccent, fontSize: 20),),
        foregroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureTagihan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data'));
          }

          final data = snapshot.data!;

          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = data[index];
              return ListTile(
                title: Text(item['name']),
                subtitle: Text(item['invoice']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatCurrency(item['amount']),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PelunasanDetailPage(item: item),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'share',
            child: const Icon(Icons.share),
            onPressed: () {},
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'download',
            child: const Icon(Icons.download),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  String formatCurrency(String jumlah) {
    final value = double.tryParse(jumlah) ?? 0;
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }
}

class PelunasanDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const PelunasanDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final String nama = item['name'];
    final String tanggalTagihan = item['date'] ?? '-';

    final String tanggalPembayaranPertama = item['date'] ?? '-';
    final String tanggalPelunasan = item['date'] ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: Text(nama, overflow: TextOverflow.ellipsis),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Tanggal Tagihan'),
            trailing: Text(formatTanggal(tanggalTagihan)),
          ),
          const Divider(
            height: 5,
          ),
          ListTile(
            title: const Text('Tanggal Pembayaran Pertama'),
            trailing: Text(formatTanggal(tanggalPembayaranPertama)),
          ),
          const Divider(
            height: 5,
          ),
          ListTile(
            title: const Text('Tanggal Pelunasan'),
            trailing: Text(formatTanggal(tanggalPelunasan)),
          ),
          const Divider(
            height: 5,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Detailbelumdibayar(invoice: item),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lihat Detail'),
                Icon(Icons.chevron_right),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatTanggal(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (e) {
      return '-';
    }
  }
}
