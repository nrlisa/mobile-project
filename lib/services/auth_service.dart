import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class AuthService {
  final dbHelper = DatabaseHelper.instance;

  // We use SharedPreferences to remember who is logged in
  Future<void> _saveSession(int userId, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
    await prefs.setString('role', role);
  }

  // 1. REGISTER
  Future<String?> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final db = await dbHelper.database;
    try {
      await db.insert('users', {
        'email': email,
        'password': password,
        'name': name,
        'role': role,
      });
      return null; // Success
    } catch (e) {
      return "Email already exists or invalid data.";
    }
  }

  // 2. LOGIN
  Future<String?> login(String email, String password) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      final user = result.first;
      await _saveSession(user['id'] as int, user['role'] as String);
      return null; // Success
    } else {
      return "Invalid email or password";
    }
  }

  // 3. GET CURRENT USER ROLE
  Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role') ?? 'guest';
  }
  
  // 4. GET CURRENT USER ID
  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  // 5. LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}