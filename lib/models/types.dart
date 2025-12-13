// File: lib/models/types.dart

class Event {
  final String id;
  final String title;
  final String date;
  final String location;
  final String icon; // 'globe' or 'pen'

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.icon,
  });
}

class Booth {
  final String id;
  final String hall;
  final String type; // e.g., 'Small', 'Medium', 'Large'
  String status; // 'available', 'booked', 'reserved', 'selected'
  final double price;
  final String dimensions; // New field, e.g., "3m x 3m"
  final List<String> features; // New field, e.g., ["Power Socket", "WiFi"]

  Booth({
    required this.id,
    required this.hall,
    required this.type,
    required this.status,
    required this.price,
    this.dimensions = "3m x 3m", // Default value
    this.features = const ["Standard Power Socket", "1 Table, 2 Chairs", "Waste Basket"], // Default values
  });
}

class ApplicationFormData {
  String companyName;
  String companyDescription;
  String exhibitProfile;
  List<String> additionalItems;

  ApplicationFormData({
    this.companyName = '',
    this.companyDescription = '',
    this.exhibitProfile = '',
    List<String>? additionalItems,
  }) : additionalItems = additionalItems ?? [];
}

class ApplicationRecord {
  final String id;
  final String eventName;
  final String boothType;
  final String submissionDate;
  final String status; // 'Approved', 'Pending', 'Rejected'

  ApplicationRecord({
    required this.id,
    required this.eventName,
    required this.boothType,
    required this.submissionDate,
    required this.status,
  });
}