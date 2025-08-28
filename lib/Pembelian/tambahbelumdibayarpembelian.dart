import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hayami_app/Pembelian/detailpembelian.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// Model Item untuk data produk yang ditambahkan
class Item {
  final String product;
  final int quantity;
  final double price;
  final double discountRp;
  final double discountPercent;

  Item({
    required this.product,
    required this.quantity,
    required this.price,
    required this.discountRp,
    required this.discountPercent,
  });

  double get subtotal => quantity * price;

  double get totalDiscount =>
      (discountRp * quantity) + (discountPercent / 100) * subtotal;

  double get total => (subtotal - totalDiscount).clamp(0, double.infinity);
}

class TambahTagihanPage extends StatefulWidget {
  const TambahTagihanPage({super.key});

  @override
  State<TambahTagihanPage> createState() => _TambahTagihanPageState();
}

class _TambahTagihanPageState extends State<TambahTagihanPage> {
  List<Item> items = [];
  String? selectedSupplier;
  DateTime selectedDate = DateTime.now();

  final TextEditingController diskonRpController =
      TextEditingController(text: '0');
  final TextEditingController diskonPersenController =
      TextEditingController(text: '0');

  double get subtotalItems {
    return items.fold(0, (sum, item) => sum + item.total);
  }

  Future<void> _simpanTagihanKeServer() async {
    // Ambil id_user dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getString('id_user');

    if (idUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User tidak ditemukan. Silakan login ulang.')),
      );
      return;
    }

    const url = 'http://192.168.1.10/nindo/tambahstock.php?action=save_po';

    final data = {
      "id_user": idUser, // <-- id_user ditambahkan di sini
      "tgl_po": selectedDate.toIso8601String(),
      "id_supplier": selectedSupplier,
      "disc_nominal":
          double.tryParse(diskonRpController.text.replaceAll('.', '')) ?? 0,
      "disc_persen":
          double.tryParse(diskonPersenController.text.replaceAll('.', '')) ?? 0,
      "net_total": totalTagihan,
      "items": items
          .map((item) => {
                "id_bahan": item.product,
                "qty": item.quantity,
                "harga": item.price,
                "total": item.total,
                "disc_nominal": item.discountRp,
                "disc_persen": item.discountPercent,
              })
          .toList(),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      final result = json.decode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        final invoice = result['invoice'];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPembelian(invoice: invoice),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Gagal simpan: ${result['error'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error koneksi: $e')),
      );
    }
  }

  double get totalDiskonTagihan {
    final diskonRp =
        double.tryParse(diskonRpController.text.replaceAll('.', '')) ?? 0;
    final diskonPersen =
        double.tryParse(diskonPersenController.text.replaceAll('.', '')) ?? 0;
    double diskonPercentValue = (diskonPersen / 100) * subtotalItems;
    double totalDiskon = diskonRp + diskonPercentValue;
    return totalDiskon.clamp(0, subtotalItems);
  }

  double get totalTagihan {
    return (subtotalItems - totalDiskonTagihan).clamp(0, double.infinity);
  }

  void _tambahItem() async {
    final result = await Navigator.push<Item>(
      context,
      MaterialPageRoute(builder: (_) => const TambahItemPage()),
    );
    if (result != null) {
      setState(() {
        items.add(result);
      });
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    diskonRpController.dispose();
    diskonPersenController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    diskonRpController.addListener(() => setState(() {}));
    diskonPersenController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Tagihan'),
        centerTitle: true,
        leading: const CloseButton(),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        elevation: 3,
      ),
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSupplierField(),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Tanggal Transaksi',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        controller: TextEditingController(
                            text:
                                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (items.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Dismissible(
                      key: Key(item.product + index.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        setState(() {
                          items.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Item "${item.product}" dihapus')),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: ListTile(
                          leading: const Icon(Icons.shopping_bag,
                              color: Colors.indigo),
                          title: Text(item.product),
                          subtitle: Text(
                            'Qty: ${item.quantity}, Harga: ${currencyFormatter.format(item.price)}\n'
                            'Diskon: ${currencyFormatter.format(item.discountRp * item.quantity)}, '
                            '${item.discountPercent.toStringAsFixed(0)}%\n'
                            'Total: ${currencyFormatter.format(item.total)}',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                items.removeAt(index);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Item "${item.product}" dihapus')),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ElevatedButton.icon(
            onPressed: _tambahItem,
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            label: const Text(
              'Tambah Item',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade700,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 16),
              elevation: 4,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Subtotal'),
                    trailing: Text(
                      currencyFormatter.format(subtotalItems),
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: diskonRpController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      RupiahInputFormatter(), // Tambahkan ini
                    ],
                    decoration: InputDecoration(
                      labelText: 'Diskon (Rp)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.money_off),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: diskonPersenController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Diskon (%)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.percent),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: const Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      currencyFormatter.format(totalTagihan),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              if (selectedSupplier == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Pilih supplier terlebih dahulu')),
                );
                return;
              }
              if (items.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tambahkan minimal satu item')),
                );
                return;
              }

              _simpanTagihanKeServer(); // Kirim ke server
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade900,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 5,
              textStyle: const TextStyle(fontSize: 18),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierField() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (_) => const PilihSupplierPage()),
        );
        if (result != null) {
          setState(() {
            selectedSupplier = result;
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Supplier',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          controller: TextEditingController(text: selectedSupplier),
        ),
      ),
    );
  }
}

class TambahItemPage extends StatefulWidget {
  const TambahItemPage({super.key});

  @override
  State<TambahItemPage> createState() => _TambahItemPageState();
}

class _TambahItemPageState extends State<TambahItemPage> {
  String? selectedProduct;
  final TextEditingController kuantitasController =
      TextEditingController(text: '1');
  final TextEditingController hargaController =
      TextEditingController(text: '0');
  final TextEditingController diskonRpController =
      TextEditingController(text: '0');
  final TextEditingController diskonPersenController =
      TextEditingController(text: '0');

  double total = 0;

  @override
  void initState() {
    super.initState();
    kuantitasController.addListener(_hitungTotal);
    hargaController.addListener(_hitungTotal);
    diskonRpController.addListener(_hitungTotal);
    diskonPersenController.addListener(_hitungTotal);
  }

  void _hitungTotal() {
    final int kuantitas =
        int.tryParse(kuantitasController.text.replaceAll('.', '')) ?? 0;
    final double harga =
        double.tryParse(hargaController.text.replaceAll('.', '')) ?? 0;
    final double diskonRp =
        double.tryParse(diskonRpController.text.replaceAll('.', '')) ?? 0;
    final double diskonPersen =
        double.tryParse(diskonPersenController.text.replaceAll('.', '')) ?? 0;

    double subtotal = kuantitas * harga;
    double totalDiskon =
        (diskonRp * kuantitas) + ((diskonPersen / 100) * subtotal);
    double hasil = subtotal - totalDiskon;

    setState(() {
      total = hasil < 0 ? 0 : hasil;
    });
  }

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  Widget _buildTextField(String label, TextEditingController controller,
      {IconData? icon, Widget? suffix, Color? color}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        RupiahInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffix: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        labelStyle: TextStyle(color: color),
      ),
    );
  }

  @override
  void dispose() {
    kuantitasController.dispose();
    hargaController.dispose();
    diskonRpController.dispose();
    diskonPersenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Item'),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        elevation: 3,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (_) => const PilihProdukPage()),
              );
              if (result != null) {
                setState(() {
                  selectedProduct = result;
                });
              }
            },
            child: AbsorbPointer(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Produk',
                  prefixIcon: const Icon(Icons.shopping_bag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                controller: TextEditingController(text: selectedProduct),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField('Kuantitas', kuantitasController),
          const SizedBox(height: 16),
          _buildTextField('Harga', hargaController, color: Colors.indigo),
          const SizedBox(height: 16),
          _buildTextField('Diskon', diskonRpController,
              icon: Icons.local_offer, suffix: const Text('Rp')),
          const SizedBox(height: 16),
          _buildTextField('Diskon', diskonPersenController,
              icon: Icons.local_offer, suffix: const Text('%')),
          const SizedBox(height: 30),
          ListTile(
            title: const Text('Total'),
            trailing: Text(
              currencyFormatter.format(total),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              if (selectedProduct == null || selectedProduct!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pilih produk terlebih dahulu')),
                );
                return;
              }

              final int kuantitas =
                  int.tryParse(kuantitasController.text.replaceAll('.', '')) ??
                      0;
              if (kuantitas <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kuantitas harus lebih dari 0')),
                );
                return;
              }

              final double harga =
                  double.tryParse(hargaController.text.replaceAll('.', '')) ??
                      0;
              if (harga <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Harga harus lebih dari 0')),
                );
                return;
              }

              final double diskonRp = double.tryParse(
                      diskonRpController.text.replaceAll('.', '')) ??
                  0;
              final double diskonPersen = double.tryParse(
                      diskonPersenController.text.replaceAll('.', '')) ??
                  0;

              final item = Item(
                product: selectedProduct!,
                quantity: kuantitas,
                price: harga,
                discountRp: diskonRp,
                discountPercent: diskonPersen,
              );

              Navigator.pop(context, item);
            },
             style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 5,
              textStyle: const TextStyle(fontSize: 18),
            ),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}

class PilihSupplierPage extends StatefulWidget {
  const PilihSupplierPage({super.key});

  @override
  State<PilihSupplierPage> createState() => _PilihSupplierPageState();
}

class _PilihSupplierPageState extends State<PilihSupplierPage> {
  List<String> suppliers = [];
  List<String> filteredSuppliers = [];
  bool isLoading = true;
  String? error;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSuppliers();

    searchController.addListener(() {
      filterSuppliers();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchSuppliers() async {
    const url =
        'http://192.168.1.10/nindo/tambahstock.php?action=suppliers_products';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List suppliersData = data["suppliers"];

        setState(() {
          suppliers = suppliersData
              .map<String>((item) => item["nm_supp"].toString())
              .toList();
          filteredSuppliers = suppliers;
          isLoading = false;
        });
      } else {
        setState(() {
          error =
              'Failed to load suppliers. Status code: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void filterSuppliers() {
    final query = searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredSuppliers = suppliers;
      } else {
        filteredSuppliers = suppliers
            .where((supplier) => supplier.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pilih Supplier')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pilih Supplier')),
        body: Center(child: Text(error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Supplier'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Cari Supplier',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredSuppliers.isNotEmpty
                ? ListView.builder(
                    itemCount: filteredSuppliers.length,
                    itemBuilder: (context, index) {
                      final supplier = filteredSuppliers[index];
                      return ListTile(
                        title: Text(supplier),
                        onTap: () => Navigator.pop(context, supplier),
                      );
                    },
                  )
                : const Center(child: Text('Supplier tidak ditemukan')),
          ),
        ],
      ),
    );
  }
}

class PilihProdukPage extends StatefulWidget {
  const PilihProdukPage({super.key});

  @override
  State<PilihProdukPage> createState() => _PilihProdukPageState();
}

class _PilihProdukPageState extends State<PilihProdukPage> {
  List<String> products = [];
  List<String> filteredProducts = [];
  bool isLoading = true;
  String? error;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();

    searchController.addListener(() {
      filterProducts();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    const url =
        'http://192.168.1.10/nindo/tambahstock.php?action=suppliers_products';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List productsData = data["products"];

        setState(() {
          products = productsData
              .map<String>((item) => item["nm_product"].toString())
              .toList();
          filteredProducts = products;
          isLoading = false;
        });
      } else {
        setState(() {
          error =
              'Failed to load products. Status code: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void filterProducts() {
    final query = searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredProducts = products;
      } else {
        filteredProducts = products
            .where((product) => product.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pilih Produk')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pilih Produk')),
        body: Center(child: Text(error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Produk'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Cari Produk',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredProducts.isNotEmpty
                ? ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ListTile(
                        title: Text(product),
                        onTap: () => Navigator.pop(context, product),
                      );
                    },
                  )
                : const Center(child: Text('Produk tidak ditemukan')),
          ),
        ],
      ),
    );
  }
}

class RupiahInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String cleaned = newValue.text.replaceAll('.', '');

    if (cleaned.isEmpty) return newValue.copyWith(text: '');

    int value = int.tryParse(cleaned) ?? 0;
    String newText = _formatter.format(value);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
