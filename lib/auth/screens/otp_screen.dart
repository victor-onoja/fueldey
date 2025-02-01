import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../business_logic/map/map_screen.dart';
import '../../utils/app_theme_colors.dart';
import '../logic/auth_bloc.dart';
import '../logic/auth_event.dart';
import '../logic/auth_state.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String? username;
  final String? phoneNumber;

  const OtpScreen({
    super.key,
    required this.verificationId,
    this.username,
    this.phoneNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Verification failed'),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state.status == AuthStatus.authenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MapScreen()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter the verification code sent to your phone',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                    labelText: 'OTP Code',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_otpController.text.length != 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid OTP'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    context
                        .read<AuthBloc>()
                        .add(AuthOtpSubmitted(_otpController.text));

                    if (widget.username != null && widget.phoneNumber != null) {
                      context.read<AuthBloc>().add(
                            AuthCreateUser(
                              username: widget.username!,
                              phoneNumber: widget.phoneNumber!,
                            ),
                          );
                    }
                  },
                  child: const Text('Verify'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
