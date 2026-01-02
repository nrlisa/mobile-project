// lib/services/api_service.dart
import 'package:flutter/foundation.dart';
import '../models/booth.dart';
import 'db_service.dart';

class ApiService {
  final DbService _dbService = DbService();

  /// Fetches real booth data from the database for a specific event.
  /// This removes the previous mock/placeholder logic.
  Future<List<Booth>> getBooths(String eventId) async {
    try {
      // Trace: Database → DbService → ApiService → Frontend
      // We take the first emission from the real Firestore stream
      final List<Booth> booths = await _dbService.getBoothsStream(eventId).first;

      // Constraint check: Do not provide fake UI if data is missing
      if (booths.isEmpty) {
        throw Exception("No booths found in database for event ID: $eventId");
      }

      return booths;
    } catch (e) {
      // Error handling: Provide the actual error message instead of a fake fallback
      debugPrint("❌ ApiService Error: $e");
      rethrow; 
    }
  }
}