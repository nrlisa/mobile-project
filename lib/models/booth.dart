class Booth {
  final String id;
  final double price;
  final String status; // 'available', 'booked', 'reserved'

  // Use a semicolon ; at the end, not {}
  Booth({
    required this.id,
    required this.price,
    required this.status,
  });

  get label => null;
}