import 'package:flutter/material.dart';

import '../auth/logic/user_model.dart';

class RouteGuard {
  static bool canAccess(UserRole? userRole, List<UserRole> allowedRoles) {
    if (userRole == null) return false;
    return allowedRoles.contains(userRole);
  }
}

class SecureRoute extends StatelessWidget {
  final Widget child;
  final List<UserRole> allowedRoles;
  final Widget? fallbackRoute;
  final UserRole? userRole;

  const SecureRoute({
    super.key,
    required this.child,
    required this.allowedRoles,
    required this.userRole,
    this.fallbackRoute,
  });

  @override
  Widget build(BuildContext context) {
    if (RouteGuard.canAccess(userRole, allowedRoles)) {
      return child;
    }

    return fallbackRoute ?? const UnauthorizedScreen();
  }
}

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unauthorized'),
      ),
      body: const Center(
        child: Text('You do not have permission to access this page.'),
      ),
    );
  }
}
