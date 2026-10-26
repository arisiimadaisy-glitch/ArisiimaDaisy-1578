import '../models/user_model.dart';

class UserRepository {
  User? _currentUser;

  UserRepository() {
    _initializeSeedData();
  }

  void _initializeSeedData() {
    _currentUser = User(
      id: 'user_001',
      name: 'Sarah Nakato',
      email: 'sarah@example.com',
      currency: 'UGX',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    );
  }

  Future<User?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _currentUser;
  }

  Future<void> updateUser(User user) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _currentUser = user;
  }

  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_currentUser != null && _currentUser!.email == email) {
      return _currentUser!;
    }
    throw Exception('Invalid credentials');
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 50));
    // Keep the seed user but simulate logout
  }
}
