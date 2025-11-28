import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/user_role.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../doctor/presentation/doctor_dashboard_screen.dart';
import '../application/auth_controller.dart';
import '../../core/services/auth_service.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const routeName = 'login';
  static const routePath = '/auth/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _submitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    
    try {
      // Connexion avec détection automatique du rôle
      final detectedRole = await ref
          .read(authControllerProvider.notifier)
          .loginAuto(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (detectedRole == null) {
        _showError('Identifiants invalides.');
        return;
      }

      final authState = ref.read(authControllerProvider);
      if (authState.status == AuthStatus.authenticated) {
        if (!mounted) return;
        
        // Rediriger selon le rôle détecté
        if (detectedRole == UserRole.medecin) {
          context.go(DoctorDashboardScreen.routePath);
        } else {
          context.go(DashboardScreen.routePath);
        }
      }
    } on AuthFailure catch (error, stackTrace) {
      developer.log(
        'Login failed',
        error: error,
        stackTrace: stackTrace,
        name: 'LoginScreen',
      );
      _showError(error.message);
    } catch (error, stackTrace) {
      developer.log(
        'Unexpected error during login: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'LoginScreen',
      );
      _showError(
        'Une erreur inattendue est survenue: ${error.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D5BFF);
    const backgroundGradientTop = Color(0xFFF4F7FF);
    const backgroundGradientBottom = Color(0xFFE8F0FF);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundGradientTop, backgroundGradientBottom],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Carte principale
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Logo + titre
                              Center(
                                child: Column(
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: primaryBlue,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(
                                        Icons.medical_services_outlined,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'MédicoRDV Pro',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Système de gestion de rendez-vous médicaux',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Onglets Connexion / Inscription
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F6FB),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _SegmentButton(
                                        label: 'Connexion',
                                        isSelected: true,
                                        onTap: () {
                                          // déjà sur connexion
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: _SegmentButton(
                                        label: 'Inscription',
                                        isSelected: false,
                                        onTap: () {
                                          context.go(SignupScreen.routePath);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Email
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'exemple@email.com',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez renseigner votre email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Mot de passe
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Mot de passe',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez renseigner votre mot de passe';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => context.push(
                                    ForgotPasswordScreen.routePath,
                                  ),
                                  child: const Text('Mot de passe oublié ?'),
                                ),
                              ),

                              const SizedBox(height: 8),
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryBlue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: _submitting ? null : _submit,
                                  child: _submitting
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Text('Se connecter'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Footer conditions
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'En vous connectant, vous acceptez nos conditions '
                        "d’utilisation et notre politique de confidentialité.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

