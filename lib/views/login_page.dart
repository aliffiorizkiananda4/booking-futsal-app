import 'package:flutter/material.dart';
import 'package:inventory_apps/services/auth_service.dart';
import 'package:inventory_apps/utils/color.dart';
import 'package:inventory_apps/views/dashboard.dart';
import 'package:inventory_apps/widgets/button/custom_button.dart';
import 'package:inventory_apps/widgets/form/custom_text_field.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
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
                            text: 'Inventory',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          TextSpan(
                            text: 'Apps',
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
                      'Manage Your Inventory Efficiently',
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
                      controller: _usernameController,
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
                        ? CircularProgressIndicator(
                            color: AppColors.primaryBlue,
                          )
                        : CustomButton(
                            label: 'Login',
                            onTap: () async {
                              final username = _usernameController;
                              final password = _passwordController;
                              if (username.text.isEmpty ||
                                  password.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Username tidak boleh kosong",
                                    ),
                                  ),
                                );
                                return;
                              }
                              setState(() {
                                _isLoading = true;
                              });
                              bool isSucces = await AuthService.login(
                                username.text,
                                password.text,
                              );
                              setState(() {
                                _isLoading = false;
                              });
                              if (isSucces) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DashboardScreen(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Login Gagal!"),
                                    backgroundColor: Colors.red,
                                  )
                                );
                              }
                            },
                            backgroundColor: AppColors.primaryBlue,
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
