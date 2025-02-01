import 'package:equatable/equatable.dart';

import 'user_model.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  otpSent,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final String? verificationId;

  const AuthState._({
    this.status = AuthStatus.unknown,
    this.user,
    this.errorMessage,
    this.verificationId,
  });

  const AuthState.unknown() : this._();

  const AuthState.authenticated(UserModel user)
      : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  const AuthState.otpSent(String verificationId)
      : this._(status: AuthStatus.otpSent, verificationId: verificationId);

  const AuthState.error(String message)
      : this._(status: AuthStatus.error, errorMessage: message);

  @override
  List<Object?> get props => [status, user, errorMessage, verificationId];
}
