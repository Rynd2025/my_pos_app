import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthState()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final result = await authRepository.getCurrentUser();
    result.fold(
      (failure) => emit(const AuthState(status: AuthStatus.unauthenticated)),
      (user) {
        if (user == null) {
          emit(const AuthState(status: AuthStatus.unauthenticated));
        } else if (!user.isDeviceAuthorized) {
          emit(AuthState(status: AuthStatus.unauthorized, user: user));
        } else {
          emit(AuthState(status: AuthStatus.authenticated, user: user));
        }
      },
    );
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState(status: AuthStatus.loading));
    final loginResult = await authRepository.login(event.username, event.password);
    
    await loginResult.fold(
      (failure) async => emit(AuthState(status: AuthStatus.error, message: failure.message)),
      (tokens) async {
        final userResult = await authRepository.getCurrentUser();
        userResult.fold(
          (failure) => emit(AuthState(status: AuthStatus.error, message: failure.message)),
          (user) {
            if (user == null) {
              emit(const AuthState(status: AuthStatus.unauthenticated));
            } else if (!user.isDeviceAuthorized) {
              emit(AuthState(status: AuthStatus.unauthorized, user: user));
            } else {
              emit(AuthState(status: AuthStatus.authenticated, user: user));
            }
          },
        );
      },
    );
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
