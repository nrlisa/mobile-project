import 'package:flutter/foundation.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class DbService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- 1. ADD EXHIBITION (Organizer Page 7) ---
  Future<void> addEvent(EventModel event) async {
    try {
      await _firestore.collection('events').doc(event.id).set(event.toJson());
      debugPrint("✅ Event Added/Updated: ${event.name}");
    } catch (e) {
      debugPrint("❌ Error adding event: $e");
      rethrow;
    }
  }

  // --- 2. PHASE 3 - SAVE BOOTH TYPES (Organizer Page 8) ---
  Future<void> addBoothType(String eventId, Map<String, dynamic> boothData) async {
    // Safety check: Don't attempt to save if the eventId is empty
    if (eventId.isEmpty) return;
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('booth_types')
          .add(boothData);
      debugPrint("✅ Booth Type Added specifically to Event: $eventId");
    } catch (e) {
      debugPrint("❌ Error adding booth type: $e");
      rethrow;
    }
  }

  // --- 3. PHASE 4 - EXHIBITOR READS BOOTHS (Exhibitor Page 13) ---
  // FIXED: Returns an empty stream if eventId is empty to prevent red screen error
  Stream<QuerySnapshot> getBoothsForEvent(String eventId) {
    if (eventId.isEmpty) {
      return const Stream.empty();
    }
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('booth_types')
        .snapshots();
  }

  // --- 4. GUEST & EXHIBITOR SELECT EVENT (Page 1 & Page 12) ---
  // Fetches only exhibitions marked as "Published"
  Stream<List<EventModel>> getGuestEvents() {
    return _firestore
        .collection('events')
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return EventModel.fromJson(doc.data());
      }).toList();
    });
  }

  // --- 5. GET ORGANIZER EVENTS (Organizer Page 6) ---
  Stream<List<EventModel>> getOrganizerEvents(String organizerId) {
    return _firestore
        .collection('events')
        .where('organizerId', isEqualTo: organizerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return EventModel.fromJson(doc.data());
      }).toList();
    });
  }

  // Function to delete an exhibition
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      debugPrint("✅ Event $eventId deleted from Firebase");
    } catch (e) {
      debugPrint("❌ Error deleting event: $e");
      rethrow;
    }
  }

  // --- 6. FLOORPLAN & MISC METHODS ---
  Future<void> saveFloorplanLayout(String eventId, List<Map<String, dynamic>> layout) async {
    try {
      await _firestore.collection('events').doc(eventId).set({
        'layout': layout,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getFloorplanLayout(String eventId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['layout'] as List<dynamic>? ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    try {
      final snapshot = await _firestore.collection('events').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return []; 
    }
  }

  Future<void> generateBooths(String eventId, int count) async {
    debugPrint("Generating $count booths for $eventId");
  }

  // --- 7. CREATE EVENT (Alternate method) ---
  Future<String> createEvent({
    required String name, 
    required String location, 
    required DateTime startDate, 
    required DateTime endDate, 
    required String floorPlanUrl
  }) async {
    try {
      final docRef = _firestore.collection('events').doc();
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
      debugPrint("✅ Event Created: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      debugPrint("❌ Error creating event: $e");
      rethrow;
    }
  }
}