import 'package:cloud_firestore/cloud_firestore.dart';

class DbService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- ORGANIZER METHODS ---

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
        'price': 100, // stored as int or double
        'status': 'available', 
        'exhibitorId': null,
      });
    }
    await batch.commit();
  }

  // --- EXHIBITOR / GUEST METHODS ---

  // 1. Get All Events
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

  // 2. Get Booths for a specific Event
  Future<List<Map<String, dynamic>>> getBooths(String eventId) async {
    QuerySnapshot snapshot = await _db
        .collection('events')
        .doc(eventId)
        .collection('booths')
        .orderBy('boothNumber') // Sort by B1, B2...
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }

  // 3. Book a Booth
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
}