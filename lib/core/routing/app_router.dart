import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/login_screen.dart';
import '../../auth/presentation/signup_screen.dart';
import '../../auth/presentation/forgot_password_screen.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../doctor/presentation/doctor_dashboard_screen.dart';
import '../../appointments/presentation/appointments_list_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../auth/application/auth_controller.dart';
import '../domain/user_role.dart';

/// Centralized definition of all routes in the Patient app.
GoRouter createAppRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: SplashScreen.routePath,
    refreshListenable: GoRouterRefreshStream(
      ref.read(authControllerProvider.notifier).authStream,
    ),
    routes: [
      GoRoute(
        path: SplashScreen.routePath,
        name: SplashScreen.routeName,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: LoginScreen.routePath,
        name: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: SignupScreen.routePath,
        name: SignupScreen.routeName,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: ForgotPasswordScreen.routePath,
        name: ForgotPasswordScreen.routeName,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: DoctorDashboardScreen.routePath,
        name: DoctorDashboardScreen.routeName,
        builder: (context, state) => const DoctorDashboardScreen(),
      ),
      GoRoute(
        path: DashboardScreen.routePath,
        name: DashboardScreen.routeName,
        builder: (context, state) => const DashboardScreen(),
        routes: [
          GoRoute(
            path: AppointmentsListScreen.subRoutePath,
            name: AppointmentsListScreen.routeName,
            builder: (context, state) => const AppointmentsListScreen(),
          ),
          GoRoute(
            path: HistoryScreen.subRoutePath,
            name: HistoryScreen.routeName,
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: ProfileScreen.subRoutePath,
            name: ProfileScreen.routeName,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: NotificationsScreen.subRoutePath,
            name: NotificationsScreen.routeName,
            builder: (context, state) => const NotificationsScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isLoggedIn = authState.status == AuthStatus.authenticated;

      final loggingIn = state.matchedLocation == LoginScreen.routePath ||
          state.matchedLocation == SignupScreen.routePath ||
          state.matchedLocation == ForgotPasswordScreen.routePath;

      if (!isLoggedIn && !loggingIn) {
        return LoginScreen.routePath;
      }

      if (isLoggedIn && loggingIn) {
        final role = authState.role;
        if (role == UserRole.medecin) {
          return DoctorDashboardScreen.routePath;
        }
        return DashboardScreen.routePath;
      }

      return null;
    },
  );
}

/// Helper class to allow GoRouter to listen to a Stream and refresh
/// navigation when the authentication state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Simple splash screen used to bootstrap the app and redirect based on auth.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const routeName = 'splash';
  static const routePath = '/';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}


