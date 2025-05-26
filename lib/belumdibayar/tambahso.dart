import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesOrderPage extends StatefulWidget {
  @override
  _SalesOrderPageState createState() => _SalesOrderPageState();
}

class _SalesOrderPageState extends State<SalesOrderPage> {
  final List<String> products = [
    '1.2L Bening',
    '600ml Aqua',
    'Gallon Le Minerale'
  ];
  final List<Map<String, dynamic>> orderItems = [];

  String? selectedProduct;
  int quantity = 1;
  double price = 0;
  double discount = 0;
  bool isProductSaved = false;

  String customerName = '';
  String customerPhone = '';
  String customerAddress = '';

  double get subtotal => orderItems.fold(0, (sum, item) => sum + item['total']);
  double get ppn => subtotal * 0.11;
  double get netTotal => subtotal + ppn;

  void addItem() {
    setState(() {
      final total = quantity * price * (1 - discount / 100);
      orderItems.add({
        'product': selectedProduct!,
        'qty': quantity,
        'price': price,
        'disc': discount,
        'total': total,
      });
      selectedProduct = null;
      quantity = 1;
      price = 0;
      discount = 0;
    });
  }

  void saveProducts() => setState(() => isProductSaved = true);

  void saveCustomerData() => print('Customer/Supplier Saved');

  InputDecoration inputDecoration({required String label, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );

  Widget buildCard({required Widget child}) => Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFF8F9FF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: child,
      );

  Widget productInputSection() {
    return buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle("Tambah Produk"),
          DropdownButtonFormField<String>(
            value: selectedProduct,
            decoration: inputDecoration(
                label: "Pilih Produk", icon: Icons.shopping_cart),
            items: products
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (val) => setState(() => selectedProduct = val),
          ),
          SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: TextFormField(
              decoration: inputDecoration(label: "Qty", icon: Icons.numbers),
              keyboardType: TextInputType.number,
              onChanged: (val) => quantity = int.tryParse(val) ?? 1,
            )),
            SizedBox(width: 10),
            Expanded(
                child: TextFormField(
              decoration:
                  inputDecoration(label: "Harga", icon: Icons.price_change),
              keyboardType: TextInputType.number,
              onChanged: (val) => price = double.tryParse(val) ?? 0,
            )),
          ]),
          SizedBox(height: 10),
          TextFormField(
            decoration:
                inputDecoration(label: "Diskon (%)", icon: Icons.percent),
            keyboardType: TextInputType.number,
            onChanged: (val) => discount = double.tryParse(val) ?? 0,
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: addItem,
            icon: Icon(Icons.add),
            label: Text("Tambah Produk"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2E3A87),
              foregroundColor:
                  Colors.white, // Mengatur warna teks dan ikon jadi putih
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              minimumSize: Size(double.infinity, 48),
            ),
          )
        ],
      ),
    );
  }

  Widget productCard(Map<String, dynamic> item, int index) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shopping_bag, color: Colors.indigo, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['product'],
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                    'Qty: ${item['qty']}, Harga: ${currencyFormat.format(item['price'])}'),
                Text(
                    'Diskon: ${currencyFormat.format(item['price'] * item['qty'] * item['disc'] / 100)}, ${item['disc']}%'),
                Text('Total: ${currencyFormat.format(item['total'])}'),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                orderItems.removeAt(index);
              });
            },
          )
        ],
      ),
    );
  }

  Widget orderCardListSection() {
    return buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle("Daftar Produk"),
          ...orderItems.asMap().entries.map((entry) {
            return productCard(entry.value, entry.key);
          }).toList(),
          SizedBox(height: 10),
          Text("Subtotal: Rp. ${subtotal.toStringAsFixed(0)}"),
          Text("PPN (11%): Rp. ${ppn.toStringAsFixed(0)}"),
          Text("Net Total: Rp. ${netTotal.toStringAsFixed(0)}"),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: saveProducts,
            child: Text("Simpan Produk"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2E3A87),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
  }

  Widget customerForm() {
    return buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle("Data Customer/Supplier"),
          TextFormField(
            decoration:
                inputDecoration(label: "Tanggal", icon: Icons.calendar_today),
            initialValue: DateFormat('dd/MM/yyyy').format(DateTime.now()),
            readOnly: true,
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: inputDecoration(
                label: "Nama Customer/Supplier", icon: Icons.person),
            onChanged: (val) => customerName = val,
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration:
                inputDecoration(label: "Bank", icon: Icons.account_balance),
            value: null,
            hint: Text("-- Pilih Bank --"),
            items: ['BCA', 'Mandiri', 'BRI']
                .map((bank) => DropdownMenuItem(value: bank, child: Text(bank)))
                .toList(),
            onChanged: (val) {},
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: inputDecoration(label: "Nama Ecer", icon: Icons.store),
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration:
                inputDecoration(label: "Sales Person", icon: Icons.badge),
            value: null,
            items: ['Admin 1', 'Admin 2']
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (val) {},
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration:
                inputDecoration(label: "Diskon (Rp)", icon: Icons.money_off),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: inputDecoration(label: "Tempo", icon: Icons.timelapse),
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: inputDecoration(label: "Catatan", icon: Icons.notes),
            maxLines: 3,
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: saveCustomerData,
            child: Text("Simpan Data"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2E3A87),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              minimumSize: Size(double.infinity, 48),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // Reset semua data jika perlu
                customerName = '';
                customerPhone = '';
                customerAddress = '';
                isProductSaved = false; // ini menyembunyikan form
              });
            },
            child: Text("Batal"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              minimumSize: Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2E3A87),
        title: Text("Tambah Tagihan"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            productInputSection(),
            if (orderItems.isNotEmpty) ...[
              SizedBox(height: 16),
              orderCardListSection(),
            ],
            if (isProductSaved) ...[
              SizedBox(height: 16),
              customerForm(),
            ],
          ],
        ),
      ),
    );
  }
}
