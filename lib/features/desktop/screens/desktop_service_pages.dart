import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lifelink/core/responsive/responsive_layout.dart';
import 'package:lifelink/core/theme/app_colors.dart';
import 'package:lifelink/features/mobile/screens/about_page.dart';
import 'package:lifelink/features/mobile/screens/admin_orders_page.dart';
import 'package:lifelink/features/mobile/screens/admin_reports_page.dart';
import 'package:lifelink/features/mobile/screens/admin_users_page.dart';
import 'package:lifelink/features/mobile/screens/blood_inventory.dart';
import 'package:lifelink/features/mobile/screens/pay_now.dart';
import 'package:lifelink/core/services/quantity_parser.dart';
import 'package:lifelink/features/shared/widgets/profile_avatar.dart';

class DesktopPageFrame extends StatelessWidget {
  final Widget child;
  final String? title;

  const DesktopPageFrame({super.key, required this.child, this.title});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: Column(
        children: [
              if (title != null)
            Container(
              width: double.infinity,
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: AppColors.primary,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class DesktopMyDataPage extends StatefulWidget {
  const DesktopMyDataPage({super.key});

  @override
  State<DesktopMyDataPage> createState() => _DesktopMyDataPageState();
}

class _DesktopMyDataPageState extends State<DesktopMyDataPage> {
  String? name;
  String? nationalId;
  String? phone;
  String? email;
  String? profileImageUrl;
  bool loading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        loading = true;
        hasError = false;
      });
    }
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user');
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data() ?? <String, dynamic>{};
      if (!mounted) return;
      setState(() {
        name = data['username']?.toString();
        nationalId = data['nationalid']?.toString();
        phone = data['phone']?.toString();
        email = user.email;
        profileImageUrl = data['profileImageUrl']?.toString();
        loading = false;
        hasError = !doc.exists;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        hasError = true;
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('loginScreen', (_) => false);
  }

  Widget _infoCard(String title, String? value, IconData icon) {
    final displayValue = value?.trim().isNotEmpty == true ? value! : '--';
    return Container(
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: AppColors.primary, size: 23),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  displayValue,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(34, 30, 34, 42),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            ProfileAvatar(
                              imageUrl: profileImageUrl,
                              size: 84,
                              onUploaded: (url) => setState(() => profileImageUrl = url),
                            ),
                            const SizedBox(width: 22),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'My Data',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Account information',
                                    style: TextStyle(
                                      color: AppColors.white70,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Refresh',
                              onPressed: _load,
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: _logout,
                              icon: const Icon(Icons.logout_rounded, size: 18),
                              label: const Text('Logout'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white54),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      if (hasError)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 18),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Some account data could not be loaded. Please refresh and try again.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      const Text(
                        'Account information',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 900 ? 2 : 1;
                          return GridView.count(
                            crossAxisCount: columns,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: columns == 2 ? 3.35 : 4.2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _infoCard('Name', name, Icons.person_outline_rounded),
                              _infoCard('National ID', nationalId, Icons.badge_outlined),
                              _infoCard('Phone Number', phone, Icons.phone_outlined),
                              _infoCard('Email Address', email, Icons.email_outlined),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class DesktopAboutPage extends StatelessWidget {
  const DesktopAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: AppColors.background,
      child: AboutPage(),
    );
  }
}

class DesktopBloodInventoryPage extends StatelessWidget {
  const DesktopBloodInventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DesktopPageFrame(title: 'Blood Inventory', child: BloodInventoryAdminPage());
  }
}

class DesktopAdminOrdersPage extends StatelessWidget {
  const DesktopAdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DesktopPageFrame(title: 'Orders', child: AdminOrdersPage());
  }
}

class DesktopAdminUsersPage extends StatelessWidget {
  const DesktopAdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DesktopPageFrame(title: 'Users', child: AdminUsersPage());
  }
}

class DesktopAdminReportsPage extends StatelessWidget {
  const DesktopAdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DesktopPageFrame(title: 'Reports', child: AdminReportsPage());
  }
}

class _DesktopServiceScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const _DesktopServiceScaffold({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return DesktopPageFrame(
      title: title,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 36),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: child,
          ),
        ),
      ),
    );
  }
}

class DesktopBloodTypePage extends StatefulWidget {
  const DesktopBloodTypePage({super.key});

  @override
  State<DesktopBloodTypePage> createState() => _DesktopBloodTypePageState();
}

class _DesktopBloodTypePageState extends State<DesktopBloodTypePage> {
  String? selectedBlood;
  String? selectedHospital;
  int count = 1;
  int availableQty = 0;
  DateTime? receiveDate;

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: receiveDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      helpText: 'Select date',
      cancelText: 'Cancel',
      confirmText: 'Select',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.primary,
            onPrimary: AppColors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null && mounted) setState(() => receiveDate = date);
  }

  void _goToPayment() {
    if (selectedBlood == null || selectedHospital == null || receiveDate == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResponsiveLayout(
          mobile: PayNow(
            bloodType: selectedBlood!,
            hospital: selectedHospital!,
            quantity: count,
            receiveDate: receiveDate!,
            orderType: 'Pickup',
          ),
          tablet: DesktopPaymentPage(
            bloodType: selectedBlood!,
            hospital: selectedHospital!,
            quantity: count,
            receiveDate: receiveDate!,
            orderType: 'Pickup',
          ),
          desktop: DesktopPaymentPage(
            bloodType: selectedBlood!,
            hospital: selectedHospital!,
            quantity: count,
            receiveDate: receiveDate!,
            orderType: 'Pickup',
          ),
        ),
      ),
    );
  }

  Widget _field({required Widget child}) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DesktopServiceScaffold(
      title: 'Pick your blood type',
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('blood_inventory').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('An error occurred. Please try again.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final bloodData = <String, Map<String, dynamic>>{};
          for (final doc in snapshot.data!.docs) {
            final map = (doc.data() as Map<String, dynamic>)['hospitals'];
            bloodData[doc.id] = Map<String, dynamic>.from(map is Map ? map : const {});
          }

          if (selectedBlood != null && !bloodData.containsKey(selectedBlood)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() { selectedBlood = null; selectedHospital = null; availableQty = 0; count = 1; });
            });
          }

          final hospitals = selectedBlood == null ? <String>[] : bloodData[selectedBlood]!.entries.where((e) => e.value is num && (e.value as num) > 0).map((e) => e.key).toList();

          if (selectedHospital != null && !hospitals.contains(selectedHospital)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() { selectedHospital = null; availableQty = 0; count = 1; });
            });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1000 ? 4 : 2;
                  return GridView.builder(
                    itemCount: bloodData.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      mainAxisExtent: 108,
                    ),
                    itemBuilder: (context, index) {
                      final type = bloodData.keys.elementAt(index);
                      final totalQty = bloodData[type]!.values.fold<int>(
                        0,
                        (sum, value) => sum + parseInventoryQuantity(value),
                      );
                      final selected = selectedBlood == type;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => setState(() {
                            selectedBlood = type;
                            selectedHospital = null;
                            availableQty = 0;
                            count = 1;
                          }),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: selected ? AppColors.primary : AppColors.borderStrong,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadowSoft,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  type,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: selected ? AppColors.white : AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Qty: $totalQty',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? AppColors.white70 : AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _field(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedHospital,
                          isExpanded: true,
                          hint: const Text('Hospital'),
                          items: hospitals.map((hospital) => DropdownMenuItem(value: hospital, child: Text(hospital))).toList(),
                          onChanged: selectedBlood == null ? null : (value) {
                            setState(() {
                              selectedHospital = value;
                              final raw = value == null ? 0 : bloodData[selectedBlood!]![value];
                              availableQty = parseInventoryQuantity(raw);
                              count = availableQty > 0 ? 1 : 0;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: _field(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(onPressed: selectedHospital != null && count > 1 ? () => setState(() => count--) : null, icon: const Icon(Icons.remove, color: AppColors.primary)),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$count', style: const TextStyle(fontWeight: FontWeight.w800)),
                              if (selectedHospital != null)
                                Text(
                                  'Available: $availableQty',
                                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                                ),
                            ],
                          ),
                          IconButton(onPressed: selectedHospital != null && availableQty > 0 && count < availableQty ? () => setState(() => count = (count + 1).clamp(1, availableQty)) : null, icon: const Icon(Icons.add, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(16),
                child: _field(
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(Icons.event_outlined, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Receive Date',
                              style: TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              receiveDate == null
                                  ? 'Select date'
                                  : '${receiveDate!.day}/${receiveDate!.month}/${receiveDate!.year}',
                              style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: selectedBlood != null && selectedHospital != null && receiveDate != null && count > 0 ? _goToPayment : null,
                  child: const Text('Next', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DesktopDeliveryPage extends StatefulWidget {
  const DesktopDeliveryPage({super.key});

  @override
  State<DesktopDeliveryPage> createState() => _DesktopDeliveryPageState();
}

class _DesktopDeliveryPageState extends State<DesktopDeliveryPage> {
  String? selectedBlood;
  String? selectedHospital;
  int count = 1;
  int availableQty = 0;
  DateTime? receiveDate;
  final hospitalNameController = TextEditingController();
  final addressController = TextEditingController();
  final double deliveryFee = 50;

  @override
  void dispose() {
    hospitalNameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: receiveDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      helpText: 'Select date',
      cancelText: 'Cancel',
      confirmText: 'Select',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.primary,
            onPrimary: AppColors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null && mounted) setState(() => receiveDate = date);
  }

  void _goToPayment() {
    if (selectedBlood == null || selectedHospital == null || receiveDate == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResponsiveLayout(
          mobile: PayNow(
            bloodType: selectedBlood!,
            hospital: hospitalNameController.text.trim(),
            quantity: count,
            receiveDate: receiveDate!,
            orderType: 'Delivery',
            deliveryAddress: addressController.text.trim(),
            deliveryFee: deliveryFee,
          ),
          tablet: DesktopPaymentPage(
            bloodType: selectedBlood!,
            hospital: hospitalNameController.text.trim(),
            quantity: count,
            receiveDate: receiveDate!,
            orderType: 'Delivery',
            deliveryAddress: addressController.text.trim(),
            deliveryFee: deliveryFee,
          ),
          desktop: DesktopPaymentPage(
            bloodType: selectedBlood!,
            hospital: hospitalNameController.text.trim(),
            quantity: count,
            receiveDate: receiveDate!,
            orderType: 'Delivery',
            deliveryAddress: addressController.text.trim(),
            deliveryFee: deliveryFee,
          ),
        ),
      ),
    );
  }

  Widget _field({required Widget child, double height = 58}) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStrong),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DesktopServiceScaffold(
      title: 'Delivery Details',
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('blood_inventory').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('An error occurred. Please try again.'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

          final bloodData = <String, Map<String, dynamic>>{};
          for (final doc in snapshot.data!.docs) {
            final map = (doc.data() as Map<String, dynamic>)['hospitals'];
            bloodData[doc.id] = Map<String, dynamic>.from(map is Map ? map : const {});
          }

          final hospitals = selectedBlood == null
              ? <String>[]
              : bloodData[selectedBlood]!.entries
                  .where((e) => e.value is num && (e.value as num) > 0)
                  .map((e) => e.key)
                  .toList();

          if (selectedBlood != null && !bloodData.containsKey(selectedBlood)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                selectedBlood = null;
                selectedHospital = null;
                availableQty = 0;
                count = 1;
              });
            });
          } else if (selectedHospital != null && !hospitals.contains(selectedHospital)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                selectedHospital = null;
                availableQty = 0;
                count = 1;
              });
            });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1000 ? 4 : 2;
                  return GridView.builder(
                    itemCount: bloodData.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      mainAxisExtent: 108,
                    ),
                    itemBuilder: (context, index) {
                      final type = bloodData.keys.elementAt(index);
                      final totalQty = bloodData[type]!.values.fold<int>(
                        0,
                        (sum, value) => sum + parseInventoryQuantity(value),
                      );
                      final selected = selectedBlood == type;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => setState(() {
                            selectedBlood = type;
                            selectedHospital = null;
                            availableQty = 0;
                            count = 1;
                          }),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: selected ? AppColors.primary : AppColors.borderStrong,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadowSoft,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  type,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: selected ? AppColors.white : AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Qty: $totalQty',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? AppColors.white70 : AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _field(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedHospital,
                          isExpanded: true,
                          hint: const Text('Hospital'),
                          items: hospitals.map((hospital) => DropdownMenuItem(value: hospital, child: Text(hospital))).toList(),
                          onChanged: selectedBlood == null ? null : (value) {
                            setState(() {
                              selectedHospital = value;
                              final raw = value == null ? 0 : bloodData[selectedBlood!]![value];
                              availableQty = parseInventoryQuantity(raw);
                              count = availableQty > 0 ? 1 : 0;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: _field(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(onPressed: selectedHospital != null && count > 1 ? () => setState(() => count--) : null, icon: const Icon(Icons.remove, color: AppColors.primary)),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$count', style: const TextStyle(fontWeight: FontWeight.w800)),
                              if (selectedHospital != null)
                                Text(
                                  'Available: $availableQty',
                                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                                ),
                            ],
                          ),
                          IconButton(onPressed: selectedHospital != null && availableQty > 0 && count < availableQty ? () => setState(() => count = (count + 1).clamp(1, availableQty)) : null, icon: const Icon(Icons.add, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _field(child: TextField(controller: hospitalNameController, decoration: const InputDecoration(border: InputBorder.none, hintText: 'Hospital Name'))),
              const SizedBox(height: 12),
              _field(child: TextField(controller: addressController, onChanged: (_) => setState(() {}), decoration: const InputDecoration(border: InputBorder.none, hintText: 'Delivery Address'))),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(16),
                child: _field(child: Align(alignment: Alignment.centerLeft, child: Text(receiveDate == null ? 'Select Delivery Date' : 'Delivery Date: ${receiveDate!.day}/${receiveDate!.month}/${receiveDate!.year}'))),
              ),
              const SizedBox(height: 12),
              if (addressController.text.trim().isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(15)),
                  child: const Row(children: [Icon(Icons.local_shipping_rounded, color: AppColors.primary), SizedBox(width: 10), Text('Delivery Fee: EGP 50', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text))]),
                ),
              const SizedBox(height: 20),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: selectedBlood != null && selectedHospital != null && receiveDate != null && count > 0 && hospitalNameController.text.trim().isNotEmpty && addressController.text.trim().isNotEmpty ? _goToPayment : null,
                  child: const Text('Next', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DesktopPaymentPage extends StatelessWidget {
  final String bloodType;
  final String hospital;
  final int quantity;
  final DateTime receiveDate;
  final String orderType;
  final String? deliveryAddress;
  final double? deliveryFee;

  const DesktopPaymentPage({
    super.key,
    required this.bloodType,
    required this.hospital,
    required this.quantity,
    required this.receiveDate,
    required this.orderType,
    this.deliveryAddress,
    this.deliveryFee,
  });

  @override
  Widget build(BuildContext context) {
    // PaymentScreen already contains the responsive desktop/tablet layout.
    // Reusing it here avoids a nested Scaffold and keeps the payment flow
    // and Firebase/order logic exactly the same as the mobile version.
    return PayNow(
      bloodType: bloodType,
      hospital: hospital,
      quantity: quantity,
      receiveDate: receiveDate,
      orderType: orderType,
      deliveryAddress: deliveryAddress,
      deliveryFee: deliveryFee,
    );
  }
}
