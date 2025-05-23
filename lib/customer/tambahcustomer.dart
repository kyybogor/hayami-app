import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TambahCustomerScreen extends StatefulWidget {
  const TambahCustomerScreen({Key? key}) : super(key: key);

  @override
  State<TambahCustomerScreen> createState() => _TambahCustomerScreenState();
}

class _TambahCustomerScreenState extends State<TambahCustomerScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String selectedJenis = 'Customer';
  final List<String> jenisList = ['Customer', 'Supplier'];

  Future<void> _saveData() async {
    final data = {
      "jenis": selectedJenis,
      "nm_supp": _nameController.text,
      "hp": _phoneController.text,
      "email": "",
      "alamat": _addressController.text,
    };

    final response = await http.post(
      Uri.parse("http://192.168.1.10/nindo/get_supplier.php"),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: data,
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result["status"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil disimpan")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Gagal menyimpan")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menyimpan data ke server")),
      );
    }
  }

  InputDecoration inputDecoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: inputDecoration(label, icon),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Tambah Customer/Supplier",
          style: TextStyle(color: Colors.blue, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedJenis,
                  items: jenisList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedJenis = newValue!;
                    });
                  },
                  decoration: inputDecoration("Jenis", Icons.category),
                ),
                const SizedBox(height: 8),
                buildTextField(
                  controller: _nameController,
                  label: "Nama",
                  icon: Icons.person,
                ),
                buildTextField(
                  controller: _phoneController,
                  label: "Nomor HP",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                buildTextField(
                  controller: _addressController,
                  label: "Alamat",
                  icon: Icons.location_on,
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.cancel),
                      label: const Text("Batal"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text("Simpan"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 12),
                      ),
                      onPressed: _saveData,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
