import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  get currentUser => null;

  // 1. REGISTER (Auth + Firestore for Role)
  Future<String?> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      // Create User in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save User Data & Role to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unknown error occurred.";
    }
  }

  // 2. LOGIN
  Future<String?> login(String email, String password) async {
    try {
      // Sign in with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch Role from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        String role = userDoc.get('role');
        await _saveSession(userCredential.user!.uid, role);
        return null; // Success
      } else {
        return "User data not found.";
      }
    } on FirebaseAuthException catch (e) {
      return e.message; 
    } catch (e) {
      return "An error occurred during login.";
    }
  }

  // Helper: Save Session locally for quick access
  Future<void> _saveSession(String userId, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('role', role);
  }

  // 3. GET CURRENT USER ROLE
  Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    // Ideally, double-check with Firestore if sensitive, but Prefs is okay for UI routing
    return prefs.getString('role') ?? 'guest';
  }

  // 4. GET CURRENT USER ID
  Future<String?> getCurrentUserId() async {
    return _auth.currentUser?.uid;
  }

  // 5. LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}