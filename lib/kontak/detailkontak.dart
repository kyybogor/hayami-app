import 'package:flutter/material.dart';

class Detailkontak extends StatelessWidget {
  final dynamic data;

  const Detailkontak({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    String status = data['status'] ?? 'pegawai';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Kontak")
        ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusTabs(status),
            const SizedBox(height: 8),

            // Header Card with Padding
            Padding(
              padding: const EdgeInsets.all(16),
              child: _headerCard(data),
            ),

            // Section: Detail Profil (full width)
            _buildSectionTitle("Detail Profil"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildLineItem(Icons.layers, "Grup", data['grup'] ?? ''),
                  _buildLineItem(Icons.assignment, "NPWP", data['npwp'] ?? ''),
                ],
              ),
            ),

            // Section: Pemetaan Akun (full width)
            _buildSectionTitle("Pemetaan Akun"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildLineItem(Icons.receipt_long, "Akun Hutang", data['akun_hutang'] ?? ''),
                  _buildLineItem(Icons.receipt_long, "Akun Piutang", data['akun_piutang'] ?? ''),
                  _buildLineItem(Icons.receipt, "Kena pajak", data['kena_pajak'] ?? ''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTabs(String activeStatus) {
    final List<Map<String, dynamic>> tabs = [
      {"label": "Vendor", "icon": Icons.shopping_cart, "value": "vendor"},
      {"label": "Pegawai", "icon": Icons.local_shipping, "value": "pegawai"},
      {"label": "Pelanggan", "icon": Icons.person_outline, "value": "pelanggan"},
      {"label": "Investor", "icon": Icons.handshake_outlined, "value": "investor"},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: tabs.map((tab) {
        bool isActive = tab['value'] == activeStatus;

        return Container(
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              Icon(tab['icon'], color: isActive ? Colors.blue : Colors.grey),
              const SizedBox(height: 4),
              Text(
                tab['label'],
                style: TextStyle(
                  color: isActive ? Colors.blue : Colors.grey,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _headerCard(Map data) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 3,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['nama'],
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 20,
              color: Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data['instansi'],
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Center( // Tetap pusatkan avatar
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey.shade400,
              child: Text(
                data['nama'][0].toUpperCase(),
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.email, data['email']),
          _infoRow(Icons.phone, data['telepon']),
          _infoRow(Icons.location_on, data['alamat']),
        ],
      ),
    ),
  );
}


  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade300,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLineItem(IconData icon, String label, String value) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 16)),
                  const Divider(thickness: 1),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
