import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Returns the actual Firebase User instead of null
  User? get currentUser => _auth.currentUser;

  // 1. REGISTER (Generates Specific Role IDs)
  Future<String?> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      // Create User in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Generate SPECIFIC ID ROLE based on role selection
      String? organizerId;
      String? exhibitorId;
      String? adminId;

      String timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);

      if (role == 'organizer') {
        organizerId = "ORG-$timestamp";
      } else if (role == 'exhibitor') {
        exhibitorId = "EXH-$timestamp";
      } else if (role == 'admin') {
        adminId = "ADM-$timestamp";
      }

      // Save User Data & Role IDs to Firestore
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email.trim(),
        'name': name,
        'role': role,
        'organizerId': organizerId,
        'exhibitorId': exhibitorId,
        'adminId': adminId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint("✅ Registration Successful for UID: $uid as $role");
      return null; 
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ Registration Auth Error: ${e.message}");
      return e.message;
    } catch (e) {
      return "An unknown error occurred.";
    }
  }

  // 2. LOGIN (Includes Firestore Document Check)
  Future<String?> login(String email, String password) async {
    try {
      // Sign in with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Fetch Role and specific IDs from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        String role = data['role'] ?? 'guest';
        
        // Retrieve the specific ID to save in the session
        String specificId = "";
        if (role == 'organizer') specificId = data['organizerId'] ?? "";
        if (role == 'exhibitor') specificId = data['exhibitorId'] ?? "";
        if (role == 'admin') specificId = data['adminId'] ?? "";

        await _saveSession(userCredential.user!.uid, role, specificId);
        debugPrint("✅ Login Success: $email ($role)");
        return null; 
      } else {
        // If Auth succeeds but Firestore doc is missing
        debugPrint("❌ Login Error: Firestore document missing for UID ${userCredential.user!.uid}");
        return "User data not found in database. Please re-register.";
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ Login Auth Error: ${e.message}");
      return e.message; 
    } catch (e) {
      debugPrint("❌ Unexpected Login Error: $e");
      return "An error occurred during login.";
    }
  }

  // Helper: Save Session locally including the specific ID
  Future<void> _saveSession(String userId, String role, String specificId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('role', role);
    await prefs.setString('specificId', specificId);
  }

  // 3. GET CURRENT USER ROLE
  Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role') ?? 'guest';
  }

  // 4. GET CURRENT USER ID (Auth UID)
  Future<String?> getCurrentUserId() async {
    return _auth.currentUser?.uid;
  }

  // 5. LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint("✅ User Logged Out");
  }
}