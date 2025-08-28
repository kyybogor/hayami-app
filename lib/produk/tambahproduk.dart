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
    final url = Uri.parse('http://192.168.1.20/nindo/kategori.php');
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
  if (_formKey.currentState!.validate()) {
    if (_selectedKategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori harus dipilih')),
      );
      return;
    }

    final url = Uri.parse('http://192.168.1.20/nindo/tambah_produk.php');
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
  InputDecoration inputDecoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextFormField(
          controller: controller,
          decoration: inputDecoration(label, icon),
          keyboardType: keyboardType,
          validator: validator,
        ),
      );

  return Scaffold(
    appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Tambah Produk",
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Produk',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    buildTextField(
                      controller: _namaController,
                      label: 'Nama Produk',
                      icon: Icons.label,
                      validator: (v) => (v == null || v.isEmpty) ? 'Masukkan nama produk' : null,
                    ),
                    buildTextField(
                      controller: _hargaController,
                      label: 'Harga Jual',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (v) => null,
                    ),
                    buildTextField(
                      controller: _minimController,
                      label: 'Minimal Stok',
                      icon: Icons.remove_circle_outline,
                      keyboardType: TextInputType.number,
                      validator: (v) => null,
                    ),
                    buildTextField(
                      controller: _maximController,
                      label: 'Maksimal Stok',
                      icon: Icons.add_circle_outline,
                      keyboardType: TextInputType.number,
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: inputDecoration('Pilih Kategori', Icons.category),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Gambar Produk',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Tap untuk memilih gambar'),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Simpan Produk'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submitProduk,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}
