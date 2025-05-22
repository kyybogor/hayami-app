import 'package:flutter/material.dart';
import 'package:hayami_app/SignUp/free.dart';
import 'package:hayami_app/SignUp/champion.dart';
import 'package:hayami_app/SignUp/pro.dart';
import 'package:hayami_app/SignUp/elite.dart';

class PackageSelectionPage extends StatelessWidget {
  const PackageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false, // tidak ada jarak di atas
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(
              bottom: 8), // hilangkan padding kanan, kiri, atas
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: const [
                            Text(
                              'Daftar!',
                              style: TextStyle(
                                fontSize: 26,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Daftar gratis, langsung aktif!',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Silakan pilih paket",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              // Champion
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildCard(
                  context,
                  color: Colors.orange,
                  title: "Champion Free Trial",
                  subtitle: "Coba gratis 14 hari",
                  desc:
                      "Fitur untuk enterprise: multi currency, budgeting, approval, konsolidasi anak perusahaan",
                  cocok: "Cocok untuk Bisnis Enterprise",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ChampRegisterPage()),
                  ),
                ),
              ),
              // Elite
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildCard(
                  context,
                  color: Colors.blueGrey,
                  title: "Elite Free Trial",
                  subtitle: "Coba gratis 14 hari",
                  desc:
                      "5 user, 5 gudang, produk manufaktur, konversi satuan, laporan profitabilitas, marketplace connect",
                  cocok: "Cocok Untuk bisnis berkembang",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EliteRegis()),
                  ),
                ),
              ),
              // Pro
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildCard(
                  context,
                  color: Colors.brown,
                  title: "Pro Free Trial",
                  subtitle: "Coba gratis 14 hari",
                  desc:
                      "Alur bisnis lengkap, 3 user, 1 gudang, manajemen stok, multi proyek, 50 laporan keuangan & bisnis",
                  cocok: "Cocok untuk bisnis baru",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProRegis()),
                  ),
                ),
              ),
              // Free
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildCard(
                  context,
                  color: Colors.blue,
                  title: "Free",
                  subtitle: "Gratis selamanya",
                  desc:
                      "1 user, fitur dasar software akuntansi, 10 laporan keuangan",
                  cocok: "Cocok untuk usaha mikro/perorangan",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FreeRegis()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required Color color,
    required String title,
    required String subtitle,
    required String desc,
    required String cocok,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.85), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              desc,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.white70),
            Text(
              cocok,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
