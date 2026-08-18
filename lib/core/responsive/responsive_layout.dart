import 'package:flutter/material.dart';
import 'package:lifelink/core/responsive/app_breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.desktop) {
      return desktop ?? tablet ?? mobile;
    }
    if (width >= AppBreakpoints.tablet) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}
