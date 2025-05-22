import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BankDetailPage extends StatefulWidget {
  final Map<String, dynamic> bank;

  BankDetailPage({required this.bank});

  @override
  _BankDetailPageState createState() => _BankDetailPageState();
}

class _BankDetailPageState extends State<BankDetailPage> {
  late Map<String, dynamic> bank;

  @override
  void initState() {
    super.initState();
    bank = widget.bank;
  }

  Future<void> _editBankDialog() async {
    TextEditingController namaBankController =
        TextEditingController(text: bank['nama_bank']);
    TextEditingController noRekeningController =
        TextEditingController(text: bank['no_rekening']);

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Data Bank'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: namaBankController,
                decoration: const InputDecoration(labelText: 'Nama Bank'),
              ),
              TextField(
                controller: noRekeningController,
                decoration: const InputDecoration(labelText: 'No. Rekening'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final response = await http.post(
                Uri.parse(
                    'http://192.168.1.13/nindo/bank/bank_api.php?action=edit'),
                body: {
                  'id': bank['id'].toString(),
                  'nama_bank': namaBankController.text,
                  'no_rekening': noRekeningController.text,
                },
              );

              if (response.statusCode == 200) {
                setState(() {
                  bank['nama_bank'] = namaBankController.text;
                  bank['no_rekening'] = noRekeningController.text;
                });
                Navigator.pop(context, true);
              } else {
                Navigator.pop(context, false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gagal update data')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil diupdate')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Detail Bank', style: TextStyle(color: Colors.blue)),
        backgroundColor: Colors.grey[100],
        iconTheme: const IconThemeData(color: Colors.blue),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoTile(
                  icon: Icons.account_balance,
                  label: 'Nama Bank',
                  value: bank['nama_bank'] ?? '',
                ),
                _buildInfoTile(
                  icon: Icons.credit_card,
                  label: 'No. Rekening',
                  value: bank['no_rekening'] ?? '',
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: _editBankDialog,
                    icon:
                        const Icon(Icons.edit, color: Colors.blue, size: 18),
                    label: const Text("Edit",
                        style: TextStyle(color: Colors.blue)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[50],
              child: Icon(icon, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
      ],
    );
  }
}
