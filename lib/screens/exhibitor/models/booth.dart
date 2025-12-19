class Booth {
  // 1. Properties
  String id;
  String label;
  double x;
  double y;
  double width;
  double height;
  String type; // 'Small', 'Medium', 'Large'

  // 2. Constructor
  Booth({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.type = 'Medium',
  });

  // 3. Convert to JSON (for saving)
  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'type': type,
  };

  // 4. Create from JSON (for loading)
  factory Booth.fromJson(Map<String, dynamic> json) {
    return Booth(
      id: json['id'],
      label: json['label'],
      x: json['x'],
      y: json['y'],
      width: json['width'],
      height: json['height'],
      type: json['type'] ?? 'Medium',
    );
  }
} // <--- This final bracket MUST be here at the very end