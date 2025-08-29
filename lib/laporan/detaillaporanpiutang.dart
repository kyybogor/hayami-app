import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class Detaillaporanpiutang extends StatefulWidget {
  final Map<String, dynamic> customer;

  const Detaillaporanpiutang({super.key, required this.customer});

  @override
  State<Detaillaporanpiutang> createState() => _DetaillaporanpiutangState();
}

class _DetaillaporanpiutangState extends State<Detaillaporanpiutang> {
  Map<String, dynamic> piutangData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPiutang();
  }

  Future<void> fetchPiutang() async {
    setState(() {
      isLoading = true;
    });

    final idCustomer = widget.customer['id_customer'] ?? '';
    final url = Uri.parse("http://192.168.1.11/nindo/bank/piutang.php");

    try {
      final response = await http.get(url);
      final decoded = json.decode(response.body);

      // Ambil array data
      final list = decoded['data'] as List<dynamic>;

      final matched = list.firstWhere(
        (item) => item['id_customer'].toString().trim() == idCustomer,
        orElse: () => null,
      );

      setState(() {
        if (matched != null) {
          widget.customer['nama_customer'] = matched['nama_customer'];
          piutangData = matched['data'] ?? {};
          // simpan ke widget.customer biar header pakai
          widget.customer['alamat'] = matched['alamat'];
        } else {
          piutangData = {};
        }
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        piutangData = {};
        isLoading = false;
      });
    }
  }

  String formatRupiah(num number) {
    final formatter =
        NumberFormat.currency(locale: "id_ID", symbol: "Rp ", decimalDigits: 0);
    return formatter.format(number);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'belum dibayar':
        return Colors.red;
      case 'dibayar sebagian':
        return Colors.orange;
      case 'lunas':
        return Colors.green;
      case 'void':
        return Colors.grey;
      case 'jatuh tempo':
        return Colors.black;
      case 'retur':
        return Colors.deepOrange;
      case 'transaksi berulang':
        return Colors.blue;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    final nama = customer['nama_customer'] ?? '-';
    final idCustomer = customer['id_customer'] ?? '-';
    final alamat = customer['alamat'] ?? '-';
    final status = (piutangData['sisa'] ?? 0) > 0 ? 'Belum Dibayar' : 'Lunas';
    final statusColor = _getStatusColor(status);

    final totalBelanja = piutangData['total_belanja'] ?? 0;
    final sudahBayar = piutangData['sudah_bayar'] ?? 0;
    final sisa = piutangData['sisa'] ?? 0;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text('Piutang',
                style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(nama, idCustomer, alamat, status, statusColor),
          const SizedBox(height: 12),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildItemRow("Total Belanja", totalBelanja),
                      _buildItemRow("Sudah Bayar", sudahBayar),
                      _buildItemRow("Sisa", sisa, valueColor: Colors.red),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(String title, num value, {Color? valueColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(formatRupiah(value),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.black)),
        ],
      ),
    );
  }

  Widget _buildHeader(String nama, String idCustomer, String alamat,
      String status, Color statusColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nama Customer
          Text(nama,
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),

          // ID Customer
          Text(idCustomer,
              style: const TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 4),

          // Alamat
          Text(alamat,
              style: const TextStyle(fontSize: 13, color: Colors.white)),
          const SizedBox(height: 16),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(status,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
