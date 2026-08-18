import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:lifelink/core/theme/app_colors.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkWrapper extends StatefulWidget {
  final Widget child;

  const NetworkWrapper({super.key, required this.child});

  @override
  State<NetworkWrapper> createState() => _NetworkWrapperState();
}

class _NetworkWrapperState extends State<NetworkWrapper> {
  bool? _hasInternet;
  StreamSubscription? _subscription;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initNetworkListener();
  }

  Future<void> _initNetworkListener() async {
    // تحديد الحالة الأولية بصمت
    _hasInternet = kIsWeb
        ? (await Connectivity().checkConnectivity()).any((result) => result != ConnectivityResult.none)
        : await InternetConnectionChecker().hasConnection;

    // مراقبة تغيرات الشبكة
    _subscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) async {
      if (_isProcessing) return;
      _isProcessing = true;

      bool currentStatus = kIsWeb
          ? (await Connectivity().checkConnectivity()).any((result) => result != ConnectivityResult.none)
          : await InternetConnectionChecker().hasConnection;

      // لو الحالة مغيرتش فعلياً -> تجاهل
      if (currentStatus == _hasInternet) {
        _isProcessing = false;
        return;
      }

      _hasInternet = currentStatus;

      if (mounted) {
        _showStatusSnackBar(currentStatus);
      }

      // تأخير بسيط لضمان استقرار الإشارات ومنع الـ Double trigger
      await Future.delayed(const Duration(milliseconds: 500));
      _isProcessing = false;
    });
  }

  /// دالة إظهار الرسالة بنفس ستايل الـ Login بالضبط
  void _showStatusSnackBar(bool isOnline) {
    // أهم خطوة لمنع تكرار الرسائل أو تراكمها
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isOnline
              ? "✅ Internet connection restored"
              : "❌ No Internet Connection",
          style: const TextStyle(
            fontFamily: "Cairo", // نفس الخط اللي في مشروعك
            fontWeight: FontWeight.bold,
          ),
        ),
        // اللون الأحمر للفصل والأخضر للرجوع
        backgroundColor: isOnline ? AppColors.success : AppColors.danger,
        duration: const Duration(seconds: 2),
        // لو حابب تخليها طايرة (Floating) زي الـ Premium apps فك التعليق عن السطرين دول:
        // behavior: SnackBarBehavior.floating,
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}