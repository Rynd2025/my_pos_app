import '../../domain/repositories/auth_repository.dart';
import '../services/local_auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalAuthService _localAuth = LocalAuthService.instance;

  AuthRepositoryImpl();

  @override
  Future<bool> login(String email, String password) async {
    return _localAuth.login(email, password);
  }

  @override
  Future<bool> register(String email, String password) async {
    return _localAuth.register(email, password);
  }

  @override
  Future<bool> resetPassword(String email, String tempPassword) async {
    return _localAuth.resetPassword(email, tempPassword);
  }

  @override
  Future<void> signOut() async {
    return _localAuth.signOut();
  }
}
