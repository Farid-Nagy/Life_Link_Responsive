import 'package:flutter/material.dart';
import 'package:lifelink/core/responsive/responsive_layout.dart';
import 'package:lifelink/features/desktop/screens/desktop_home_screen.dart';
import 'package:lifelink/features/mobile/screens/home_screen.dart';

/// One entry point for Home across all screen sizes.
///
/// The responsive decision lives here; the mobile and desktop screens remain
/// separated in the folder structure while Firebase/business widgets are
/// reused instead of duplicated.
class HomeResponsiveShell extends StatelessWidget {
  const HomeResponsiveShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const HomeScreen(),
      tablet: const DesktopHomeScreen(),
      desktop: const DesktopHomeScreen(),
    );
  }
}
