import 'package:flutter/material.dart';
import 'package:inventory_apps/services/auth_service.dart';
import 'package:inventory_apps/views/login_page.dart';
import 'package:inventory_apps/widgets/button/custom_button.dart';
import 'package:inventory_apps/widgets/form/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF22C55E),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Daftar Akun',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Buat akun baru untuk booking lapangan futsal',
                style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 32),

              CustomTextField(
                controller: _nameController,
                hint: 'Nama Lengkap',
                prefixIcon: Icons.person_outline,
              ),

              const SizedBox(height: 14),

              CustomTextField(
                controller: _emailController,
                hint: 'Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),

              const SizedBox(height: 14),

              CustomTextField(
                controller: _phoneController,
                hint: 'Nomor Telepon',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),

              const SizedBox(height: 14),

              CustomTextField(
                controller: _passwordController,
                hint: 'Password',
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              const SizedBox(height: 28),

              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF22C55E),
                      ),
                    )
                  : CustomButton(
                      label: 'Daftar',
                      onTap: () async {
                        if (_nameController.text.isEmpty ||
                            _emailController.text.isEmpty ||
                            _phoneController.text.isEmpty ||
                            _passwordController.text.isEmpty) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Semua field harus diisi!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }

                        setState(() => _isLoading = true);

                        final success = await AuthService.register(
                          name: _nameController.text,
                          email: _emailController.text,
                          password: _passwordController.text,
                          phone: _phoneController.text,
                        );

                        if (mounted) {
                          setState(() => _isLoading = false);
                        }

                        if (success) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Registrasi berhasil! Silakan login.',
                                ),
                                backgroundColor: Color(0xFF22C55E),
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Registrasi gagal! Silakan coba lagi.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      backgroundColor: const Color(0xFF22C55E),
                    ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun? ',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xFF22C55E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
