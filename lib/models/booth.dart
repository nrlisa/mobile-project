class Booth {
  final String id;
  final String boothNumber; // e.g. "A-1"
  final String size;        // "Small", "Medium", "Large"
  final double price;
  final String status;      // 'available', 'booked', 'reserved'
  final String? companyCategory;
  final String? companyName;
  final double? x;
  final double? y;
  final double? width;
  final double? height;

  Booth({
    required this.id,
    required this.boothNumber,
    required this.size,
    required this.price,
    required this.status,
    this.companyCategory,
    this.companyName,
    this.x,
    this.y,
    this.width,
    this.height,
  });

  // Factory to create a Booth from Firestore data
  factory Booth.fromMap(Map<String, dynamic> data, String documentId) {
    return Booth(
      id: documentId,
      boothNumber: data['boothNumber'] ?? 'Unknown',
      size: data['size'] ?? 'Small',
     price: (data['price'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'available',
      companyCategory: data['companyCategory'],
      companyName: data['companyName'],
      x: (data['x'] as num?)?.toDouble(),
      y: (data['y'] as num?)?.toDouble(),
      width: (data['width'] as num?)?.toDouble(),
      height: (data['height'] as num?)?.toDouble(),
    );
  }

  // Convert Booth to Map for uploading
  Map<String, dynamic> toMap() {
    return {
      'boothNumber': boothNumber,
      'size': size,
      'price': price,
      'status': status,
      'companyCategory': companyCategory,
      'companyName': companyName,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }
}