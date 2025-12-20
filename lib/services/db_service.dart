import 'dart:convert';
import 'package:flutter/foundation.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/event_model.dart';

class DbService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- GLOBAL STATIC VARIABLE ---
  static String? currentEventId;

  // --- 1. EXHIBITION MANAGEMENT (ADMIN & ORGANIZER) ---

  Future<void> addEvent(EventModel event) async {
    try {
      currentEventId = event.id;
      await _firestore.collection('events').doc(event.id).set(event.toJson());
      debugPrint("✅ Event Saved: ${event.name}");
    } catch (e) {
      rethrow;
    }
  }

  // FIXED: Method to update exhibition details
  Future<void> updateEvent(String eventId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('events').doc(eventId).update(updatedData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      if (currentEventId == eventId) currentEventId = null;
    } catch (e) {
      rethrow;
    }
  }

  // --- 2. USER MANAGEMENT (ADMIN ROLE) ---

  // Fetches all users for the Admin Dashboard [Inference]
  Stream<QuerySnapshot> getAllUsers() {
    return _firestore.collection('users').snapshots();
  }

  // Updates user roles or information [Inference]
  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(userId).update(userData);
    } catch (e) {
      rethrow;
    }
  }

  // Deletes a user from Firestore [Inference]
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // --- 3. GLOBAL FLOORPLAN (BASE64 METHOD) ---

  Future<void> saveFloorplanLayout(String eventId, XFile imageFile) async {
    try {
      Uint8List imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      await _firestore.collection('settings').doc('global_config').set({
        'sharedLayout': [
          {'imageUrl': 'data:image/png;base64,$base64Image'}
        ], 
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint("✅ Base64 Image saved to Firestore");
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getFloorplanLayout(String eventId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('settings').doc('global_config').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['sharedLayout'] as List<dynamic>? ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- 4. EVENT CREATION & BOOTH GENERATION ---

  // FIXED: Now ensures a String is always returned or an error is thrown
  Future<String> createEvent({
    required String name, 
    required String location, 
    required DateTime startDate, 
    required DateTime endDate, 
    required String floorPlanUrl
  }) async {
    try {
      final docRef = _firestore.collection('events').doc();
      currentEventId = docRef.id;
      
      await docRef.set({
        'id': docRef.id,
        'name': name,
        'location': location,
        'startDate': startDate,
        'endDate': endDate,
        'floorPlanUrl': floorPlanUrl, 
        'createdAt': FieldValue.serverTimestamp(),
        'isPublished': false,
      });
      return docRef.id; 
    } catch (e) {
      debugPrint("❌ Create Event Error: $e");
      throw Exception("Could not create event: $e");
    }
  }

  // FIXED: Implemented the missing generateBooths method
  Future<void> generateBooths(String eventId, int count) async {
    try {
      final batch = _firestore.batch();
      for (int i = 1; i <= count; i++) {
        final boothRef = _firestore
            .collection('events')
            .doc(eventId)
            .collection('booths')
            .doc();
            
        batch.set(boothRef, {
          'boothNumber': 'B$i',
          'status': 'available',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // --- 5. DATA RETRIEVAL ---

  Future<List<Map<String, dynamic>>> getEvents() async {
    try {
      final snapshot = await _firestore.collection('events').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }

  Stream<List<EventModel>> getGuestEvents() {
    return _firestore.collection('events').where('isPublished', isEqualTo: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => EventModel.fromJson(doc.data())).toList();
    });
  }

  Stream<List<EventModel>> getOrganizerEvents(String organizerId) {
    return _firestore.collection('events').where('organizerId', isEqualTo: organizerId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => EventModel.fromJson(doc.data())).toList();
    });
  }

  Future<void> addBoothType(String? eventId, Map<String, dynamic> boothData) async {
    final String idToUse = (eventId == null || eventId.isEmpty) ? (currentEventId ?? "") : eventId;
    if (idToUse.isEmpty) return;
    try {
      await _firestore.collection('events').doc(idToUse).collection('booth_types').add(boothData);
    } catch (e) { rethrow; }
  }

  Stream<QuerySnapshot> getBoothsForEvent(String? eventId) {
    final String idToUse = (eventId == null || eventId.isEmpty) ? (currentEventId ?? "") : eventId;
    if (idToUse.isEmpty) return const Stream.empty(); 
    return _firestore.collection('events').doc(idToUse).collection('booth_types').snapshots();
  }
}