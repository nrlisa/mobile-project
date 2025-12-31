class Booth {
  final String id;
  final String boothNumber; // e.g. "A-1"
  final String size;        // "Small", "Medium", "Large"
  final double price;
  final String status;      // 'available', 'booked', 'reserved'

  Booth({
    required this.id,
    required this.boothNumber,
    required this.size,
    required this.price,
    required this.status,
  });

  // Factory to create a Booth from Firestore data
  factory Booth.fromMap(Map<String, dynamic> data, String documentId) {
    return Booth(
      id: documentId,
      boothNumber: data['boothNumber'] ?? 'Unknown',
      size: data['size'] ?? 'Small',
     price: (data['price'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'available',
    );
  }

  // Convert Booth to Map for uploading
  Map<String, dynamic> toMap() {
    return {
      'boothNumber': boothNumber,
      'size': size,
      'price': price,
      'status': status,
    };
  }
}