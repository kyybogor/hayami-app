import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hayami_app/Pembelian/detailpembelian.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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

  List<String> supplierNames = [];
  bool suppliersLoaded = false;

  final TextEditingController diskonRpController =
      TextEditingController(text: '0');
  final TextEditingController diskonPersenController =
      TextEditingController(text: '0');

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    diskonRpController.addListener(() => setState(() {}));
    diskonPersenController.addListener(() => setState(() {}));
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.1.20/nindo/tambahstock.php?action=suppliers_products'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List suppliers = data["suppliers"] ?? [];
        setState(() {
          supplierNames =
              suppliers.map<String>((s) => s["nm_supp"].toString()).toList();
          suppliersLoaded = true;
        });
      }
    } catch (e) {
      setState(() => suppliersLoaded = true);
    }
  }

  double get subtotalItems {
    return items.fold(0, (sum, item) => sum + item.total);
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

  Future<void> _simpanTagihanKeServer() async {
    final prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getString('id_user');

    if (idUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User tidak ditemukan. Silakan login ulang.')),
      );
      return;
    }

    const url = 'http://192.168.1.20/nindo/tambahstock.php?action=save_po';

    final data = {
      "id_user": idUser,
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

  Widget _buildSupplierField() {
    if (!suppliersLoaded)
      return const Center(child: CircularProgressIndicator());
    if (supplierNames.isEmpty) return const Text("Gagal load supplier");

    return InlineAutocomplete(
      options: supplierNames,
      initialValue: selectedSupplier,
      onSelected: (value) {
        setState(() {
          selectedSupplier = value;
        });
      },
      label: 'Supplier',
      icon: Icons.person,
    );
  }

  @override
  void dispose() {
    diskonRpController.dispose();
    diskonPersenController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      Navigator.pop(context, true);
      return false;
    },
    child: Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text(
              'Tambah Tagihan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
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
                          text: "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                        ),
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
              children: items
                  .asMap()
                  .entries
                  .map((entry) => _buildItemCard(entry.key, entry.value))
                  .toList(),
            ),
          ElevatedButton.icon(
            onPressed: _tambahItem,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Tambah Item',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade700,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontSize: 16),
              elevation: 4,
            ),
          ),
          const SizedBox(height: 10),
          _buildSummaryCard(),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              if (selectedSupplier == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pilih supplier terlebih dahulu')),
                );
                return;
              }
              if (items.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tambahkan minimal satu item')),
                );
                return;
              }
              _simpanTagihanKeServer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade900,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 5,
              textStyle: const TextStyle(fontSize: 18),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildItemCard(int index, Item item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
              SnackBar(content: Text('Item "${item.product}" dihapus')));
        },
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: ListTile(
            leading: const Icon(Icons.shopping_bag, color: Colors.indigo),
            title: Text(item.product),
            subtitle: Text(
              'Qty: ${item.quantity}, Harga: ${currencyFormatter.format(item.price)}\n'
              'Diskon: ${currencyFormatter.format(item.discountRp * item.quantity)}, '
              '${item.discountPercent.toStringAsFixed(0)}%\n'
              'Total: ${currencyFormatter.format(item.total)}',
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                setState(() {
                  items.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Item "${item.product}" dihapus')));
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                RupiahInputFormatter(),
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.percent),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Total',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
  List<String> productNames = [];
  bool productsLoaded = false;

  final TextEditingController kuantitasController =
      TextEditingController(text: '1');
  final TextEditingController hargaController =
      TextEditingController(text: '0');
  final TextEditingController diskonRpController =
      TextEditingController(text: '0');
  final TextEditingController diskonPersenController =
      TextEditingController(text: '0');

  double total = 0;

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    kuantitasController.addListener(_hitungTotal);
    hargaController.addListener(_hitungTotal);
    diskonRpController.addListener(_hitungTotal);
    diskonPersenController.addListener(_hitungTotal);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.1.20/nindo/tambahstock.php?action=suppliers_products'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List products = data["products"] ?? [];
        setState(() {
          productNames =
              products.map<String>((p) => p["nm_product"].toString()).toList();
          productsLoaded = true;
        });
      }
    } catch (e) {
      setState(() => productsLoaded = true);
    }
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          productsLoaded
              ? InlineAutocomplete(
                  options: productNames,
                  initialValue: selectedProduct,
                  onSelected: (value) {
                    setState(() {
                      selectedProduct = value;
                    });
                  },
                  label: 'Produk',
                  icon: Icons.shopping_bag,
                )
              : const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 16),
          _buildTextField('Qty', kuantitasController,
              icon: Icons.format_list_numbered),
          const SizedBox(height: 16),
          _buildTextField('Harga', hargaController, icon: Icons.money),
          const SizedBox(height: 16),
          _buildTextField('Diskon Rp', diskonRpController,
              icon: Icons.money_off),
          const SizedBox(height: 16),
          _buildTextField('Diskon %', diskonPersenController,
              icon: Icons.percent),
          const SizedBox(height: 16),
          Text(
            'Total: ${currencyFormatter.format(total)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (selectedProduct == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pilih produk terlebih dahulu')),
                );
                return;
              }
              final int kuantitas =
                  int.tryParse(kuantitasController.text.replaceAll('.', '')) ??
                      0;
              final double harga =
                  double.tryParse(hargaController.text.replaceAll('.', '')) ??
                      0;
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
              backgroundColor: Colors.indigo.shade900,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 5,
              textStyle: const TextStyle(fontSize: 18),
            ),
            child: const Text(
              'Tambah',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String clean = newValue.text.replaceAll('.', '');
    if (clean.isEmpty) clean = '0';
    int value = int.tryParse(clean) ?? 0;
    final formatted = NumberFormat('#,###', 'id_ID').format(value);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class InlineAutocomplete extends StatefulWidget {
  final List<String> options;
  final String? initialValue;
  final ValueChanged<String> onSelected;
  final String label;
  final IconData? icon;

  const InlineAutocomplete({
    super.key,
    required this.options,
    required this.onSelected,
    this.initialValue,
    required this.label,
    this.icon,
  });

  @override
  State<InlineAutocomplete> createState() => _InlineAutocompleteState();
}

class _InlineAutocompleteState extends State<InlineAutocomplete> {
  final TextEditingController _controller = TextEditingController();
  List<String> filteredOptions = [];
  bool showOptions = false;
  bool hasSelected = false; 
  
  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue ?? '';

    _controller.addListener(() {
      final text = _controller.text;

      if (hasSelected) {
        setState(() {
          showOptions = false;
        });
        return;
      }

      if (text.isEmpty) {
        setState(() {
          filteredOptions = [];
          showOptions = false;
        });
      } else {
        setState(() {
          filteredOptions = widget.options
              .where((o) => o.toLowerCase().contains(text.toLowerCase()))
              .take(4)
              .toList();
          showOptions = filteredOptions.isNotEmpty;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.label,
            prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onChanged: (value) {
            if (hasSelected) {
              setState(() {
                hasSelected = false;
              });
            }
          },
        ),
        if (showOptions)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: ListView(
              shrinkWrap: true,
              children: filteredOptions
                  .map((e) => ListTile(
                        title: Text(e),
                        onTap: () {
                          _controller.text = e;
                          widget.onSelected(e);
                          setState(() {
                            hasSelected = true;
                            showOptions = false; 
                          });
                        },
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

