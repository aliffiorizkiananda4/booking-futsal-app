import 'package:flutter/material.dart';
import 'package:inventory_apps/services/auth_service.dart';
import 'package:inventory_apps/services/booking_service.dart';
import 'package:inventory_apps/services/field_service.dart';
import 'package:inventory_apps/views/admin/booking_management_page.dart';
import 'package:inventory_apps/views/admin/field_management_page.dart';
import 'package:inventory_apps/views/admin/payment_management_page.dart';
import 'package:inventory_apps/views/admin/schedule_management_page.dart';
import 'package:inventory_apps/views/admin/user_management_page.dart';
import 'package:inventory_apps/views/login_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  String _name = "";

  // Statistics
  int _totalFields = 0;
  int _totalBookings = 0;
  int _pendingBookings = 0;
  int _approvedBookings = 0;
  int _pendingPayments = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadStatistics();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  Future<void> _loadUserName() async {
    final name = await AuthService.getName();
    setState(() {
      _name = name;
    });
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      // Load fields
      final fieldService = FieldService();
      final fields = await fieldService.getFields();

      // Load bookings
      final bookingService = BookingService();
      final bookingsData = await bookingService.fetchBookings(limit: 1000);

      if (bookingsData != null) {
        final bookings = bookingsData['bookings'] as List;
        final pending = bookings.where((b) => b.status == 'pending').length;
        final approved = bookings
            .where((b) => b.status == 'confirmed' || b.status == 'paid')
            .length;

        setState(() {
          _totalFields = fields.length;
          _totalBookings = bookings.length;
          _pendingBookings = pending;
          _approvedBookings = approved;
          _pendingPayments =
              pending; // Simplified: assume pending bookings need payment
          _isLoadingStats = false;
        });
      } else {
        setState(() {
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Administrator',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Anda yakin ingin logout?',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),
              Divider(color: Colors.grey.shade200),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await AuthService.logout();
                        if (context.mounted) {
                          Navigator.pop(dialogContext);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadStatistics,
                color: const Color(0xFFEF4444),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGreeting(),
                      const SizedBox(height: 28),
                      _buildStatistics(),
                      const SizedBox(height: 28),
                      _buildMenuSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1AEF4444),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Admin Panel',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _showProfileDialog,
            child: const Icon(
              Icons.logout_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo, $_name 👋',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Kelola sistem booking futsal',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    if (_isLoadingStats) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: Color(0xFFEF4444)),
        ),
      );
    }

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistik',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Lapangan',
                    value: _totalFields.toString(),
                    icon: Icons.sports_soccer_rounded,
                    color: const Color(0xFF22C55E),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Booking',
                    value: _totalBookings.toString(),
                    icon: Icons.calendar_today_rounded,
                    color: const Color(0xFF0EA5E9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Pending',
                    value: _pendingBookings.toString(),
                    icon: Icons.pending_rounded,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Approved',
                    value: _approvedBookings.toString(),
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              title: 'Pembayaran Pending',
              value: _pendingPayments.toString(),
              icon: Icons.payment_rounded,
              color: const Color(0xFFEF4444),
              isWide: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isWide = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menu Admin',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        _buildAdminMenuItem(
          title: 'Kelola Lapangan',
          subtitle: 'Tambah, edit, hapus lapangan',
          icon: Icons.sports_soccer_rounded,
          color: const Color(0xFF22C55E),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FieldManagementPage()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildAdminMenuItem(
          title: 'Kelola Jadwal',
          subtitle: 'Atur jadwal lapangan',
          icon: Icons.schedule_rounded,
          color: const Color(0xFF0EA5E9),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScheduleManagementPage()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildAdminMenuItem(
          title: 'Kelola Booking',
          subtitle: 'Approve/reject booking',
          icon: Icons.event_note_rounded,
          color: const Color(0xFFF59E0B),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookingManagementPage()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildAdminMenuItem(
          title: 'Kelola Pembayaran',
          subtitle: 'Verifikasi bukti pembayaran',
          icon: Icons.payment_rounded,
          color: const Color(0xFF8B5CF6),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaymentManagementPage()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildAdminMenuItem(
          title: 'Kelola User',
          subtitle: 'Manajemen pengguna',
          icon: Icons.people_rounded,
          color: const Color(0xFFEF4444),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserManagementPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdminMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
