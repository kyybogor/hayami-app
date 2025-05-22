import 'package:flutter/material.dart';
import 'package:hayami_app/Login/loginScreen.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProRegis(),
  ));
}

class ProRegis extends StatefulWidget {
  const ProRegis({super.key});

  @override
  State<ProRegis> createState() => _ProRegisState();
}

class _ProRegisState extends State<ProRegis> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController couponController = TextEditingController();

  bool _showCouponField = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.zero, // hapus padding default
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 60, left: 20, right: 20, bottom: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.brown, Color.fromARGB(255, 99, 65, 52)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const Text(
                    'Daftar!',
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Pro Free Trial',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildTextField(Icons.person, "Nama lengkap", nameController),
                  const SizedBox(height: 16),
                  _buildTextField(Icons.apartment, "Nama perusahaan", companyController),
                  const SizedBox(height: 16),
                  _buildTextField(Icons.phone, "Nomor telepon", phoneController),
                  const SizedBox(height: 16),
                  _buildTextField(Icons.email, "Email", emailController),
                  const SizedBox(height: 16),

                  // Tambahkan kolom password
                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      hintText: "Password",
                      border: const UnderlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _showCouponField = !_showCouponField;
                        });
                      },
                      child: Text(
                        _showCouponField
                            ? 'Sembunyikan Kode Kupon'
                            : 'Masukkan Kode Kupon',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),

                  if (_showCouponField)
                    _buildTextField(Icons.card_giftcard, "Kode Kupon", couponController),

                  const SizedBox(height: 24),

                  // Tombol DAFTAR
                  SizedBox(
                    width: double.infinity,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Anda berhasil mendaftarkan akun, silakan masuk.'),
                          ),
                        );
                      },
                      child: Ink(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.brown, Color.fromARGB(255, 99, 65, 52)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            "DAFTAR",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: 'Sudah punya akun? ',
                        children: [
                          TextSpan(
                            text: 'Masuk',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        border: const UnderlineInputBorder(),
      ),
    );
  }
}
