import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'data/auth_provider.dart';
import 'data/username_provider.dart';

import 'package:url_launcher/url_launcher.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  Future<void> _launchPrivacyPolicy() async {}

  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToPrivacy = false;

  Timer? _debounce;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter email';
    }

    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter password';
    }

    if (value.length < 6) {
      return 'Minimum 6 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (context.read<UsernameProvider>().isAvailable != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose an available username'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _usernameController.text.trim(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: const Color(0xFFFF4E50),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration fieldStyle({required String hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.white38,
        fontWeight: FontWeight.w500,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.04),
      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.04)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: const Color(0xFFE0EAFC).withOpacity(0.15),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usernameProvider = context.watch<UsernameProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(
            left: -140,
            top: -100,
            child: Container(
              width: 340,
              height: 340,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Color(0xFFE0EAFC),
                    Color(0xFFFF4E50),
                    Color(0xFF3F2B96),
                    Color(0xFFE0EAFC),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(
                color: const Color(0xFF0D0D0D).withOpacity(0.72),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 390),
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TOP CHIP
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Text(
                          "WaveOn",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),
                      const Text(
                        "Sync up. Press play.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          height: 1.1,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Sync music with people around you.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.42),
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _usernameController,
                        onChanged: (value) {
                          context.read<UsernameProvider>().checkUsername(value);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter username';
                          }

                          if (value.length < 3) {
                            return 'Minimum 3 characters';
                          }

                          if (RegExp(r'\s').hasMatch(value)) {
                            return 'No spaces allowed';
                          }

                          if (context.read<UsernameProvider>().isAvailable ==
                              false) {
                            return 'Username taken';
                          }

                          return null;
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: fieldStyle(
                          hint: "Username",
                          suffix: usernameProvider.isChecking
                              ? const Padding(
                                  padding: EdgeInsets.all(14),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white54,
                                    ),
                                  ),
                                )
                              : usernameProvider.isAvailable == true
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.greenAccent,
                                  size: 20,
                                )
                              : usernameProvider.isAvailable == false
                              ? const Icon(
                                  Icons.cancel_rounded,
                                  color: Color(0xFFFF4E50),
                                  size: 20,
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 6),

                      TextFormField(
                        controller: _emailController,
                        validator: _validateEmail,
                        style: const TextStyle(color: Colors.white),
                        decoration: fieldStyle(hint: "Email"),
                      ),

                      const SizedBox(height: 6),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: _validatePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: fieldStyle(
                          hint: "Password",
                          suffix: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: Colors.white38,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        validator: _validateConfirmPassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: fieldStyle(
                          hint: "Confirm Password",
                          suffix: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: Colors.white38,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _agreedToPrivacy = !_agreedToPrivacy;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _agreedToPrivacy
                                    ? const Color(0xFFE0EAFC).withOpacity(0.2)
                                    : Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _agreedToPrivacy
                                      ? const Color(0xFFE0EAFC)
                                      : Colors.white.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: _agreedToPrivacy
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: Color(0xFFE0EAFC),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: GestureDetector(
                              onTap: _launchPrivacyPolicy,
                              child: Text.rich(
                                TextSpan(
                                  text: "I have read and agree to the ",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.42),
                                    fontSize: 13,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: "Privacy Policy",
                                      style: TextStyle(
                                        color: Color(0xFFE0EAFC),
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_isLoading || !_agreedToPrivacy)
                              ? null
                              : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _agreedToPrivacy
                                ? Colors.white.withOpacity(0.08)
                                : Colors.white.withOpacity(0.02),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Create Account",
                                  style: TextStyle(
                                    color: _agreedToPrivacy
                                        ? Colors.white
                                        : Colors.white38,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Center(
                        child: GestureDetector(
                          onTap: () {
                            context.go('/login');
                          },
                          child: Text.rich(
                            TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.35),
                                fontSize: 14,
                              ),
                              children: const [
                                TextSpan(
                                  text: "Sign in",
                                  style: TextStyle(
                                    color: Color(0xFFE0EAFC),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
