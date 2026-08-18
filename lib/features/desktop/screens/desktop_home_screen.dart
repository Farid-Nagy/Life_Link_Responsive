import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lifelink/core/theme/app_colors.dart';
import 'package:lifelink/features/desktop/screens/desktop_service_pages.dart';

class DesktopHomeScreen extends StatefulWidget {
  const DesktopHomeScreen({super.key});

  @override
  State<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen> {
  int _selectedIndex = 1;
  String? _username;

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

  Widget _content() {
    switch (_selectedIndex) {
      case 0:
        return const DesktopMyDataPage();
      case 2:
        return const DesktopAboutPage();
      default:
        return const _DesktopHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          SizedBox(
            width: 264,
            child: _DesktopSidebar(
              selectedIndex: _selectedIndex,
              username: _selectedIndex == 1 ? _username : null,
              onSelected: (index) => setState(() => _selectedIndex = index),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                _DesktopHeader(username: _selectedIndex == 1 ? _username : null),
                Expanded(child: _content()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopHomeContent extends StatelessWidget {
  const _DesktopHomeContent();

  static const _bloodRows = [
    ('O-', 'Donates to everyone', 'Receives from O-'),
    ('O+', 'Donates to O+, A+, B+, AB+', 'Receives from O+, O-'),
    ('A-', 'Donates to A-, A+, AB-, AB+', 'Receives from A-, O-'),
    ('A+', 'Donates to A+, AB+', 'Receives from A+, A-, O-'),
    ('B-', 'Donates to B-, B+, AB-, AB+', 'Receives from B-, O-'),
    ('B+', 'Donates to B+, AB+', 'Receives from B+, B-, O-'),
    ('AB-', 'Donates to AB-, AB+', 'Receives from everyone'),
    ('AB+', 'Donates to AB+ only', 'Universal receiver'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 980;
        final contentWidth = constraints.maxWidth > 1320 ? 1280.0 : double.infinity;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 22, 26, 30),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _WelcomeStrip(),
                  const SizedBox(height: 18),
                  GridView.count(
                    crossAxisCount: compact ? 1 : 2,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: compact ? 4.8 : 3.55,
                    children: [
                      _DesktopServiceCard(
                        icon: Icons.local_shipping_rounded,
                        title: 'Delivery',
                        subtitle: 'Request blood delivery to your location',
                        onTap: () => Navigator.pushNamed(context, 'deliverypage'),
                      ),
                      _DesktopServiceCard(
                        icon: Icons.bloodtype_rounded,
                        title: 'Blood Bags Booking',
                        subtitle: 'Choose blood type and reserve bags',
                        onTap: () => Navigator.pushNamed(context, 'bloodTypePage'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const _SectionTitle(),
                  const SizedBox(height: 14),
                  GridView.builder(
                    itemCount: _bloodRows.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: compact ? 1 : 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      mainAxisExtent: compact ? 92 : 96,
                    ),
                    itemBuilder: (_, index) {
                      final row = _bloodRows[index];
                      return _DesktopBloodRow(row.$1, row.$2, row.$3);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WelcomeStrip extends StatelessWidget {
  const _WelcomeStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.favorite_rounded, color: AppColors.primary, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Blood connects us all',
              style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text),
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.muted),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Who Donates to Whom?',
        style: TextStyle(color: AppColors.white, fontSize: 19, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _DesktopBloodRow extends StatelessWidget {
  final String type;
  final String donate;
  final String receive;

  const _DesktopBloodRow(this.type, this.donate, this.receive);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent,
            ),
            alignment: Alignment.center,
            child: Text(
              type,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(donate, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.text)),
                const SizedBox(height: 4),
                Text(receive, style: const TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DesktopServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accentLight, AppColors.accent],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: Offset(0, 10)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(.16),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, size: 34, color: AppColors.white),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(color: AppColors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: AppColors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  final String? username;

  const _DesktopHeader({this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          const Text('Life Link', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.text)),
          const Spacer(),
          if (username?.trim().isNotEmpty == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(30)),
              child: Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(username!, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.text)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final String? username;
  final ValueChanged<int> onSelected;

  const _DesktopSidebar({required this.selectedIndex, required this.username, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 26),
            Container(
              width: 76,
              height: 76,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Image.asset('images/logo.png'),
            ),
            const SizedBox(height: 12),
            const Text('Life Link', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary)),
            if (username?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(username!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
              ),
            ],
            const SizedBox(height: 30),
            _Item(icon: Icons.home_rounded, label: 'Home', selected: selectedIndex == 1, onTap: () => onSelected(1)),
            _Item(icon: Icons.person_outline_rounded, label: 'My Data', selected: selectedIndex == 0, onTap: () => onSelected(0)),
            _Item(icon: Icons.info_outline_rounded, label: 'About', selected: selectedIndex == 2, onTap: () => onSelected(2)),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text('Blood connects us all', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.muted)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Item({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        dense: true,
        minLeadingWidth: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: selected ? AppColors.primarySoft : null,
        leading: Icon(icon, color: selected ? AppColors.primary : AppColors.muted),
        title: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: selected ? AppColors.primary : AppColors.text)),
        onTap: onTap,
      ),
    );
  }
}
