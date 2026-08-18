import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lifelink/core/theme/app_colors.dart';
import 'package:lifelink/features/desktop/screens/desktop_service_pages.dart';
import 'package:lifelink/features/desktop/widgets/desktop_ui_kit.dart';
import 'package:lifelink/features/mobile/screens/login_screen.dart';

class DesktopAdminScreen extends StatefulWidget {
  const DesktopAdminScreen({super.key});

  @override
  State<DesktopAdminScreen> createState() => _DesktopAdminScreenState();
}

class _DesktopAdminScreenState extends State<DesktopAdminScreen> {
  int _selectedIndex = 0;
  String? _username;

  static const _items = <_AdminNavItem>[
    _AdminNavItem(Icons.dashboard_rounded, 'Dashboard'),
    _AdminNavItem(Icons.inventory_2_outlined, 'Blood Inventory'),
    _AdminNavItem(Icons.receipt_long_outlined, 'Orders'),
    _AdminNavItem(Icons.people_outline, 'Users'),
    _AdminNavItem(Icons.analytics_outlined, 'Reports'),
  ];

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!mounted) return;
      setState(() => _username = doc.data()?['username']?.toString());
    } catch (_) {}
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Widget _content() {
    switch (_selectedIndex) {
      case 1:
        return const DesktopBloodInventoryPage();
      case 2:
        return const DesktopAdminOrdersPage();
      case 3:
        return const DesktopAdminUsersPage();
      case 4:
        return const DesktopAdminReportsPage();
      default:
        return const _DashboardOverview();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = _items[_selectedIndex].label;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          SizedBox(width: 248, child: _AdminSidebar(selectedIndex: _selectedIndex, username: _username, onLogout: _logout, onSelected: (index) => setState(() => _selectedIndex = index))),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 82,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        pageTitle,
                        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: AppColors.text),
                      ),
                      const Spacer(),
                      if (_username?.trim().isNotEmpty == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                          decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(30)),
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline_rounded, size: 19, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(_username!, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.text)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(child: _content()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final String? username;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;

  const _AdminSidebar({
    required this.selectedIndex,
    required this.username,
    required this.onSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
              child: const Icon(Icons.bloodtype_rounded, color: AppColors.white, size: 30),
            ),
            const SizedBox(height: 10),
            const Text('LIFE LINK', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.primary)),
            if (username?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(username!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ),
            ],
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final item = _AdminNavItem._all[index];
                  final selected = selectedIndex == index;
                  return InkWell(
                    onTap: () => onSelected(index),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primarySoft : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(item.icon, color: selected ? AppColors.primary : AppColors.muted, size: 21),
                          const SizedBox(width: 14),
                          Text(item.label, style: TextStyle(color: selected ? AppColors.primary : AppColors.textSecondary, fontWeight: selected ? FontWeight.w800 : FontWeight.w600)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
              child: InkWell(
                onTap: onLogout,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                  decoration: BoxDecoration(color: AppColors.danger.withAlpha(12), borderRadius: BorderRadius.circular(16)),
                  child: const Row(
                    children: [
                      Icon(Icons.logout_rounded, color: AppColors.danger, size: 21),
                      SizedBox(width: 14),
                      Text('Logout', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
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
}

class _AdminNavItem {
  final IconData icon;
  final String label;

  const _AdminNavItem(this.icon, this.label);

  static const _all = <_AdminNavItem>[
    _AdminNavItem(Icons.dashboard_rounded, 'Dashboard'),
    _AdminNavItem(Icons.inventory_2_outlined, 'Blood Inventory'),
    _AdminNavItem(Icons.receipt_long_outlined, 'Orders'),
    _AdminNavItem(Icons.people_outline, 'Users'),
    _AdminNavItem(Icons.analytics_outlined, 'Reports'),
  ];
}

class _DashboardOverview extends StatelessWidget {
  const _DashboardOverview();

  Future<List<int>> _load() async {
    final results = await Future.wait([
      FirebaseFirestore.instance.collection('users').get(),
      FirebaseFirestore.instance.collection('orders').get(),
      FirebaseFirestore.instance.collection('blood_inventory').get(),
    ]);

    var available = 0;
    for (final doc in results[2].docs) {
      final hospitals = (doc.data()['hospitals'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
      for (final value in hospitals.values) {
        available += value is num ? value.toInt() : int.tryParse('$value') ?? 0;
      }
    }
    return [results[0].docs.length, results[1].docs.length, available];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Unable to load dashboard data', style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
          );
        }
        final values = snapshot.data ?? [0, 0, 0];
        return DesktopPageShell(
          maxWidth: 1240,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DesktopSectionHeader(
                title: 'Dashboard Overview',
                subtitle: 'A quick view of the current Life Link activity',
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 920 ? 3 : 2;
                  return GridView.count(
                    crossAxisCount: columns,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 2.4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _StatCard('Users', values[0], Icons.people_outline_rounded),
                      _StatCard('Orders', values[1], Icons.receipt_long_outlined),
                      _StatCard('Available Bags', values[2], Icons.bloodtype_rounded),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              DesktopGlassCard(
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.favorite_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Life Link', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text)),
                          SizedBox(height: 3),
                          Text('Manage inventory, orders and users from one place.', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;

  const _StatCard(this.title, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowSoft, blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$value', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.text)),
                const SizedBox(height: 2),
                Text(title, style: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
