class EventModel {
  String id;
  String name;
  String date;
  String location;
  String description;
  bool isPublished; // Status: Published or Draft
  String organizerId; // To know WHO created it

  EventModel({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.isPublished,
    required this.organizerId,
  });

  // Convert to Map for Database
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'date': date,
    'location': location,
    'description': description,
    'isPublished': isPublished,
    'organizerId': organizerId,
  };

  // Create Object from Database Data
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      date: json['date'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      isPublished: json['isPublished'] ?? false,
      organizerId: json['organizerId'] ?? '',
    );
  }
}