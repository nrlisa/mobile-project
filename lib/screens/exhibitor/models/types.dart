// lib/models/types.dart

class Event {
  final String id;
  final String name;
  final String location;
  final String date;

  Event({
    required this.id, 
    required this.name, 
    required this.location, 
    required this.date
  });
}

// ADD THIS CLASS: This allows your app to recognize 'reserved' status
class Booth {
  final String id;
  final String hall;
  final String type;
  final String status; // 'available', 'booked', or 'reserved'
  final double price;
  final String dimensions;
  final List<String> features;

  Booth({
    required this.id,
    required this.hall,
    required this.type,
    required this.status,
    required this.price,
    this.dimensions = "3m x 3m",
    this.features = const ["Standard Power Socket", "1 Table, 2 Chairs"],
  });
}

class ApplicationRecord {
  final String id;
  final String eventName;
  final String boothType;
  final String submissionDate;
  final String status;

  ApplicationRecord({
    required this.id,
    required this.eventName,
    required this.boothType,
    required this.submissionDate,
    required this.status,
  });
}