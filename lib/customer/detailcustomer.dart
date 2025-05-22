import 'package:flutter/material.dart';
import 'package:hayami_app/customer/editcustomer.dart';

class Customerdetailscreen extends StatelessWidget {
  final Map<String, dynamic> customer;

  const Customerdetailscreen({Key? key, required this.customer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Detail Customer", style: TextStyle(color: Colors.blue)),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.blue),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // ⬅️ Tambahkan ini
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTile(
                icon: Icons.person,
                title: 'Nama',
                subtitle: customer['name'] ?? '-',
              ),
              const Divider(),
              CustomTile(
                icon: Icons.category,
                title: 'Jenis',
                subtitle: customer['jenis'] ?? '-',
              ),
              const Divider(),
              CustomTile(
                icon: Icons.phone,
                title: 'Telepon',
                subtitle: customer['phone'] ?? '-',
              ),
              const Divider(),
              CustomTile(
                icon: Icons.location_on,
                title: 'Alamat',
                subtitle: customer['address'] ?? '-',
              ),
              const SizedBox(height: 12), // jarak atas tombol
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditCustomerScreen(customer: customer),
                      ),
                    );

                    if (result != null && result is Map<String, dynamic>) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Data berhasil diperbarui")),
                      );
                      Navigator.of(context).pop(result);
                    }
                  },
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                  label:
                      const Text("Edit", style: TextStyle(color: Colors.blue)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const CustomTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade50,
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
