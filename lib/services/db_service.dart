import 'dart:convert';
import 'package:flutter/foundation.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

      // Save to global configuration so it applies to ALL events
      await _firestore.collection('settings').doc('global_config').set({
        'sharedLayout': [
          {'imageUrl': 'data:image/png;base64,$base64Image'}
        ],
      }, SetOptions(merge: true));
      debugPrint("✅ Base64 Image saved to Global Config");
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
    required String floorPlanUrl,
    required String organizerId,
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
        'organizerId': organizerId,
        'createdAt': FieldValue.serverTimestamp(),
        'isPublished': false,
      });
      return docRef.id; 
    } catch (e) {
      debugPrint("❌ Create Event Error: $e");
      throw Exception("Could not create event: $e");
    }
  }

  // UPDATED: Appends booths instead of overwriting.
  // Checks for existing booths of the same size to continue numbering correctly.
  Future<void> createBoothsBatch(String eventId, String size, double price, int count) async {
    try {
      // 0. Fetch Event to get Organizer ID
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      final String? organizerId = eventDoc.data()?['organizerId'];

      final collectionRef = _firestore.collection('events').doc(eventId).collection('booths');

      // 1. DETERMINE STARTING NUMBER
      // We query how many booths of this specific 'size' already exist.
      // This prevents duplicates if you add more booths later.
      final existingBoothsSnapshot = await collectionRef
          .where('size', isEqualTo: size)
          .get();
      
      int startNumber = existingBoothsSnapshot.docs.length + 1;

      // 2. CREATE NEW BOOTHS (Batch Write)
      final createBatch = _firestore.batch();
      
      // Determine prefix: S=Small, M=Medium, L=Large
      String prefix = size.isNotEmpty ? size.substring(0, 1).toUpperCase() : "B";
      
      for (int i = 0; i < count; i++) {
        int currentNumber = startNumber + i;
        final docRef = collectionRef.doc();
        
        createBatch.set(docRef, {
          'boothNumber': '$prefix-$currentNumber', // e.g., S-1... or S-11 if appending
          'size': size,
          'price': price, 
          'status': 'available',
          'organizerId': organizerId, // Save for Dashboard filtering
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      await createBatch.commit();
      debugPrint("✅ Added $count $size booths starting from $prefix-$startNumber for event $eventId");
      
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

  // Added: Support querying by multiple IDs (e.g. UID and ORG-ID) to ensure all events are found
  Stream<List<EventModel>> getOrganizerEventsMultiple(List<String> organizerIds) {
    if (organizerIds.isEmpty) return const Stream.empty();
    return _firestore.collection('events').where('organizerId', whereIn: organizerIds).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => EventModel.fromJson(doc.data())).toList();
    });
  }

  // Added: Get ALL events (ignoring organizerId) for debugging or Admin use
  Stream<List<EventModel>> getAllEventsStream() {
    return _firestore.collection('events').snapshots().map((snapshot) {
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

  // Fetch single booth details
  Future<Booth> getBooth(String eventId, String boothId) async {
    try {
      final doc = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('booths')
          .doc(boothId)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return Booth.fromMap(doc.data()!, doc.id);
      } else {
        throw Exception("Booth not found");
      }
    } catch (e) {
      rethrow;
    }
  }

  // Fetch single event raw data
  Future<Map<String, dynamic>> getEventData(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!;
      } else {
        throw Exception("Event not found");
      }
    } catch (e) {
      rethrow;
    }
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

  Future<String> submitApplication({
    required String userId,
    required String eventName,
    required String eventId, // Added: needed to find the booth
    required String boothId,
    required String boothNumber, // Added: Human readable booth number (e.g., S-1)
    required String eventDate,   // Added: Event date range
    required Map<String, dynamic> applicationData,
    required double totalAmount,
  }) async {
    try {
      // Fetch Event to get Organizer ID for the application
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      final String? organizerId = eventDoc.data()?['organizerId'];

      // 1. Create the Application Record
      DocumentReference docRef = await _firestore.collection('applications').add({
        'userId': userId,
        'eventName': eventName,
        'eventId': eventId,
        'boothId': boothId,
        'boothNumber': boothNumber,
        'organizerId': organizerId, // Save for Dashboard filtering
        'eventDate': eventDate,
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
      return docRef.id;
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

  Stream<QuerySnapshot> getAllApplications() {
    return _firestore.collection('applications').orderBy('submissionDate', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getOrganizerApplications() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return _firestore.collection('applications').where('organizerId', isEqualTo: uid).snapshots();
  }

  Stream<QuerySnapshot> getOrganizerBoothsGroup() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return _firestore.collectionGroup('booths').where('organizerId', isEqualTo: uid).snapshots();
  }

  Stream<QuerySnapshot> getAllBoothsGroup() {
    return _firestore.collectionGroup('booths').snapshots();
  }

  Future<void> markApplicationAsPaid(String docId) async {
    try {
      await _firestore.collection('applications').doc(docId).update({
        'paymentStatus': 'Paid',
        // 'status': 'Paid' // Removed: Status remains 'Pending' after payment
      });
      debugPrint("✅ Application $docId marked as Paid");
    } catch (e) {
      rethrow;
    }
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
      // 1. Get the application to find which booth to free up
      final doc = await _firestore.collection('applications').doc(docId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final eventId = data['eventId'];
        final boothId = data['boothId'];

        // 2. Reset Booth Status to 'available'
        if (eventId != null && boothId != null) {
          await updateBoothStatus(eventId, boothId, 'available');
        }
      }

      await _firestore.collection('applications').doc(docId).delete();
      debugPrint("✅ Application $docId cancelled/deleted");
    } catch (e) {
      debugPrint("❌ Cancel Application Error: $e");
      rethrow;
    }
  }

  Future<void> generateBooths(String eventId, int count) async {
    await createBoothsBatch(eventId, 'Standard', 100.0, count);
  }
}