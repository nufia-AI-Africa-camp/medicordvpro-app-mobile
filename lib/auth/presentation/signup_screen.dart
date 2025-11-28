import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/auth_service.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../application/auth_controller.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  static const routeName = 'signup';
  static const routePath = '/auth/signup';

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Vérifier que les mots de passe correspondent
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Les mots de passe ne correspondent pas.');
      return;
    }

    setState(() => _submitting = true);

    try {
      await ref.read(authControllerProvider.notifier).signup(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            password: _passwordController.text,
          );

      final authState = ref.read(authControllerProvider);
      if (authState.status == AuthStatus.authenticated) {
        if (!mounted) return;
        // Rediriger vers le dashboard patient
        context.go(DashboardScreen.routePath);
      }
    } on AuthFailure catch (error, stackTrace) {
      developer.log(
        'Signup failed',
        error: error,
        stackTrace: stackTrace,
        name: 'SignupScreen',
      );
      _showError(error.message);
    } catch (error, stackTrace) {
      developer.log(
        'Unexpected error during signup: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'SignupScreen',
      );
      
      // Si c'est une AuthFailure, elle a déjà été gérée dans le bloc on AuthFailure
      // Ce bloc catch ne devrait capturer que les vraies erreurs inattendues
      String errorMessage = 'Une erreur inattendue est survenue.';
      if (error is AuthFailure) {
        errorMessage = error.message;
      } else {
        errorMessage = 'Erreur: ${error.toString()}';
      }
      
      _showError(errorMessage);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
            colors: [
              backgroundGradientTop,
              backgroundGradientBottom,
            ],
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
                                        isSelected: false,
                                        onTap: () {
                                          context.go(LoginScreen.routePath);
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: _SegmentButton(
                                        label: 'Inscription',
                                        isSelected: true,
                                        onTap: () {
                                          // déjà sur inscription
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Nom / Prénom
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _firstNameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Prénom',
                                      ),
                                      textCapitalization: TextCapitalization.words,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Veuillez renseigner votre prénom';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _lastNameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Nom',
                                      ),
                                      textCapitalization: TextCapitalization.words,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Veuillez renseigner votre nom';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

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
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Veuillez renseigner votre email';
                                  }
                                  if (!value.contains('@') || !value.contains('.')) {
                                    return 'Veuillez entrer un email valide';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Téléphone
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Téléphone',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Veuillez renseigner votre téléphone';
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
                                  prefixIcon:
                                      const Icon(Icons.lock_outline_rounded),
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
                                  if (value.length < 6) {
                                    return 'Le mot de passe doit contenir au moins 6 caractères';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Confirmation
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                decoration: InputDecoration(
                                  labelText: 'Confirmer le mot de passe',
                                  prefixIcon:
                                      const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez confirmer votre mot de passe';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

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
                                      : const Text("S'inscrire"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'En vous inscrivant, vous acceptez nos conditions '
                        "d’utilisation et notre politique de confidentialité.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
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

