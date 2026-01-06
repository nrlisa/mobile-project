// lib/services/api_service.dart
import 'package:flutter/foundation.dart';
import '../models/booth.dart';
import 'db_service.dart';

class ApiService {
  final DbService _dbService = DbService();

  Future<List<Booth>> getBooths(String eventId) async {
    try {
      final List<Booth> booths = await _dbService.getBoothsStream(eventId).first;

      if (booths.isEmpty) {
        throw Exception("No booths found in database for event ID: $eventId");
      }

      return booths;
    } catch (e) {
      debugPrint("❌ ApiService Error: $e");
      rethrow; 
    }
  }
}