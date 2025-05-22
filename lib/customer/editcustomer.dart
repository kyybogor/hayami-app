import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditCustomerScreen extends StatefulWidget {
  final Map<String, dynamic> customer;

  const EditCustomerScreen({Key? key, required this.customer})
      : super(key: key);

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String selectedJenis = 'Customer';
  final List<String> jenisList = ['Customer', 'Supplier'];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.customer['name'] ?? '';
    _phoneController.text = widget.customer['phone'] ?? '';
    _addressController.text = widget.customer['address'] ?? '';
    selectedJenis = widget.customer['jenis'] ?? 'Customer';
  }

  Future<void> _updateCustomer() async {
    final url = Uri.parse("http://192.168.1.10/nindo/get_supplier.php");

    final response = await http.post(
      url,
      body: {
        "id_supp": widget.customer['id'].toString(), // wajib untuk edit
        "nm_supp": _nameController.text,
        "jenis": selectedJenis,
        "hp": _phoneController.text,
        "alamat": _addressController.text,
        "email": widget.customer['email'] ?? "", // Tambahkan jika ada
      },
    );

    print("RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final result = json.decode(response.body);
        if (result["status"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result["message"] ?? "Berhasil")),
          );
          Navigator.pop(context, {
            'id': widget.customer['id'],
            'nm_supp': _nameController.text,
            'jenis': selectedJenis,
            'hp': _phoneController.text,
            'alamat': _addressController.text,
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result["message"] ?? "Gagal memperbarui")),
          );
        }
      } catch (e) {
        print("JSON error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Respon tidak valid dari server")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menghubungi server")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Edit Customer/Supplier",
            style: TextStyle(color: Colors.blue, fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                decoration: const InputDecoration(
                  labelText: 'Jenis',
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _updateCustomer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12),
                      elevation: 2,
                    ),
                    child: const Text("Update"),
                  ),
                ],
              ),
              const SizedBox(height: 32), // Space at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
