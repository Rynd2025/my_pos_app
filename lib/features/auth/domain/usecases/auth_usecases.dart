import '../../domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<bool> call(String email, String password) async {
    return repository.register(email, password);
  }
}

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<bool> call(String email, String password) async {
    return repository.login(email, password);
  }
}

class ResetPasswordUseCase {
  final AuthRepository repository;
  ResetPasswordUseCase(this.repository);

  Future<bool> call(String email, String tempPassword) async {
    return repository.resetPassword(email, tempPassword);
  }
}

class SignOutUseCase {
  final AuthRepository repository;
  SignOutUseCase(this.repository);

  Future<void> call() async {
    return repository.signOut();
  }
}
