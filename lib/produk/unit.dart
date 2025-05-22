import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: KonversiSatuanPage(),
    debugShowCheckedModeBanner: false,
  ));
}

// Model untuk menyimpan data konversi
class KonversiData {
  final String satuan;
  final String leftQty;
  final String rightQty;

  KonversiData({
    required this.satuan,
    required this.leftQty,
    required this.rightQty,
  });
}

// ===================== KonversiSatuanPage =====================
class KonversiSatuanPage extends StatefulWidget {
  const KonversiSatuanPage({super.key});

  @override
  State<KonversiSatuanPage> createState() => _KonversiSatuanPageState();
}

class _KonversiSatuanPageState extends State<KonversiSatuanPage> {
  List<KonversiData> konversiList = [];

  void _navigateToTambahKonversi() async {
    final result = await Navigator.push<KonversiData>(
      context,
      MaterialPageRoute(builder: (_) => const TambahKonversiPage()),
    );

    if (result != null) {
      setState(() {
        konversiList.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Satuan'),
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: konversiList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Data tidak ditemukan',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: konversiList.length,
              itemBuilder: (context, index) {
                final item = konversiList[index];
                return ListTile(
                  title: Text('${item.leftQty} ${item.satuan} = ${item.rightQty} Pcs'),
                  onTap: () async {
                    final result = await Navigator.push<KonversiData>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditKonversiPage(konversiData: item),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        konversiList[index] = result;
                      });
                    }
                  },
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(); // Pemisah antar list item
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToTambahKonversi,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text('Simpan', style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ),
    );
  }
}

// ===================== TambahKonversiPage =====================
class TambahKonversiPage extends StatefulWidget {
  const TambahKonversiPage({super.key});

  @override
  State<TambahKonversiPage> createState() => _TambahKonversiPageState();
}

class _TambahKonversiPageState extends State<TambahKonversiPage> {
  String? selectedUnit;
  List<String> units = ['Dus', 'Box', 'Kg'];
  final TextEditingController hargaBeliController =
      TextEditingController(text: '299000');
  final TextEditingController hargaJualController =
      TextEditingController(text: '499000');

  final TextEditingController leftQtyController =
      TextEditingController(text: '1');
  final TextEditingController rightQtyController =
      TextEditingController(text: '1');

  void _showAddUnitDialog() {
    final TextEditingController newUnitController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Satuan'),
        content: TextField(
          controller: newUnitController,
          decoration: const InputDecoration(hintText: 'Masukkan nama satuan'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final newUnit = newUnitController.text.trim();
              if (newUnit.isNotEmpty) {
                setState(() {
                  units.add(newUnit);
                  selectedUnit = newUnit;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Konversi Satuan'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 40,
                  child: Text(
                    '1',  // Angka 1 ini tidak bisa diubah
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey[100],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedUnit,
                        hint: const Text('Pilih Satuan'),
                        isExpanded: true,
                        onChanged: (value) {
                          if (value == 'Tambah Satuan...') {
                            _showAddUnitDialog();
                          } else {
                            setState(() {
                              selectedUnit = value;
                            });
                          }
                        },
                        items: [
                          ...units.map((u) => DropdownMenuItem(
                                value: u,
                                child: Text(u),
                              )),
                          const DropdownMenuItem(
                            value: 'Tambah Satuan...',
                            child: Text(
                              'Tambah Satuan...',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('='), // Simbol "="
                const SizedBox(width: 12),
                SizedBox(
                  width: 40,
                  child: TextField(
                    controller: rightQtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Pcs', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Harga Beli', style: TextStyle(fontSize: 16)),
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: hargaBeliController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: 'Rp',
                      border: InputBorder.none,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Harga Jual', style: TextStyle(fontSize: 16)),
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: hargaJualController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: 'Rp',
                      border: InputBorder.none,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            final konversi = KonversiData(
              satuan: selectedUnit ?? '',
              leftQty: leftQtyController.text,
              rightQty: rightQtyController.text,
            );

            Navigator.pop(context, konversi);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text('Simpan', style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ),
    );
  }
}

// ===================== EditKonversiPage =====================
class EditKonversiPage extends StatefulWidget {
  final KonversiData konversiData;

  const EditKonversiPage({super.key, required this.konversiData});

  @override
  State<EditKonversiPage> createState() => _EditKonversiPageState();
}

class _EditKonversiPageState extends State<EditKonversiPage> {
  String? selectedUnit;
  List<String> units = ['Dus', 'Box', 'Kg'];
  final TextEditingController hargaBeliController =
      TextEditingController(text: '299000');
  final TextEditingController hargaJualController =
      TextEditingController(text: '499000');

  final TextEditingController leftQtyController =
      TextEditingController();
  final TextEditingController rightQtyController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedUnit = widget.konversiData.satuan;
    leftQtyController.text = widget.konversiData.leftQty;
    rightQtyController.text = widget.konversiData.rightQty;
  }

  void _showAddUnitDialog() {
    final TextEditingController newUnitController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Satuan'),
        content: TextField(
          controller: newUnitController,
          decoration: const InputDecoration(hintText: 'Masukkan nama satuan'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final newUnit = newUnitController.text.trim();
              if (newUnit.isNotEmpty) {
                setState(() {
                  units.add(newUnit);
                  selectedUnit = newUnit;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Konversi Satuan'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 40,
                  child: Text(
                    '1',  // Angka 1 ini tidak bisa diubah
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey[100],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedUnit,
                        hint: const Text('Pilih Satuan'),
                        isExpanded: true,
                        onChanged: (value) {
                          if (value == 'Tambah Satuan...') {
                            _showAddUnitDialog();
                          } else {
                            setState(() {
                              selectedUnit = value;
                            });
                          }
                        },
                        items: [
                          ...units.map((u) => DropdownMenuItem(
                                value: u,
                                child: Text(u),
                              )),
                          const DropdownMenuItem(
                            value: 'Tambah Satuan...',
                            child: Text(
                              'Tambah Satuan...',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('='), // Simbol "="
                const SizedBox(width: 12),
                SizedBox(
                  width: 40,
                  child: TextField(
                    controller: rightQtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Pcs', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Harga Beli', style: TextStyle(fontSize: 16)),
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: hargaBeliController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: 'Rp',
                      border: InputBorder.none,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Harga Jual', style: TextStyle(fontSize: 16)),
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: hargaJualController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: 'Rp',
                      border: InputBorder.none,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            final konversi = KonversiData(
              satuan: selectedUnit ?? '',
              leftQty: leftQtyController.text,
              rightQty: rightQtyController.text,
            );

            Navigator.pop(context, konversi);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text('Simpan', style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ),
    );
  }
}
