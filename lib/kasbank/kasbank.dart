import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'bank_detail_page.dart';

class KasBankPage extends StatefulWidget {
  @override
  _KasBankPageState createState() => _KasBankPageState();
}

class _KasBankPageState extends State<KasBankPage> {
  List<Map<String, dynamic>> bankData = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedFilter = 'Nama Bank';

  @override
  void initState() {
    super.initState();
    fetchBankData();
  }

  Future<void> fetchBankData() async {
    setState(() => isLoading = true);
    final response = await http.get(
      Uri.parse('http://192.168.1.3/nindo/bank_api.php?action=get'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        bankData = data.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data dari server')),
      );
    }
  }

  Future<void> _showAddBankDialog() async {
    final _formKey = GlobalKey<FormState>();
    String namaBank = '';
    String noRekening = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Rekening Bank'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Nama Bank'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Masukkan nama bank'
                        : null,
                    onSaved: (value) => namaBank = value!.trim(),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'No. Rekening'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) => value == null || value.isEmpty
                        ? 'Masukkan no. rekening'
                        : null,
                    onSaved: (value) => noRekening = value!.trim(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green.shade800, // warna background hijau
    foregroundColor: Colors.white, // warna teks/icon putih
  ),
  onPressed: () async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context);
      await _submitNewBank(namaBank, noRekening);
    }
  },
  child: const Text("Simpan"), // contoh teks di tombol
),
          ],
        );
      },
    );
  }

  Future<void> _submitNewBank(String namaBank, String noRekening) async {
    final url =
        Uri.parse('http://192.168.1.13/nindo/bank/bank_api.php?action=insert');

    try {
      final response = await http.post(url, body: {
        'nama_bank': namaBank,
        'no_rekening': noRekening,
      });

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil menambahkan rekening')),
        );
        fetchBankData();
      } else {
        String errorMsg = data['error'] ?? 'Gagal menambahkan rekening';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredBankData = bankData.where((bank) {
      final query = searchQuery.toLowerCase();
      if (selectedFilter == 'Nama Bank') {
        return (bank['nama_bank'] ?? '').toLowerCase().contains(query);
      } else if (selectedFilter == 'No. Rekening') {
        return (bank['no_rekening'] ?? '').toLowerCase().contains(query);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFF2E7D32),
        title: Text('Bank', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: fetchBankData,
                    child: ListView.separated(
                      itemCount: filteredBankData.length,
                      separatorBuilder: (context, index) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final bank = filteredBankData[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade800,
                            child: Icon(
                              Icons.credit_card,
                              color: Colors.white,
                            ),
                          ),
                          title: Text('${bank['nama_bank']}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${bank['no_rekening']}'),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BankDetailPage(bank: bank),
                              ),
                            );
                            await fetchBankData(); // Refresh data setelah kembali
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
  onPressed: _showAddBankDialog,
  backgroundColor: Colors.green.shade800, // warna background ijo
  child: Icon(
    Icons.add,
    color: Colors.white, // warna icon putih
  ),
),
    );
  }
}
