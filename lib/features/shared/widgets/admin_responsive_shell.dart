import 'package:flutter/material.dart';
import 'package:lifelink/core/responsive/responsive_layout.dart';
import 'package:lifelink/features/desktop/screens/desktop_admin_screen.dart';
import 'package:lifelink/features/mobile/screens/admin.dart';

class AdminResponsiveShell extends StatelessWidget {
  const AdminResponsiveShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const AdminPage(),
      tablet: const DesktopAdminScreen(),
      desktop: const DesktopAdminScreen(),
    );
  }
}
