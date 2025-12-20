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
    return EventModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unnamed',
      date: json['date'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      isPublished: json['isPublished'] ?? false,
      organizerId: json['organizerId'] ?? '',
    );
  }
}