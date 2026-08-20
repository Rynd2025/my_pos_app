part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;

  const RegisterRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class ResetPasswordRequested extends AuthEvent {
  final String email;
  final String tempPassword;

  const ResetPasswordRequested({required this.email, required this.tempPassword});

  @override
  List<Object?> get props => [email, tempPassword];
}

class LogoutRequested extends AuthEvent {}
