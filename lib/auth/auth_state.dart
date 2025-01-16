part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool isModerator;
  final String? stationName;
  final String? moderatorName;

  const AuthState._({
    this.status = AuthStatus.unknown,
    this.user,
    this.errorMessage,
    this.isModerator = false,
    this.stationName,
    this.moderatorName,
  });

  const AuthState.unknown() : this._();

  const AuthState.authenticated(
    User user, {
    bool isModerator = false,
    String? stationName,
    String? moderatorName,
  }) : this._(
          status: AuthStatus.authenticated,
          user: user,
          isModerator: isModerator,
          stationName: stationName,
          moderatorName: moderatorName,
        );

  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  const AuthState.error(String errorMessage)
      : this._(status: AuthStatus.error, errorMessage: errorMessage);

  @override
  List<Object?> get props => [
        status,
        user,
        errorMessage,
        isModerator,
        stationName,
        moderatorName,
      ];
}
