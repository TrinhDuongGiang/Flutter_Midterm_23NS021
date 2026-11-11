
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _authService = AuthService();

  bool _showPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signIn(
        email: _email.text,
        password: _password.text,
      );

      if (!mounted) return;

    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authService.getErrorMessage(error)),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.pastelGradient,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              left: -100,
              child: _bubble(310),
            ),
            Positioned(
              bottom: -130,
              right: -90,
              child: _bubble(360),
            ),
            const Positioned(
              top: 45,
              left: 55,
              child: _Star(28),
            ),
            const Positioned(
              top: 110,
              right: 75,
              child: _Star(35),
            ),
            const Positioned(
              bottom: 85,
              left: 80,
              child: _Star(26),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.lavender.withValues(alpha: 0.45),
                            blurRadius: 45,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: desktop
                            ? Row(
                                children: [
                                  Expanded(child: _illustration()),
                                  Expanded(child: _loginForm()),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _mobileHeader(),
                                  _loginForm(),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.25),
      ),
    );
  }

  Widget _catImage(double height) {
    return Image.asset(
      'assets/images/cat_laptop.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Icon(
        Icons.pets_rounded,
        size: height * 0.55,
        color: AppTheme.primary,
      ),
    );
  }

  Widget _illustration() {
    return SizedBox(
      height: 610,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.cloudBlue,
                  AppTheme.softLilac,
                  AppTheme.lavender,
                ],
              ),
            ),
          ),
          const Positioned(
            top: 45,
            left: 45,
            child: _Star(25),
          ),
          const Positioned(
            top: 85,
            right: 55,
            child: _Star(33),
          ),
          Positioned(
            bottom: -10,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.75,
              child: Image.asset(
                'assets/images/clouds.png',
                height: 185,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _catImage(290),
                const SizedBox(height: 10),
                const Text(
                  'DuongGiang',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'User Management System',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  '',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      decoration: const BoxDecoration(
        gradient: AppTheme.pastelGradient,
      ),
      child: Column(
        children: [
          _catImage(130),
          const Text(
            'DuongGiang',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 48,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.pets_rounded, color: AppTheme.primary),
                  SizedBox(width: 10),
                  Text(
                    'ADMIN',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),
              const Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sign in to your dashboard.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 35),
              const Text(
                'Email address',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _email,
                enabled: !_isLoading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'admin@example.com',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(email)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              const Text(
                'Password',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _password,
                enabled: !_isLoading,
                obscureText: !_showPassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _login(),
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Please enter your password'
                        : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppTheme.buttonGradient,
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.lavender.withValues(alpha: 0.65),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Sign In  →',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  'A lovely place to manage your users ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Star extends StatelessWidget {
  final double size;

  const _Star(this.size);

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.auto_awesome_rounded,
      size: size,
      color: Colors.white,
    );
  }
}
