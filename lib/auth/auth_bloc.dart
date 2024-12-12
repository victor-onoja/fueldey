import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fueldey/auth/auth_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.unknown()) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInWithGoogle>(_onSignInWithGoogle);
    on<AuthSignInWithApple>(_onSignInWithApple);
    on<AuthSignInAsGuest>(_onSignInAsGuest);
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

  Future<void> _onSignInWithGoogle(
      AuthSignInWithGoogle event, Emitter<AuthState> emit) async {
    try {
      final user = await _authRepository.signInWithGoogle();
      emit(user != null
          ? AuthState.authenticated(user)
          : const AuthState.unauthenticated());
    } catch (error) {
      emit(AuthState.error(error.toString()));
    }
  }

  Future<void> _onSignInWithApple(
      AuthSignInWithApple event, Emitter<AuthState> emit) async {
    try {
      final user = await _authRepository.signInWithApple();
      emit(user != null
          ? AuthState.authenticated(user)
          : const AuthState.unauthenticated());
    } catch (error) {
      emit(AuthState.error(error.toString()));
    }
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

  Future<void> _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    await _authRepository.signOut();
    emit(const AuthState.unauthenticated());
  }
}
