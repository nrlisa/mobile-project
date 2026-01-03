import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String id;
  String name;
  String date;
  String location;
  String description;
  bool isPublished;
  String organizerId;

  EventModel({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.isPublished,
    required this.organizerId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'date': date,
    'location': location,
    'description': description,
    'isPublished': isPublished,
    'organizerId': organizerId,
  };

  factory EventModel.fromJson(Map<String, dynamic> json) {
    String dateStr = json['date'] ?? '';

    // Fallback: If 'date' string is empty, try to construct it from startDate/endDate
    if (dateStr.isEmpty && json['startDate'] != null && json['endDate'] != null) {
      try {
        DateTime start = (json['startDate'] is Timestamp) 
            ? (json['startDate'] as Timestamp).toDate() 
            : DateTime.parse(json['startDate'].toString());
        DateTime end = (json['endDate'] is Timestamp) 
            ? (json['endDate'] as Timestamp).toDate() 
            : DateTime.parse(json['endDate'].toString());
        dateStr = "${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}";
      } catch (_) {}
    }

    return EventModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unnamed',
      date: dateStr,
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      isPublished: json['isPublished'] ?? false,
      organizerId: json['organizerId'] ?? '',
    );
  }
}