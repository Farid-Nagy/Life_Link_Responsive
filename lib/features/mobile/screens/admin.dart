import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lifelink/core/responsive/app_breakpoints.dart';
import 'package:lifelink/core/theme/app_colors.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final String currentRoute = "adminHome";

  void _navigateAndCloseDrawer(String routeName) {
    Navigator.of(context).pop();
    Navigator.pushNamed(context, routeName);
  }

  Widget _buildDashboardCard(
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 16),
            Text(
              "$count",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(title),
          ],
        ),
      ),
    );
  }

  // ================= LOGOUT =================
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, "loginScreen");
  }

  // ================= عدد المستشفيات =================
  Future<int> getHospitalsCount() async {
    final bloodTypes = ['A+', 'A-', 'AB+', 'AB-', 'B+', 'B-', 'O+', 'O-'];

    Set<String> uniqueHospitals = {};

    for (String bloodType in bloodTypes) {
      final doc = await FirebaseFirestore.instance
          .collection('blood_inventory')
          .doc(bloodType)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        if (data.containsKey('hospitals')) {
          Map<String, dynamic> hospitals = data['hospitals'];

          uniqueHospitals.addAll(hospitals.keys);
        }
      }
    }

    return uniqueHospitals.length;
  }

  // ================= عدد المستخدمين =================
  Future<int> getUsersCount() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();

    return snapshot.docs.length;
  }

  // ================= الأكياس المتاحة =================
  Future<int> getAvailableBags() async {
    final bloodTypes = ['A+', 'A-', 'AB+', 'AB-', 'B+', 'B-', 'O+', 'O-'];

    int totalAvailable = 0;

    for (String bloodType in bloodTypes) {
      final doc = await FirebaseFirestore.instance
          .collection('blood_inventory')
          .doc(bloodType)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        if (data.containsKey('hospitals')) {
          Map<String, dynamic> hospitals = data['hospitals'];

          hospitals.forEach((hospital, count) {
            if (count is int && count > 0) {
              totalAvailable += count;
            }
          });
        }
      }
    }

    return totalAvailable;
  }

  // ================= الأكياس المحجوزة =================
  Future<int> getReservedBags() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .get();

    int totalQuantity = 0;

    for (var doc in snapshot.docs) {
      final quantityDynamic = doc['quantity'];

      int quantity = 0;

      if (quantityDynamic is int) {
        quantity = quantityDynamic;
      } else if (quantityDynamic is String) {
        quantity = int.tryParse(quantityDynamic) ?? 0;
      } else if (quantityDynamic is double) {
        quantity = quantityDynamic.toInt();
      }

      totalQuantity += quantity;
    }

    return totalQuantity;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 1100;
        final body = RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: Padding(
            padding: EdgeInsets.all(desktop ? 28 : 16),
            child: FutureBuilder<List<int>>(
              future: Future.wait([
                getUsersCount(),
                getHospitalsCount(),
                getAvailableBags(),
                getReservedBags(),
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final values = snapshot.data ?? [0, 0, 0, 0];
                final cards = [
                  _buildDashboardCard(
                    'Users',
                    values[0],
                    Icons.people,
                    Colors.orange,
                  ),
                  _buildDashboardCard(
                    'Hospitals',
                    values[1],
                    Icons.local_hospital,
                    Colors.red,
                  ),
                  _buildDashboardCard(
                    'Available',
                    values[2],
                    Icons.inventory,
                    Colors.blue,
                  ),
                  _buildDashboardCard(
                    'Reserved',
                    values[3],
                    Icons.pending_actions,
                    Colors.green,
                  ),
                ];

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppBreakpoints.maxContentWidth,
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: cards.length,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: desktop ? 320 : 280,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        mainAxisExtent: desktop ? 220 : 190,
                      ),
                      itemBuilder: (_, index) => cards[index],
                    ),
                  ),
                );
              },
            ),
          ),
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Admin Home'),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('جاري تحديث البيانات...')),
                  );
                },
              ),
            ],
          ),
          drawer: desktop ? null : _buildDrawer(),
          body: desktop
              ? Row(
                  children: [
                    _buildDesktopNavigation(),
                    Expanded(child: body),
                  ],
                )
              : body,
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            accountName: Text('Admin'),
            accountEmail: Text('admin@lifelink.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings, color: AppColors.primary),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Admin Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Blood Inventory'),
            onTap: () => _navigateAndCloseDrawer('bloodInventoryAdmin'),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Orders'),
            onTap: () => _navigateAndCloseDrawer('adminOrdersScreen'),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Users'),
            onTap: () => _navigateAndCloseDrawer('usersAdmin'),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reports'),
            onTap: () => _navigateAndCloseDrawer('reportsAdmin'),
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNavigation() {
    return Container(
      width: 235,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 24),
          const CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primarySurface,
            child: Icon(
              Icons.admin_panel_settings,
              color: AppColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Admin Portal',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 24),
          _adminNavItem(Icons.admin_panel_settings, 'Dashboard', null),
          _adminNavItem(
            Icons.inventory,
            'Blood Inventory',
            'bloodInventoryAdmin',
          ),
          _adminNavItem(Icons.receipt_long, 'Orders', 'adminOrdersScreen'),
          _adminNavItem(Icons.people, 'Users', 'usersAdmin'),
          _adminNavItem(Icons.bar_chart, 'Reports', 'reportsAdmin'),
          const Spacer(),
          _adminNavItem(Icons.logout, 'Logout', null, logout: true),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _adminNavItem(
    IconData icon,
    String label,
    String? route, {
    bool logout = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: logout ? Colors.red : AppColors.primary),
        title: Text(
          label,
          style: TextStyle(color: logout ? Colors.red : AppColors.text),
        ),
        onTap: () {
          if (logout) {
            _logout();
          } else if (route != null) {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }
}
