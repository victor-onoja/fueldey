import 'package:equatable/equatable.dart';

import 'user_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthPhoneNumberSubmitted extends AuthEvent {
  final String phoneNumber;

  const AuthPhoneNumberSubmitted(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class AuthOtpSubmitted extends AuthEvent {
  final String otp;

  const AuthOtpSubmitted(this.otp);

  @override
  List<Object> get props => [otp];
}

class AuthCreateUser extends AuthEvent {
  final String username;
  final String phoneNumber;

  const AuthCreateUser({
    required this.username,
    required this.phoneNumber,
  });

  @override
  List<Object> get props => [username, phoneNumber];
}

class AuthUserChanged extends AuthEvent {
  final UserModel? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthSignOut extends AuthEvent {}
