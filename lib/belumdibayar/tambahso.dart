import 'package:flutter/material.dart';
import 'package:hayami_app/belumdibayar/detailpenjualan.dart';
import 'package:hayami_app/pajak/pajakpenjualan.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SalesOrderPage extends StatefulWidget {
  @override
  _SalesOrderPageState createState() => _SalesOrderPageState();
}

class _SalesOrderPageState extends State<SalesOrderPage> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  String? selectedProduct;
  int quantity = 1;
  double price = 0;
  double discount = 0;
  bool isProductSaved = false;
  String customerName = '';
  String customerPhone = '';
  String customerAddress = '';
  final List<Map<String, dynamic>> orderItems = [];
  TextEditingController discPercentController = TextEditingController();
TextEditingController ppnPercentController = TextEditingController();
TextEditingController ongkirController = TextEditingController();
TextEditingController kodeUnikController = TextEditingController();
TextEditingController qtyController = TextEditingController();
TextEditingController priceController = TextEditingController();
TextEditingController discountController = TextEditingController();
final NumberFormat rupiahFormat = NumberFormat.decimalPattern('id');
  TextEditingController productController = TextEditingController();
List<dynamic> customers = [];
List<dynamic> filteredCustomers = [];
List<dynamic> banks = [];
List<dynamic> salesList = [];

String? selectedCustomer;
String? selectedBank;
String? selectedSales;
String? selectedCustomerId;   // <-- buat simpan id_supp
String? selectedCustomerName; // <-- buat simpan nm_supp
TextEditingController customerController = TextEditingController();
TextEditingController ecerController = TextEditingController();
TextEditingController discRpController = TextEditingController();
TextEditingController tempoController = TextEditingController();
TextEditingController noteController = TextEditingController();
bool showCustomerForm = false;
List<Map<String, dynamic>> productList = [];
final TextEditingController tglSoController = TextEditingController();
  String? selectedProductId;
  String? selectedSalesId;    // dari dropdown sales
  String? selectedBankId;  
bool isFormValid() {
  return (selectedCustomerId != null &&
          selectedBankId != null &&
          selectedSales != null &&
          tempoController.text.isNotEmpty);
}

Future<void> fetchCustomers() async {
  final res = await http.get(Uri.parse('http://192.168.1.3/nindo/customer_mobile.php'));
  if (res.statusCode == 200) {
    List<dynamic> data = json.decode(res.body);
    print(data); // Tambahkan print untuk debug
    setState(() {
      customers = data;
    });
  }
}


Future<void> fetchBanks() async {
  final res = await http.get(Uri.parse('http://192.168.1.3/nindo/bank_mobile.php'));
  if (res.statusCode == 200) {
    List<dynamic> data = json.decode(res.body);
    setState(() {
      banks = data;
    });
  }
}

Future<void> fetchSales() async {
  final res = await http.get(Uri.parse('http://192.168.1.3/nindo/sales.php'));
  if (res.statusCode == 200) {
    List<dynamic> data = json.decode(res.body);
    setState(() {
      salesList = data;
    });
  }
}

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('http://192.168.1.3/nindo/product.php/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        // Filter produk yang qty lebih dari 0
        products = data.where((product) => int.parse(product['qty']) > 0).toList();
      });
    } else {
      throw Exception('Gagal memuat data produk');
    }
  }
  
Future<void> saveCustomerData() async {
  final prefs = await SharedPreferences.getInstance();
  final idUser = prefs.getString('id_user');

  if (idUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User tidak ditemukan. Silakan login ulang.')),
    );
    return;
  }

  try {
    final now = DateTime.now();
    final dibuatTgl = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    DateTime baseDate;
    try {
      baseDate = DateFormat("yyyy-MM-dd").parse(tglSoController.text);
    } catch (_) {
      baseDate = DateTime.now();
    }
    final tglTempo = DateFormat("yyyy-MM-dd").format(
      baseDate.add(Duration(days: int.tryParse(tempoController.text) ?? 0)),
    );

    final so1 = {
      "tgl_so": tglSoController.text,
      "id_customer": selectedCustomerId ?? "",
      "disc_nominal": discRpController.text,
      "disc_persen": discPercentController.text,
      "ppn_persen": ppnPercentController.text,
      "net_total": _hitungNetTotal().toStringAsFixed(0),
      "hutang": _hitungNetTotal().toStringAsFixed(0),
      "dibuat_oleh": idUser,
      "dibuat_tgl": dibuatTgl,
      "status": "1",
      "ket": noteController.text,
      "ongkir": ongkirController.text.replaceAll('.', ''),
      "kode_unik": (int.tryParse(kodeUnikController.text) ?? 0).toString(),
      "no_batch": "1",
      "tempo": tempoController.text,
      "tgl_tempo": tglTempo,
      "salesperson": selectedSalesId ?? (selectedSales ?? ""),
      "id_bank": selectedBankId ?? "",
    };

    final List<Map<String, dynamic>> so2 = orderItems.map((item) {
      final totalPrice  = (item['price'] as num) * (item['qty'] as num);
      final discPercent = (item['disc'] as num);
      final discNominal = (totalPrice * (discPercent / 100)).round();

      return {
        "id_product": item['id_product'].toString(),
        "qty": (item['qty'] as num).toString(),
        "harga": (item['price'] as num).toStringAsFixed(0),
        "total": (totalPrice - discNominal).toStringAsFixed(0),
        "disc_nominal": discNominal.toString(),
        "disc_persen": discPercent.toString(),
        "jenis": "stock",
      };
    }).toList();

    final body = jsonEncode({"so1": so1, "so2": so2});
    final url = Uri.parse("http://192.168.1.20/nindo/input_so_mobile.php");
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: body);

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
if (result['success'] == true && result['invoice'] != null) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DetailPenjualan(invoice: result['invoice']),
    ),
  );
} else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: ${result['message']}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server error: ${response.statusCode}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}

// fungsi kecil untuk hitung net total biar ringkas
double _hitungNetTotal() {
  double total = 0;
  for (var item in orderItems) {
    total += (item['price'] * item['qty']) * (1 - item['disc'] / 100);
  }
  double discPercent = double.tryParse(discPercentController.text) ?? 0;
  double discRp = total * (discPercent / 100);
  double ppnPercent = double.tryParse(ppnPercentController.text) ?? 0;
  double ppnRp = (total - discRp) * (ppnPercent / 100);
  double ongkir = double.tryParse(ongkirController.text.replaceAll('.', '')) ?? 0;
  return (total - discRp) + ppnRp + ongkir;
}


void filterCustomers(String query) {
  final filtered = customers.where((c) {
    final name = c['nm_supp'].toLowerCase();
    return name.contains(query.toLowerCase());
  }).take(4).toList();

  print(filtered); // Tambahkan ini untuk debug
  setState(() {
    filteredCustomers = filtered;
  });
}

void selectCustomer(String name) {
  setState(() {
    selectedCustomer = name;
    customerController.text = name;
    filteredCustomers = [];
  });
}

void resetForm() {
  setState(() {
    // kosongkan semua text controller
    tglSoController.clear();
    customerController.clear();
    ecerController.clear();
    discRpController.clear();
    discPercentController.clear();
    ppnPercentController.text = "11";
    ongkirController.clear();
    kodeUnikController.clear();
    tempoController.clear();
    noteController.clear();

    // kosongkan pilihan dropdown/autocomplete
    selectedCustomerId = null;
    selectedCustomerName = null;
    selectedBankId = null;
    selectedSales = null;
    selectedSalesId = null;

    // kosongkan produk order
    orderItems.clear();

    // set tanggal default hari ini biar ga kosong
    tglSoController.text = DateFormat("yyyy-MM-dd").format(DateTime.now());
  });
}

  // Fungsi untuk menyaring produk berdasarkan input pencarian
  void filterProducts(String query) {
    final filtered = products.where((product) {
      final name = product['nm_product'].toLowerCase();
      return name.contains(query.toLowerCase()); // Cek jika nama produk mengandung query
    }).take(4).toList(); // Batasi hanya 4 produk yang ditampilkan

    setState(() {
      filteredProducts = filtered;
    });
  }

  // Fungsi untuk memilih produk dari daftar yang terfilter
  void selectProduct(String productName) {
  final selected = products.firstWhere((p) => p['nm_product'] == productName);
  setState(() {
    selectedProduct = productName;
    selectedProductId = selected['id_product'].toString(); // <-- simpan id
    price = double.tryParse(selected['price']) ?? 0;
    filteredProducts = [];
    productController.text = selectedProduct!;
  });
}

  // Fungsi untuk menghapus produk yang dipilih (jika backspace ditekan)
  void deselectProduct() {
    setState(() {
      selectedProduct = null;
      price = 0;
      productController.clear(); // Menghapus kolom pencarian
      filteredProducts = []; // Kosongkan daftar jika produk belum dipilih
    });
  }

  // Fungsi untuk menangani perubahan pada kolom input produk
  void handleProductChange(String query) {
    if (query.isEmpty) {
      deselectProduct(); // Jika input kosong, reset produk dan tampilkan rekomendasi
    } else {
      filterProducts(query); // Menyaring produk jika ada input
    }
  }

  @override
void initState() {
  super.initState();
  // default hari ini format yyyy-MM-dd
  tglSoController.text = DateFormat("yyyy-MM-dd").format(DateTime.now());
  fetchProducts();
  fetchCustomers();
  fetchBanks();
  fetchSales();
  if (ppnPercentController.text.isEmpty) {
    ppnPercentController.text = "11";
  }
}


void addItem() {
  setState(() {
    final total = quantity * price * (1 - discount / 100);
    orderItems.add({
  'id_product': selectedProductId, // <-- penting
  'nm_product': selectedProduct,  // buat tampil di card
  'qty': quantity,
  'price': price,
  'disc': discount,
});

    // reset field
    selectedProduct = null;
    quantity = 0;
    price = 0;
    discount = 0;

    productController.clear();
    qtyController.clear();
    priceController.clear();
    discountController.clear();
  });
}


  void saveProducts() => setState(() => isProductSaved = true);

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

Widget productInputSection() {
  bool isFormValid = selectedProduct != null &&
      (int.tryParse(qtyController.text) ?? 0) > 0 &&
      (double.tryParse(priceController.text) ?? 0) > 0;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      sectionTitle("Tambah Produk"),
      TextField(
        controller: productController,
        decoration: inputDecoration(
          label: "Pilih Produk",
          icon: Icons.search,
        ),
        onChanged: handleProductChange,
        onEditingComplete: () {
          if (productController.text.isEmpty) {
            deselectProduct();
          }
        },
      ),

      if (filteredProducts.isNotEmpty && selectedProduct == null) 
        Column(
          children: filteredProducts.map((product) {
            return ListTile(
              title: Text(product['nm_product']),
              onTap: () => selectProduct(product['nm_product']),
            );
          }).toList(),
        ),
      
      SizedBox(height: 10),
      Row(children: [
        Expanded(
          child: TextFormField(
            controller: qtyController,
            decoration: inputDecoration(label: "Qty", icon: Icons.numbers),
            keyboardType: TextInputType.number,
            onChanged: (val) => setState(() {
              quantity = int.tryParse(val) ?? 0;
            }),
          ),
        ),
        SizedBox(width: 5),
        Expanded(
  child: TextFormField(
    controller: priceController,
    decoration: inputDecoration(label: "Harga", icon: Icons.price_change),
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      CurrencyInputFormatter(), // <-- formatter yang kita buat
    ],
    onChanged: (val) {
      // konversi string "10.000" jadi double 10000
      String clean = val.replaceAll('.', '');
      setState(() {
        price = double.tryParse(clean) ?? 0;
      });
    },
  ),
),
      ]),
      SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: discountController,
              decoration: inputDecoration(label: "Diskon (%)", icon: Icons.percent),
              keyboardType: TextInputType.number,
              onChanged: (val) => discount = double.tryParse(val) ?? 0,
            ),
          ),
          SizedBox(width: 5),
          ElevatedButton.icon(
            onPressed: isFormValid ? addItem : null, // <- validasi
            icon: Icon(Icons.add),
            label: Text("Tambah Produk"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2E3A87),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: Size(120, 48),
            ),
          )
        ],
      ),
    ],
  );
}

Widget productCard(Map<String, dynamic> item) {
  final totalPrice = item['price'] * item['qty'];
  final discountAmount = totalPrice * (item['disc'] / 100);
  final totalAfterDiscount = totalPrice - discountAmount;

  return Card(
    margin: EdgeInsets.symmetric(vertical: 5),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian detail produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${item['qty']}x ${item['nm_product']}",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  "Rp. ${rupiahFormat.format(item['price'])} - disc ${item['disc']}% (${rupiahFormat.format(discountAmount)})",
                ),
                Text(
                  "Total: Rp. ${rupiahFormat.format(totalAfterDiscount)}",
                ),
              ],
            ),
          ),

          // Ikon hapus di sebelah kanan
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                orderItems.remove(item);
              });
            },
          ),
        ],
      ),
    ),
  );
}

Widget calculationTable() {
  double total = 0;
  for (var item in orderItems) {
    total += (item['price'] * item['qty']) * (1 - item['disc'] / 100);
  }

  double discPercent = double.tryParse(discPercentController.text) ?? 0;
  double discRp = total * (discPercent / 100);
  discRpController.text = discRp.toStringAsFixed(0);

  double ppnPercent = double.tryParse(ppnPercentController.text) ?? 0;
  double ppnRp = (total - discRp) * (ppnPercent / 100);

  double ongkir = double.tryParse(ongkirController.text.replaceAll('.', '')) ?? 0;

  int kodeUnik = int.tryParse(kodeUnikController.text) ?? 0;

  double netTotal = (total - discRp) + ppnRp + ongkir;

  TextStyle labelStyle = TextStyle(fontSize: 16);
  TextStyle valueStyle = TextStyle(fontSize: 16);

  return Table(
    columnWidths: const {
      0: FlexColumnWidth(2),
      1: FlexColumnWidth(2),
    },
    border: TableBorder.all(color: Colors.grey.shade400),
    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
    children: [
      // Total
      TableRow(children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Text("Total", style: labelStyle),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: Text("Rp. ${rupiahFormat.format(total)}", style: valueStyle),
        ),
      ]),
      // Disc %
      TableRow(children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Text("Disc (%)", style: labelStyle),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: TextField(
            controller: discPercentController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ]),
      // Disc Rp
      TableRow(children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Text("Disc (Rp)", style: labelStyle),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: Text("Rp. ${rupiahFormat.format(discRp)}", style: valueStyle),
        ),
      ]),
      // PPN
      TableRow(children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Text("PPN", style: labelStyle),
              SizedBox(width: 5),
              Expanded(
                child: TextField(
                  controller: ppnPercentController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(width: 5),
              Text("%", style: labelStyle),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: Text("Rp. ${rupiahFormat.format(ppnRp)}", style: valueStyle),
        ),
      ]),
      // Ongkir
      TableRow(children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Text("Ongkir", style: labelStyle),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: TextField(
            controller: ongkirController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(), // <-- biar input ongkir juga ada titik ribuan
            ],
            onChanged: (_) => setState(() {}),
          ),
        ),
      ]),
      // Kode Unik
      TableRow(children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Text("Kode Unik", style: labelStyle),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: TextField(
  controller: kodeUnikController,
  keyboardType: TextInputType.number,   // ganti ke number biar user pasti isi angka
  decoration: InputDecoration(
    isDense: true,
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  ),
  onChanged: (_) => setState(() {}),
),
        ),
      ]),
      // Net Total
      TableRow(children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Text("Net Total", style: labelStyle.copyWith(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: Text("Rp. ${rupiahFormat.format(netTotal)}",
              style: valueStyle.copyWith(fontWeight: FontWeight.bold)),
        ),
      ]),
    ],
  );
}

Widget customerFormSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Date
      TextField(
  controller: tglSoController,
  readOnly: true,
  decoration: inputDecoration(label: "Date (yyyy-MM-dd)", icon: Icons.calendar_today),
  onTap: () async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(tglSoController.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        tglSoController.text = DateFormat("yyyy-MM-dd").format(picked);
      });
    }
  },
),
      SizedBox(height: 10),

      // Customer
Autocomplete<Map<String, dynamic>>(
  optionsBuilder: (TextEditingValue textEditingValue) {
    if (textEditingValue.text.isEmpty) {
      return const Iterable<Map<String, dynamic>>.empty();
    }
    return customers
        .where((c) => (c['nm_supp'] as String)
            .toLowerCase()
            .contains(textEditingValue.text.toLowerCase()))
        .cast<Map<String, dynamic>>();
  },
  displayStringForOption: (c) => c['nm_supp'],
  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
    customerController = controller;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: inputDecoration(
        label: "Supplier/Customer Name",
        icon: Icons.person,
      ),
    );
  },
  onSelected: (c) {
    setState(() {
      selectedCustomerId = c['id_supp'];   // <-- simpan id untuk dikirim ke server
      selectedCustomerName = c['nm_supp']; // <-- simpan nama untuk ditampilkan
      customerController.text = c['nm_supp'];
    });
  },
),

      SizedBox(height: 10),

      // Bank
      DropdownButtonFormField<String>(
  isExpanded: true,
  decoration: inputDecoration(label: "Bank", icon: Icons.account_balance),
  value: selectedBankId, // value = ID
  items: banks.map<DropdownMenuItem<String>>((b) {
    final id = b['id'].toString();
    final label = "${b['nama_bank']} - ${b['no_rekening']}";
    return DropdownMenuItem<String>(
      value: id,                     // simpan ID
      child: Text(label, overflow: TextOverflow.ellipsis),
    );
  }).toList(),
  onChanged: (val) => setState(() => selectedBankId = val),
),


      SizedBox(height: 10),

      // Ecer Name
      TextField(
        controller: ecerController,
        decoration: inputDecoration(label: "Ecer Name", icon: Icons.store),
      ),
      SizedBox(height: 10),

      // Sales Person
      DropdownButtonFormField<String>(
        decoration: inputDecoration(label: "Sales Person", icon: Icons.person_pin),
        value: selectedSales,
        items: salesList.map<DropdownMenuItem<String>>((s) {
  return DropdownMenuItem<String>(
    value: s['salesname'],
    child: Text(s['salesname']),
  );
}).toList(),
        onChanged: (val) {
  setState(() => selectedSales = val);
},
      ),
      SizedBox(height: 10),

      // Disc (Rp)
      TextFormField(
  controller: discRpController,
  readOnly: true,
  decoration: inputDecoration(label: "Disc (Rp)", icon: Icons.money_off),
),
      SizedBox(height: 10),

      // Tempo
      TextField(
  controller: tempoController,
  onChanged: (_) => setState(() {}), // biar validasi ke-update
  decoration: inputDecoration(label: "Tempo", icon: Icons.access_time),
),
      SizedBox(height: 10),

      // Note
      TextField(
        controller: noteController,
        maxLines: 3,
        decoration: inputDecoration(label: "Note", icon: Icons.note),
      ),
    ],
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      centerTitle: true,
      title: Text(
        "Sales Order",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Color(0xFF2E3A87),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          productInputSection(),
          SizedBox(height: 20),
          ...orderItems.map((item) => productCard(item)).toList(),
          SizedBox(height: 10),
          calculationTable(),
          SizedBox(height: 10),

          // Tombol Save
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: orderItems.isNotEmpty
                  ? () {
                      // Menampilkan dialog
                      showDialog(
  context: context,
  builder: (BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: 20, // margin kiri-kanan biar gak mepet layar
        vertical: 40,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.95, // hampir full lebar
          maxHeight: MediaQuery.of(context).size.height * 0.85, // lebih tinggi
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Judul
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Customer Form',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // Isi Form
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: customerFormSection(),
              ),
            ),
            // Tombol Aksi
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
  onPressed: isFormValid()
      ? () async {
          await saveCustomerData();  
          resetForm();              // <-- langsung reset setelah save
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Transaksi berhasil disimpan")),
          );
        }
      : null,
  child: const Text('Save', style: TextStyle(color: Colors.white)),
  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  },
);

                    }
                  : null, // <- disable tombol Save kalau kosong
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Save'),
            ),
          ),

          SizedBox(height: 20),

          if (showCustomerForm) customerFormSection(),
        ],
      ),
    ),
  );
}
}

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('id');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // kalau kosong
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Hapus semua titik/karakter non-digit
    String value = newValue.text.replaceAll('.', '');
    double number = double.tryParse(value) ?? 0;

    // Format ulang pakai titik ribuan
    String newText = _formatter.format(number);

    // balikin posisi cursor ke akhir
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}