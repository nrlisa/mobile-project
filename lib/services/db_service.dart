import 'dart:convert';
import 'package:flutter/foundation.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/event_model.dart';
import '../models/booth.dart'; 

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

  Stream<QuerySnapshot> getAllUsers() {
    return _firestore.collection('users').snapshots();
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(userId).update(userData);
    } catch (e) {
      rethrow;
    }
  }

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

  // UPDATED: This creates exactly what the Organizer inputs (Size, Price, Qty)
  // It also clears old booths for this event to keep data clean.
  Future<void> createBoothsBatch(String eventId, String size, double price, int count) async {
    try {
      final collectionRef = _firestore.collection('events').doc(eventId).collection('booths');

      // 1. DELETE EXISTING BOOTHS (Ensures clean slate)
      final existingBooths = await collectionRef.get();
      final deleteBatch = _firestore.batch();
      for (var doc in existingBooths.docs) {
        deleteBatch.delete(doc.reference);
      }
      await deleteBatch.commit(); 

      // 2. CREATE NEW BOOTHS
      final createBatch = _firestore.batch();
      
      // Determine prefix: S=Small, M=Medium, L=Large
      String prefix = size.isNotEmpty ? size.substring(0, 1).toUpperCase() : "B";
      
      for (int i = 1; i <= count; i++) {
        final docRef = collectionRef.doc();
        createBatch.set(docRef, {
          'boothNumber': '$prefix-$i', // e.g., S-1, S-2
          'size': size,
          'price': price, // Uses the EXACT price from input
          'status': 'available',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await createBatch.commit();
      debugPrint("✅ Generated $count $size booths at RM $price for event $eventId");
    } catch (e) {
      debugPrint("❌ Error generating booths: $e");
      rethrow;
    }
  }

  // --- 5. DATA RETRIEVAL ---

  Future<List<Map<String, dynamic>>> getEvents() async {
    try {
      final snapshot = await _firestore.collection('events').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; 
        return data;
      }).toList();
    } catch (e) {
      debugPrint("❌ Error fetching events: $e");
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

  // Stream specifically for Booth Objects (Organizer & Exhibitor UI)
  Stream<List<Booth>> getBoothsStream(String eventId) {
    if (eventId.isEmpty) return const Stream.empty();
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('booths')
        .orderBy('createdAt') 
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Booth.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Toggle Booth Status (Organizer Management)
  Future<void> updateBoothStatus(String eventId, String boothId, String newStatus) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('booths')
          .doc(boothId)
          .update({'status': newStatus});
    } catch (e) {
      rethrow;
    }
  }

  // --- 6. APPLICATION MANAGEMENT ---

  Future<void> submitApplication({
    required String userId,
    required String eventName,
    required String eventId, // Added: needed to find the booth
    required String boothId,
    required Map<String, dynamic> applicationData,
    required double totalAmount,
  }) async {
    try {
      // 1. Create the Application Record
      await _firestore.collection('applications').add({
        'userId': userId,
        'eventName': eventName,
        'eventId': eventId,
        'boothId': boothId,
        'companyName': applicationData['details']?['companyName'] ?? 'N/A',
        'companyDescription': applicationData['details']?['description'] ?? 'N/A',
        'exhibitProfile': applicationData['details']?['exhibitProfile'] ?? 'N/A',
        'addons': applicationData['addons'] ?? [],
        'totalAmount': totalAmount,
        'status': 'Pending', 
        'submissionDate': FieldValue.serverTimestamp(),
      });

      // 2. Mark the Booth as 'booked' so no one else can take it
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('booths')
          .doc(boothId)
          .update({'status': 'booked'});

      debugPrint("✅ Application stored & Booth marked as Booked");
    } catch (e) {
      debugPrint("❌ Firestore Application Error: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getExhibitorApplications(String userId) {
    return _firestore
        .collection('applications')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Future<void> updateApplication(String docId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('applications').doc(docId).update(updatedData);
      debugPrint("✅ Application $docId updated");
    } catch (e) {
      debugPrint("❌ Update Application Error: $e");
      rethrow;
    }
  }

  Future<void> cancelApplication(String docId) async {
    try {
      await _firestore.collection('applications').doc(docId).delete();
      debugPrint("✅ Application $docId cancelled/deleted");
    } catch (e) {
      debugPrint("❌ Cancel Application Error: $e");
      rethrow;
    }
  }

  Future<void> generateBooths(String eventId, int count) async {}
}