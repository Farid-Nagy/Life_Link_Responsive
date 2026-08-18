import 'package:flutter/material.dart';
import 'package:lifelink/core/theme/app_colors.dart';
import 'package:lifelink/features/shared/widgets/home_responsive_shell.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:lifelink/network_wrapper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false;
  bool _messageVisible = false;
  bool _obscurePassword = true;

  void showMessage(String text, {Color color = AppColors.danger}) {
    if (!mounted || _messageVisible) return;
    _messageVisible = true;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(text),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
          ),
        )
        .closed
        .then((_) {
      if (mounted) _messageVisible = false;
    });
  }

  Future<void> signUp() async {
    setState(() => isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': _usernameController.text.trim(),
        'nationalid': _nationalIdController.text.trim(),
        'phone': _phoneNumberController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'user',
      });

      if (!mounted) return;
      showMessage('Account created successfully ✅', color: AppColors.success);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeResponsiveShell()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showMessage(
        e.code == 'network-request-failed' ? '❌ No Internet Connection' : getErrorMessage(e),
      );
    } catch (_) {
      if (mounted) showMessage('An unexpected error occurred, please try again');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already in use';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      default:
        return 'An unexpected error occurred, please try again';
    }
  }

  InputDecoration _inputDecoration({required IconData icon, required String hint, bool password = false}) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      hintText: hint,
      suffixIcon: password
          ? IconButton(
              onPressed: isLoading ? null : () => setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              ),
            )
          : null,
    );
  }

  Widget _brandPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(52),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 112,
                height: 112,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Image.asset('images/logo.png'),
              ),
              const SizedBox(height: 24),
              const Text(
                'LIFE LINK',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'welcome!\nHere you can Sign Up',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _form({required bool desktop}) {
    final fields = [
      TextField(
        controller: _usernameController,
        enabled: !isLoading,
        decoration: _inputDecoration(icon: Icons.person_outline, hint: 'UserName'),
      ),
      TextField(
        controller: _nationalIdController,
        enabled: !isLoading,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(14),
        ],
        decoration: _inputDecoration(icon: Icons.badge_outlined, hint: 'National ID'),
      ),
      TextField(
        controller: _phoneNumberController,
        enabled: !isLoading,
        keyboardType: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: _inputDecoration(icon: Icons.phone_outlined, hint: 'Phone number'),
      ),
      TextField(
        controller: _emailController,
        enabled: !isLoading,
        keyboardType: TextInputType.emailAddress,
        decoration: _inputDecoration(icon: Icons.email_outlined, hint: 'Email'),
      ),
      TextField(
        controller: _passwordController,
        enabled: !isLoading,
        obscureText: _obscurePassword,
        decoration: _inputDecoration(icon: Icons.lock_outline, hint: 'Password', password: true),
      ),
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Container(
        padding: EdgeInsets.all(desktop ? 34 : 16),
        decoration: desktop
            ? BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowSoft,
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              )
            : null,
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (!desktop) ...[
                Image.asset('images/logo.png', width: 170, height: 170),
                const Text(
                  'LIFE LINK',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
              if (!desktop) const SizedBox(height: 4),
              Align(
                alignment: desktop ? Alignment.centerLeft : Alignment.center,
                child: Text(
                  'welcome!\nHere you can Sign Up',
                  textAlign: desktop ? TextAlign.left : TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                    fontSize: desktop ? 16 : 18,
                    color: desktop ? AppColors.muted : AppColors.primary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              for (var i = 0; i < fields.length; i++) ...[
                fields[i],
                if (i != fields.length - 1) const SizedBox(height: 12),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (_usernameController.text.isEmpty ||
                              _nationalIdController.text.isEmpty ||
                              _phoneNumberController.text.isEmpty ||
                              _emailController.text.isEmpty ||
                              _passwordController.text.isEmpty) {
                            showMessage('Please fill in all fields');
                          } else if (_nationalIdController.text.trim().length != 14) {
                            showMessage('National ID must be exactly 14 digits');
                          } else {
                            signUp();
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                        )
                      : const Text(
                          'Sign up',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nationalIdController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NetworkWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'LifeLink',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 900;
              if (!desktop) {
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: _form(desktop: false),
                  ),
                );
              }
              return Row(
                children: [
                  Expanded(child: _brandPanel()),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: _form(desktop: true),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
