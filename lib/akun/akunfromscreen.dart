import 'package:flutter/material.dart';

class AkunFormScreen extends StatefulWidget {
  final String nama;
  final String kode;
  final String kategori;

  const AkunFormScreen({
    super.key,
    required this.nama,
    required this.kode,
    required this.kategori,
  });

  @override
  State<AkunFormScreen> createState() => _AkunFormScreenState();
}

class _AkunFormScreenState extends State<AkunFormScreen> {
  late TextEditingController _namaController;
  late TextEditingController _kodeController;
  String selectedKategori = 'Kas & Bank';
  String? selectedSubAkun;

  final List<String> kategoriList = [
    'Kas & Bank',
    'Akun Piutang',
    'Persediaan',
    'Lainnya',
  ];

  final List<String> subAkunList = [
    'Tidak Ada',
    'Kas',
    'Piutang Usaha',
    'Persediaan Barang',
  ];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.nama);
    _kodeController = TextEditingController(text: widget.kode);
    selectedKategori = widget.kategori;
    selectedSubAkun = 'Tidak Ada';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kodeController.dispose();
    super.dispose();
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.grey),
            border: const UnderlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    final isDisabled = onChanged == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey[200] : Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: isDisabled
                ? []
                : const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              onChanged: onChanged,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      color: isDisabled ? Colors.grey : Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget buildSubAkunField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.menu_book_outlined, color: Colors.black45),
            SizedBox(width: 10),
            Text("Sub Akun dari", style: TextStyle(color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(thickness: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text("Ubah Akun"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            buildTextField(
              label: "Nama",
              controller: _namaController,
              icon: Icons.description,
            ),
            buildTextField(
              label: "Kode",
              controller: _kodeController,
              icon: Icons.qr_code,
            ),
            buildDropdownField(
              label: 'Kategori',
              value: selectedKategori,
              items: kategoriList,
              onChanged: null, // disabled
            ),
            buildSubAkunField(),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // TODO: Simpan logika di sini
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text("Simpan", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
