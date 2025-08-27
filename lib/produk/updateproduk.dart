import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class EditProductPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  late TextEditingController _minimController;
  late TextEditingController _maximController;

  String? _selectedKategoriId;
  List<Map<String, dynamic>> _kategoriList = [];

  File? _selectedImage;
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    _namaController =
        TextEditingController(text: widget.product['nm_product'] ?? '');
    _hargaController =
        TextEditingController(text: widget.product['price']?.toString() ?? '');
    _minimController =
        TextEditingController(text: widget.product['minim']?.toString() ?? '');
    _maximController =
        TextEditingController(text: widget.product['maxim']?.toString() ?? '');
    
    // Initialize the selected category ID from the product data
    _selectedKategoriId = widget.product['brand']?.toString(); 

    _fetchKategori();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _minimController.dispose();
    _maximController.dispose();
    super.dispose();
  }

  Future<void> _fetchKategori() async {
    final url = Uri.parse('http://192.168.1.9/nindo2/kategori.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> kategoriData = json.decode(response.body);
        setState(() {
          _kategoriList = kategoriData
              .map((kategori) => {
                    'id_kategori': kategori['id_kategori'].toString(),
                    'nama_kategori': kategori['nm_kategori'].toString(),
                  })
              .toList();

          // Ensure that the selected category ID exists in the list
          if (_selectedKategoriId != null && _selectedKategoriId!.isNotEmpty) {
            // Check if the selected category is in the list
            if (!_kategoriList.any((kategori) =>
                kategori['id_kategori'] == _selectedKategoriId)) {
              _selectedKategoriId = null; // Reset if not found
            }
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan jaringan')));
    }
  }

Future<void> _pickImage(ImageSource source) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: source);
  if (pickedFile != null) {
    final file = File(pickedFile.path);
    final bytes = await file.readAsBytes();
    setState(() {
      _selectedImage = file;
      _base64Image = base64Encode(bytes);
    });
  }
}

  Future<void> _submitEdit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedKategoriId == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Pilih kategori')));
        return;
      }

      final url = Uri.parse('http://192.168.1.10/nindo/edit_produk.php');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'id_product': widget.product['id_product'].toString(),
            'nm_product': _namaController.text,
            'gambar': _base64Image ?? '',
            'qty': widget.product['qty'].toString(),
            'minim': _minimController.text,
            'maxim': _maximController.text,
            'price': _hargaController.text,
            'brand': _selectedKategoriId, // Send the selected category ID to the backend
            'id_cabang': 'pusat',
          }),
        );

        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produk berhasil diperbarui')));
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal: ${data['message']}')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Gagal mengirim data')));
      }
    }
  }

  InputDecoration inputDecoration(String label) => InputDecoration(
        labelText: label,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        border: InputBorder.none,
      );

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) =>
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.blue),
        ),
        child: TextFormField(
          controller: controller,
          decoration: inputDecoration(label),
          keyboardType: keyboardType,
          validator: validator,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Produk')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField(
                controller: _namaController,
                label: 'Nama Produk',
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Masukkan nama produk' : null,
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: _hargaController,
                label: 'Harga Jual',
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Masukkan harga jual' : null,
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: _minimController,
                label: 'Minimal Stok',
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Masukkan minimal stok' : null,
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: _maximController,
                label: 'Maksimal Stok',
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Masukkan maksimal stok' : null,
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.blue),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedKategoriId,
                  onChanged: (value) =>
                      setState(() => _selectedKategoriId = value),
                  items: _kategoriList
                      .map<DropdownMenuItem<String>>((kategori) {
                    return DropdownMenuItem<String>(
                      value: kategori['id_kategori']!,
                      child: Text(kategori['nama_kategori']!),
                    );
                  }).toList(),
                  decoration: inputDecoration('Kategori'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Pilih kategori' : null,
                ),
              ),
              const SizedBox(height: 24),
              if (_selectedImage != null)
                Image.file(_selectedImage!, height: 150)
              else if (widget.product['gambar'] != null &&
                  widget.product['gambar'].toString().isNotEmpty)
                Image.network(
                    'http://192.168.1.10/nindo/' + widget.product['gambar'],
                    height: 150),
              const SizedBox(height: 8),
ElevatedButton.icon(
  onPressed: () {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Ambil Foto dengan Kamera"),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("Pilih dari Galeri"),
                onTap: () {
                  _pickImage(ImageSource.gallery); // Use the gallery
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  },
  icon: const Icon(Icons.image),
  label: const Text("Ganti Gambar"),
),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitEdit,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
                child: const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
