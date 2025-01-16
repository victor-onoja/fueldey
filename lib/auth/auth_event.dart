part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthUserChanged extends AuthEvent {
  final User? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthSignInAsGuest extends AuthEvent {}

class AuthSignInAsModerator extends AuthEvent {
  final String stationName;
  final String moderatorName;

  const AuthSignInAsModerator({
    required this.stationName,
    required this.moderatorName,
  });

  @override
  List<Object> get props => [stationName, moderatorName];
}

class AuthSignOut extends AuthEvent {}
