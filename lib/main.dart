import 'package:flutter/material.dart';
import 'package:inventory_apps/services/auth_service.dart';
import 'package:inventory_apps/views/dashboard_router.dart';
import 'package:inventory_apps/views/onboarding_page.dart';

void main() {
  runApp(const FutsalBookingApp());
}

class FutsalBookingApp extends StatelessWidget {
  const FutsalBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Futsal Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF22C55E),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF22C55E)),
      ),
      home: FutureBuilder<bool>(
        future: AuthService.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF22C55E)),
              ),
            );
          }

          if (snapshot.data == true) {
            return const DashboardRouter();
          }

          return const OnboardingScreen();
        },
      ),
    );
  }
}
