class Booth {
  String id;
  String label;
  double x;
  double y;
  double width;
  double height;
  String type; 

  Booth({
    required this.id, required this.label, required this.x, required this.y,
    required this.width, required this.height, this.type = 'Medium',
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'label': label, 'x': x, 'y': y,
    'width': width, 'height': height, 'type': type,
  };

  factory Booth.fromJson(Map<String, dynamic> json) {
    return Booth(
      id: json['id'], label: json['label'], x: json['x'], y: json['y'],
      width: json['width'], height: json['height'], type: json['type'] ?? 'Medium',
    );
  }
}// TODO Implement this library.