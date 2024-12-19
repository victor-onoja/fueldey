import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../business_logic/map/map_screen.dart';
import '../utils/app_theme_colors.dart';
import 'auth_bloc.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Authentication failed'),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state.status == AuthStatus.authenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MapScreen()),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo
                  Image.asset(
                    'assets/images/logo.webp',
                    height: 150,
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Welcome to Fuel Finder',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Find the nearest fuel stations with fuel with ease',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 48),

                  // Sign In Buttons
                  _buildSignInButton(
                    context,
                    onPressed: () =>
                        context.read<AuthBloc>().add(AuthSignInWithGoogle()),
                    icon: 'assets/icons/google_logo.png',
                    label: 'Continue with Google',
                  ),
                  const SizedBox(height: 16),
                  _buildSignInButton(
                    context,
                    onPressed: () =>
                        context.read<AuthBloc>().add(AuthSignInWithApple()),
                    icon: 'assets/icons/apple_logo.jpeg',
                    label: 'Continue with Apple',
                  ),
                  const SizedBox(height: 16),
                  _buildSignInButton(
                    context,
                    onPressed: () =>
                        context.read<AuthBloc>().add(AuthSignInAsGuest()),
                    icon: 'assets/icons/guest_icon.png',
                    label: 'Continue as Guest',
                  ),

                  // Loading indicator
                  if (state.status == AuthStatus.unknown)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignInButton(
    BuildContext context, {
    required VoidCallback onPressed,
    required String icon,
    required String label,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: SvgPicture.asset(
        icon,
        width: 24,
        height: 24,
      ),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.text,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
