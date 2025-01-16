import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fueldey/auth/auth_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../business_logic/fuel_station/moderator_validator.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final ModeratorValidator _moderatorValidator;

  AuthBloc({
    required AuthRepository authRepository,
    required ModeratorValidator moderatorValidator,
  })  : _authRepository = authRepository,
        _moderatorValidator = moderatorValidator,
        super(const AuthState.unknown()) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInAsGuest>(_onSignInAsGuest);
    on<AuthSignInAsModerator>(_onSignInAsModerator);
    on<AuthSignOut>(_onSignOut);

    _authRepository.user.listen((user) {
      add(AuthUserChanged(user));
    });
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    emit(event.user != null
        ? AuthState.authenticated(event.user!)
        : const AuthState.unauthenticated());
  }

  Future<void> _onSignInAsGuest(
      AuthSignInAsGuest event, Emitter<AuthState> emit) async {
    try {
      final user = await _authRepository.signInAnonymously();
      emit(user != null
          ? AuthState.authenticated(user)
          : const AuthState.unauthenticated());
    } catch (error) {
      emit(AuthState.error(error.toString()));
    }
  }

  Future<void> _onSignInAsModerator(
    AuthSignInAsModerator event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isValidModerator = await _moderatorValidator.validateModerator(
        event.stationName,
        event.moderatorName,
      );

      if (!isValidModerator) {
        emit(const AuthState.error('Invalid moderator credentials'));
        return;
      }

      final user = await _authRepository.signInAnonymously();
      if (user != null) {
        emit(AuthState.authenticated(
          user,
          isModerator: true,
          stationName: event.stationName,
          moderatorName: event.moderatorName,
        ));
      } else {
        emit(const AuthState.error('Failed to sign in'));
      }
    } catch (error) {
      emit(AuthState.error(error.toString()));
    }
  }

  Future<void> _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    await _authRepository.signOut();
    emit(const AuthState.unauthenticated());
  }
}
