import 'package:flutter/foundation.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class DbService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- GLOBAL STATIC VARIABLE ---
  // Stays in memory to track the most recently created event ID
  static String? currentEventId;

  // --- 1. ADD/UPDATE EXHIBITION ---
  // Standardized to link events directly via the organizer's UID string
  Future<void> addEvent(EventModel event) async {
    try {
      // Standardized: We use the UID string passed in organizerId directly [Inference]
      // This ensures the "vILKJ3YVHFUfGrnpJ6NDiH1G4VY2" ID is used consistently [Inference]
      final updatedEvent = EventModel(
        id: event.id,
        name: event.name,
        location: event.location,
        date: event.date,
        description: event.description,
        isPublished: event.isPublished,
        organizerId: event.organizerId, 
      );

      // Store the event ID in global memory for immediate use in booth creation
      currentEventId = updatedEvent.id;
      
      await _firestore.collection('events').doc(updatedEvent.id).set(updatedEvent.toJson());
      debugPrint("✅ Event Saved for Organizer UID: ${updatedEvent.organizerId}");
    } catch (e) {
      debugPrint("❌ Error adding event: $e");
      rethrow;
    }
  }

  // --- 2. SAVE BOOTH TYPES ---
  Future<void> addBoothType(String? eventId, Map<String, dynamic> boothData) async {
    final String idToUse = (eventId == null || eventId.isEmpty) 
        ? (currentEventId ?? "") 
        : eventId;

    if (idToUse.isEmpty) {
      debugPrint("⚠️ addBoothType failed: No ID found in pass or memory");
      return;
    }
    
    try {
      // Adds booth types to a sub-collection under the specific event
      await _firestore
          .collection('events')
          .doc(idToUse)
          .collection('booth_types')
          .add(boothData);
      debugPrint("✅ Booth added to event: $idToUse");
    } catch (e) {
      rethrow;
    }
  }

  // --- 3. READ BOOTHS ---
  Stream<QuerySnapshot> getBoothsForEvent(String? eventId) {
    final String idToUse = (eventId == null || eventId.isEmpty) 
        ? (currentEventId ?? "") 
        : eventId;

    if (idToUse.isEmpty) {
      debugPrint("⚠️ getBoothsForEvent: No ID found.");
      return const Stream.empty(); 
    }

    return _firestore
        .collection('events')
        .doc(idToUse)
        .collection('booth_types')
        .snapshots();
  }

  // --- 4. GUEST & EXHIBITOR PUBLIC VIEW ---
  // Only shows events where the Organizer has toggled the "Publish" slider to ON
  Stream<List<EventModel>> getGuestEvents() {
    return _firestore
        .collection('events')
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => EventModel.fromJson(doc.data())).toList();
    });
  }

  // --- 5. GET ORGANIZER DASHBOARD EVENTS ---
  // Standardized: Queries Firestore using the UID string [Inference]
  Stream<List<EventModel>> getOrganizerEvents(String organizerId) {
    return _firestore
        .collection('events')
        .where('organizerId', isEqualTo: organizerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => EventModel.fromJson(doc.data())).toList();
    });
  }

  // Function to delete an exhibition
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      if (currentEventId == eventId) currentEventId = null;
    } catch (e) {
      rethrow;
    }
  }

  // --- 6. FLOORPLAN & LAYOUT METHODS ---
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

  // --- 7. CREATE EVENT (MANUAL ENTRY) ---
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
      rethrow;
    }
  }

  Future<void> generateBooths(String eventId, int count) async {}

  Future<List<Map<String, dynamic>>> getEvents() async {
    try {
      final snapshot = await _firestore.collection('events').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint("❌ Error getting events: $e");
      return [];
    }
  }
}