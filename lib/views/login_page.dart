import 'package:flutter/material.dart';
import 'package:inventory_apps/services/auth_service.dart';
import 'package:inventory_apps/utils/color.dart';
import 'package:inventory_apps/views/dashboard_router.dart';
import 'package:inventory_apps/views/register_page.dart';
import 'package:inventory_apps/widgets/button/custom_button.dart';
import 'package:inventory_apps/widgets/form/custom_text_field.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: Lottie.asset("assets/icons/login.json"),
                    ),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Futsal',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF22C55E),
                            ),
                          ),
                          TextSpan(
                            text: 'Booking',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Book Your Futsal Field Easily',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Login To Your Account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),

                    const SizedBox(height: 24),

                    CustomTextField(
                      controller: _emailController,
                      hint: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
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
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _isLoading
                        ? const CircularProgressIndicator(
                            color: Color(0xFF22C55E),
                          )
                        : CustomButton(
                            label: 'Login',
                            onTap: () async {
                              final email = _emailController;
                              final password = _passwordController;
                              if (email.text.isEmpty || password.text.isEmpty) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Email dan password tidak boleh kosong",
                                      ),
                                    ),
                                  );
                                }
                                return;
                              }
                              setState(() {
                                _isLoading = true;
                              });
                              bool isSuccess = await AuthService.login(
                                email.text,
                                password.text,
                              );
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                              if (isSuccess) {
                                if (mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DashboardRouter(),
                                    ),
                                  );
                                }
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Login Gagal! Periksa email dan password Anda.",
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
                          'Belum punya akun? ',
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Daftar',
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
          ),
        ],
      ),
    );
  }
}
