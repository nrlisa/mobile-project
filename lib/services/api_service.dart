// lib/services/api_service.dart
import '../models/types.dart'; // Use types.dart if that is where Booth is

class ApiService {
  // Placeholder function so the file isn't empty
  Future<List<Booth>> getBooths() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return []; // Return empty list for now
  }
}