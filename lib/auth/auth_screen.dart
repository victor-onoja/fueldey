import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../business_logic/map/map_screen.dart';
import '../utils/app_theme_colors.dart';
import 'auth_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _stationNameController = TextEditingController();
  final _moderatorNameController = TextEditingController();
  bool _showModeratorFields = false;

  @override
  void dispose() {
    _stationNameController.dispose();
    _moderatorNameController.dispose();
    super.dispose();
  }

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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Logo
                    Image.asset(
                      'assets/images/logo.png',
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

                    _buildSignInButton(
                      context,
                      onPressed: () =>
                          context.read<AuthBloc>().add(AuthSignInAsGuest()),
                      icon: 'assets/icons/guest_icon.png',
                      label: 'Continue as User',
                    ),

                    const SizedBox(height: 24),

                    _buildSignInButton(
                      context,
                      onPressed: () {
                        setState(() {
                          _showModeratorFields = !_showModeratorFields;
                        });
                      },
                      icon: 'assets/icons/guest_icon.png',
                      label: 'Continue as Moderator',
                    ),

                    if (_showModeratorFields) ...[
                      const SizedBox(height: 24),
                      TextField(
                        controller: _stationNameController,
                        decoration: const InputDecoration(
                          labelText: 'Station Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _moderatorNameController,
                        decoration: const InputDecoration(
                          labelText: 'Moderator Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_stationNameController.text.isEmpty ||
                              _moderatorNameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please fill in all required fields'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }
                          context.read<AuthBloc>().add(
                                AuthSignInAsModerator(
                                  stationName: _stationNameController.text,
                                  moderatorName: _moderatorNameController.text,
                                ),
                              );
                        },
                        child: const Text('Sign In as Moderator'),
                      ),
                    ],

                    // Loading indicator
                    if (state.status == AuthStatus.unknown)
                      const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
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
      icon: Image.asset(
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
