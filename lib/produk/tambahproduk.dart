import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class TambahProdukPage extends StatefulWidget {
  const TambahProdukPage({super.key});

  @override
  State<TambahProdukPage> createState() => _TambahProdukPageState();
}

// Model kategori
class Kategori {
  final String id;
  final String nama;

  Kategori({required this.id, required this.nama});

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id_kategori'],
      nama: json['nm_kategori'],
    );
  }
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _minimController = TextEditingController();
  final TextEditingController _maximController = TextEditingController();

  List<Kategori> _kategoriList = [];
  String? _selectedKategoriId;

  File? _selectedImage;
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    _fetchKategori();
  }

  Future<void> _fetchKategori() async {
    final url = Uri.parse('http://192.168.1.8/nindo2/kategori.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _kategoriList = data.map((json) => Kategori.fromJson(json)).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat kategori')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan jaringan')),
      );
    }
  }

  // Mengupdate fungsi _pickImage untuk menggunakan showModalBottomSheet
  Future<void> _pickImage() async {
    final picker = ImagePicker();

    // Menampilkan Modal Bottom Sheet untuk memilih media
    final pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Ambil Foto dengan Kamera"),
              onTap: () async {
                Navigator.pop(context, await picker.pickImage(source: ImageSource.camera));
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text("Pilih dari Galeri"),
              onTap: () async {
                Navigator.pop(context, await picker.pickImage(source: ImageSource.gallery));
              },
            ),
          ],
        ),
      ),
    );

    // Setelah memilih gambar, lakukan proses penyimpanan
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      final bytes = await pickedFile.readAsBytes();
      _base64Image = base64Encode(bytes);
    }
  }

  Future<void> _submitProduk() async {
    // Validasi untuk kolom gambar kosong
    if (_formKey.currentState!.validate()) {
      if (_selectedKategoriId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori harus dipilih')),
        );
        return;
      }

      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gambar produk harus dipilih')),
        );
        return;
      }

      final url = Uri.parse('http://192.168.1.8/nindo/tambah_produk.php');
      try {
        final response = await http.post(url, body: {
          'nm_product': _namaController.text,
          'gambar': _base64Image ?? '',
          'minim': _minimController.text,
          'maxim': _maximController.text,
          'price': _hargaController.text,
          'brand': _selectedKategoriId ?? '',
          'id_cabang': 'pusat',
        });

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produk berhasil ditambahkan')),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal menambahkan produk: ${data['message']}')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Terjadi kesalahan jaringan')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan saat mengirim data')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration inputDecoration(String label) => InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField(
                controller: _namaController,
                label: 'Nama Produk',
                validator: (v) => (v == null || v.isEmpty) ? 'Masukkan nama produk' : null,
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: _hargaController,
                label: 'Harga Jual',
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Masukkan harga jual' : null,
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: _minimController,
                label: 'Minimal Stok',
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Masukkan minimal stok' : null,
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: _maximController,
                label: 'Maksimal Stok',
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Masukkan maksimal stok' : null,
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String>(
                  decoration: inputDecoration('Pilih Kategori'),
                  value: _selectedKategoriId,
                  items: _kategoriList.map((kategori) {
                    return DropdownMenuItem<String>(
                      value: kategori.id,
                      child: Text(kategori.nama),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedKategoriId = value;
                    });
                  },
                  validator: (value) => value == null ? 'Pilih kategori produk' : null,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Gambar Produk:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 250, // Adjusted to allow larger image preview
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.contain, // Use BoxFit.contain to make sure image fits fully
                          ),
                        )
                      : const Center(child: Text('Tap untuk memilih gambar')),
                ),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: _submitProduk,
                  child: const Text('Simpan Produk'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
