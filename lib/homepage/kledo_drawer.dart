import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class KledoDrawer extends StatelessWidget {
  final menuItems = [
    {'icon': Icons.home, 'title': 'Beranda'},
    {'icon': Icons.shopping_bag, 'title': 'Penjualan'},
    {'icon': Icons.shopping_cart, 'title': 'Pembelian'},
    {'icon': Icons.account_balance_wallet, 'title': 'Biaya'},
    {'icon': Icons.inventory_2, 'title': 'Produk'},
    {'icon': Icons.local_shipping, 'title': 'Inventori'},
    {'icon': Icons.bar_chart, 'title': 'Laporan'},
    {'icon': Icons.account_balance, 'title': 'Kas & Bank'},
    {'icon': Icons.settings, 'title': 'Pengaturan'},
    {'icon': Icons.help_outline, 'title': 'FAQ'},
    {'icon': Icons.exit_to_app, 'title': 'Keluar'},
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A75CF), Color(0xFF007BFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kledo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Zahlfan Wiranto',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text('prt ayam',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            Container(
              color: Colors.yellow[100],
              padding: EdgeInsets.all(10),
              child: RichText(
                text: TextSpan(
                  children: [
                    WidgetSpan(
                      child: Icon(Icons.info, size: 16, color: Colors.black),
                    ),
                    TextSpan(
                      text:
                          '  Data yang tampil saat ini adalah data dummy. Setelah Anda siap, ',
                      style: TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: 'klik disini',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(
                      text: ' untuk mengosongkan data.',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            ...menuItems.map((item) {
              return ListTile(
                leading: Icon(item['icon'] as IconData, color: Colors.white),
                title: Text(item['title'] as String,
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              );
            }).toList(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  // WhatsApp action
                },
                icon: FaIcon(FontAwesomeIcons.whatsapp),
                label: Text('Halo, ada yang bisa saya bantu?'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
