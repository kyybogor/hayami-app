import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class InputSOPage extends StatefulWidget {
  @override
  _InputSOPageState createState() => _InputSOPageState();
}

class _InputSOPageState extends State<InputSOPage> {
  final _ecerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _salesController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedPPN = "0";
  DateTime _selectedDate = DateTime.now();
  bool _loading = false;

  Future<void> _submitSO() async {
    setState(() => _loading = true);

    final url = Uri.parse("https://yourdomain.com/input_so_flutter.php");
    final response = await http.post(url, body: {
      "ecername": _ecerController.text,
      "phone_cust": _phoneController.text, // Format: "0 | Nama"
      "sales": _salesController.text,
      "tanggal": DateFormat('yyyy-MM-dd').format(_selectedDate),
      "note": _noteController.text,
      "ppn_s": _selectedPPN,
      "id_so": "new",
      "id_user": "admin", // Sesuaikan sesuai user login
    });

    setState(() => _loading = false);

    if (response.statusCode == 200) {
      final result = response.body;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Success: $result')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal kirim data')),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Input Sales Order")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _ecerController,
              decoration: InputDecoration(labelText: "Nama Eceran"),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "HP + Nama (format: 0 | Nama)"),
            ),
            TextField(
              controller: _salesController,
              decoration: InputDecoration(labelText: "Sales"),
            ),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(labelText: "Catatan"),
            ),
            ListTile(
              title: Text("Tanggal: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}"),
              trailing: Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            DropdownButtonFormField<String>(
              value: _selectedPPN,
              items: [
                DropdownMenuItem(value: "0", child: Text("0%")),
                DropdownMenuItem(value: "11", child: Text("11%")),
              ],
              onChanged: (val) => setState(() => _selectedPPN = val),
              decoration: InputDecoration(labelText: "PPN"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submitSO,
              child: _loading ? CircularProgressIndicator() : Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}
