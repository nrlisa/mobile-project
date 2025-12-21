// lib/models/types.dart

class Event {
  final String id;
  final String name;
  final String date;
  final String location;
  final String icon;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    this.icon = 'event',
  });
}

class Booth {
  final String id;
  final String hall;
  final String type;
  String status;
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