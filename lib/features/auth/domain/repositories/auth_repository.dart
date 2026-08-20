abstract class AuthRepository {
  Future<bool> register(String email, String password);
  Future<bool> login(String email, String password);
  Future<bool> resetPassword(String email, String tempPassword);
  Future<void> signOut();
}
