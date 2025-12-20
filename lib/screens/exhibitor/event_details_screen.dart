import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class DbService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ====================================================
  // 1. ORGANIZER: EVENTS & BOOTHS SETUP
  // ====================================================

  // Create a new Event
  Future<String> createEvent({
    required String name,
    required String location,
    required DateTime startDate,
    required DateTime endDate,
    required String floorPlanUrl,
  }) async {
    DocumentReference docRef = await _db.collection('events').add({
      'name': name,
      'location': location,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'floorPlanUrl': floorPlanUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // (Optional) Generate text-based booths if not using the visual mapper
  Future<void> generateBooths(String eventId, int count) async {
    final batch = _db.batch();
    for (int i = 1; i <= count; i++) {
      DocumentReference boothRef = _db
          .collection('events')
          .doc(eventId)
          .collection('booths')
          .doc(); 

      batch.set(boothRef, {
        'boothNumber': 'B$i',
        'price': 100, 
        'status': 'available', 
        'exhibitorId': null,
      });
    }
    await batch.commit();
  }

  // ====================================================
  // 2. ADMIN: FLOOR PLAN (VISUAL LAYOUT)
  // ====================================================

  // Save the visual layout (JSON) to the specific event document
  Future<void> saveFloorplanLayout(String eventId, List<Map<String, dynamic>> layoutData) async {
    await _db.collection('events').doc(eventId).update({
      'layoutJson': jsonEncode(layoutData),
    });
  }

  // Load the visual layout
  Future<List<dynamic>> getFloorplanLayout(String eventId) async {
    DocumentSnapshot doc = await _db.collection('events').doc(eventId).get();
    
    if (doc.exists && doc.data() != null) {
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('layoutJson')) {
        return jsonDecode(data['layoutJson']);
      }
    }
    return []; // Return empty if no layout exists
  }

  // ====================================================
  // 3. SHARED: GET DATA
  // ====================================================

  // Get All Events
  Future<List<Map<String, dynamic>>> getEvents() async {
    QuerySnapshot snapshot = await _db.collection('events').orderBy('createdAt', descending: true).get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }

  // RE-ADDED: Get Booths (List Version) - Required by Exhibitor Screens
  Future<List<Map<String, dynamic>>> getBooths(String eventId) async {
    // 1. First try to get 'logical' booths collection if it exists
    QuerySnapshot snapshot = await _db
        .collection('events')
        .doc(eventId)
        .collection('booths')
        .orderBy('boothNumber') 
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList();
    } 
    
    // 2. If no collection, maybe fallback to parsing the visual layout (optional)
    // For now, return empty to prevent crashes
    return [];
  }

  // ====================================================
  // 4. EXHIBITOR: BOOKING & APPLICATIONS
  // ====================================================

  // RE-ADDED: Simple Book Booth (Updates status directly)
  Future<void> bookBooth(String eventId, String boothId, String userId) async {
    await _db
        .collection('events')
        .doc(eventId)
        .collection('booths')
        .doc(boothId)
        .update({
      'status': 'booked',
      'exhibitorId': userId,
    });
  }

  // NEW: Submit Application (Pending Approval) - Better for Project Requirements
  Future<void> submitApplication({
    required String eventId,
    required String boothId,
    required String exhibitorId,
    required Map<String, dynamic> formData,
  }) async {
    await _db.collection('applications').add({
      'eventId': eventId,
      'boothId': boothId,
      'exhibitorId': exhibitorId,
      'status': 'pending', 
      'submittedAt': FieldValue.serverTimestamp(),
      'companyName': formData['companyName'] ?? '',
      'description': formData['description'] ?? '',
    });
  }
}