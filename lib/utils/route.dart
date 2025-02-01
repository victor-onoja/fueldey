import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../auth/logic/auth_bloc.dart';
import '../auth/logic/auth_state.dart';
import '../auth/logic/user_model.dart';
import '../business_logic/map/admin_dashboard.dart';
import '../business_logic/map/map_screen.dart';
import '../business_logic/map/profile_screen.dart';
import '../business_logic/map/station_management_screen.dart';
import 'route_guard.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MapScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) {
        final authState = context.read<AuthBloc>().state;
        if (authState.user?.role != UserRole.admin) {
          return const UnauthorizedScreen();
        }
        return const AdminDashboard();
      },
    ),
    GoRoute(
      path: '/station-management',
      builder: (context, state) {
        final authState = context.read<AuthBloc>().state;
        if (authState.user?.role != UserRole.moderator &&
            authState.user?.role != UserRole.admin) {
          return const UnauthorizedScreen();
        }
        return const StationManagementScreen();
      },
    ),
  ],
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final isAuthenticated = authState.status == AuthStatus.authenticated;

    if (!isAuthenticated && state.location != '/login') {
      return '/login';
    }
    return null;
  },
);
