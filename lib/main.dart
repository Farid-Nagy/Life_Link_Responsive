import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lifelink/core/responsive/responsive_layout.dart';
import 'package:lifelink/core/theme/app_theme.dart';
import 'package:lifelink/features/mobile/screens/about_page.dart';
import 'package:lifelink/features/mobile/screens/admin_orders_page.dart';
import 'package:lifelink/features/mobile/screens/admin_reports_page.dart';
import 'package:lifelink/features/mobile/screens/admin_users_page.dart';
import 'package:lifelink/features/mobile/screens/blood_inventory.dart';
import 'package:lifelink/features/mobile/screens/blood_type_page.dart';
import 'package:lifelink/features/mobile/screens/delivery_page.dart';
import 'package:lifelink/features/mobile/screens/login_screen.dart';
import 'package:lifelink/features/mobile/screens/my_data_page.dart';
import 'package:lifelink/features/mobile/screens/intro_screen.dart';
import 'package:lifelink/features/mobile/screens/signup_screen.dart';
import 'package:lifelink/features/desktop/screens/desktop_service_pages.dart';
import 'package:lifelink/features/shared/widgets/admin_responsive_shell.dart';
import 'package:lifelink/features/shared/widgets/home_responsive_shell.dart';
import 'package:lifelink/firebase_options.dart';
import 'package:lifelink/network_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const IntroScreen(),
      routes: {
        'scaleDemo': (_) => const IntroScreen(),
        'admin': (_) => NetworkWrapper(child: const AdminResponsiveShell()),
        'homeScreen': (_) => NetworkWrapper(child: const HomeResponsiveShell()),
        'bloodInventoryAdmin': (_) => NetworkWrapper(
          child: ResponsiveLayout(
            mobile: const BloodInventoryAdminPage(),
            tablet: const DesktopBloodInventoryPage(),
            desktop: const DesktopBloodInventoryPage(),
          ),
        ),
        'adminOrdersScreen': (_) => NetworkWrapper(
          child: ResponsiveLayout(
            mobile: const AdminOrdersPage(),
            tablet: const DesktopAdminOrdersPage(),
            desktop: const DesktopAdminOrdersPage(),
          ),
        ),
        'usersAdmin': (_) => NetworkWrapper(
          child: ResponsiveLayout(
            mobile: const AdminUsersPage(),
            tablet: const DesktopAdminUsersPage(),
            desktop: const DesktopAdminUsersPage(),
          ),
        ),
        'reportsAdmin': (_) => NetworkWrapper(
          child: ResponsiveLayout(
            mobile: const AdminReportsPage(),
            tablet: const DesktopAdminReportsPage(),
            desktop: const DesktopAdminReportsPage(),
          ),
        ),
        'loginScreen': (_) => const LoginScreen(),
        'signupScreen': (_) => const SignupScreen(),
        'myData': (_) => NetworkWrapper(
          child: ResponsiveLayout(
            mobile: const MyDataScreen(),
            tablet: const DesktopMyDataPage(),
            desktop: const DesktopMyDataPage(),
          ),
        ),
        'aboutPage': (_) => NetworkWrapper(
          child: ResponsiveLayout(
            mobile: const AboutPage(),
            tablet: const DesktopAboutPage(),
            desktop: const DesktopAboutPage(),
          ),
        ),
        'bloodTypePage': (_) => NetworkWrapper(
          child: ResponsiveLayout(
            mobile: const BloodTypePage(),
            tablet: const DesktopBloodTypePage(),
            desktop: const DesktopBloodTypePage(),
          ),
        ),
        'deliverypage': (_) => NetworkWrapper(
          child: ResponsiveLayout(
            mobile: const DeliveryPage(),
            tablet: const DesktopDeliveryPage(),
            desktop: const DesktopDeliveryPage(),
          ),
        ),
      },
    );
  }
}
