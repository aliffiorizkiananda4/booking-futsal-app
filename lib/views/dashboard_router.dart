import 'package:flutter/material.dart';
import 'package:inventory_apps/services/auth_service.dart';
import 'package:inventory_apps/views/admin_dashboard_page.dart';
import 'package:inventory_apps/views/user_dashboard_page.dart';

class DashboardRouter extends StatelessWidget {
  const DashboardRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: AuthService.getRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF4F6FA),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF22C55E)),
            ),
          );
        }

        final role = snapshot.data ?? 'user';

        if (role == 'admin') {
          return const AdminDashboardPage();
        } else {
          return const UserDashboardPage();
        }
      },
    );
  }
}
