import 'package:flutter/material.dart';
import 'kledo_drawer.dart'; // Import file KledoDrawer kalau dipisah

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.blue[800],
      ),
      drawer: KledoDrawer(), // Panggil drawer yang sudah di buat
      body: Center(
        child: Text(
          'Selamat datang di Dashboard!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
