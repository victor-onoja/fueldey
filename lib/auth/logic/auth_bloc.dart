import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_repo.dart';
import 'auth_state.dart';
import 'user_model.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<UserModel?>? _userSubscription;

  AuthBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthState.unknown()) {
    on<AuthPhoneNumberSubmitted>(_onPhoneNumberSubmitted);
    on<AuthOtpSubmitted>(_onOtpSubmitted);
    on<AuthCreateUser>(_onCreateUser);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignOut>(_onSignOut);

    _userSubscription = _authRepository.userStream.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  Future<void> _onPhoneNumberSubmitted(
    AuthPhoneNumberSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.verifyPhone(
        phoneNumber: event.phoneNumber,
        onCodeSent: (String verificationId) {
          emit(AuthState.otpSent(verificationId));
        },
        onError: (String error) {
          emit(AuthState.error(error));
        },
      );
    } catch (error) {
      emit(AuthState.error(error.toString()));
    }
  }

  Future<void> _onOtpSubmitted(
    AuthOtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state.verificationId == null) return;

    try {
      await _authRepository.verifyOTP(
        verificationId: state.verificationId!,
        otp: event.otp,
      );
    } catch (error) {
      emit(AuthState.error(error.toString()));
    }
  }

  Future<void> _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    await _authRepository.signOut();
    emit(const AuthState.unauthenticated());
  }

  Future<void> _onCreateUser(
    AuthCreateUser event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.createUser(
        username: event.username,
        phoneNumber: event.phoneNumber,
      );
    } catch (error) {
      emit(AuthState.error(error.toString()));
    }
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    emit(
      event.user != null
          ? AuthState.authenticated(event.user!)
          : const AuthState.unauthenticated(),
    );
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
