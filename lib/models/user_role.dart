class UserModel {
  final String uid;
  final String email;
  final String role; // 'organizer', 'exhibitor', or 'admin'
  final String? organizerId;
  final String? exhibitorId;
  final String? adminId;

  // Corrected Constructor
  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.organizerId,
    this.exhibitorId,
    this.adminId,
  });

  // Convert Firestore Document (Map) to Model
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'exhibitor',
      organizerId: json['organizerId'],
      exhibitorId: json['exhibitorId'],
      adminId: json['adminId'],
    );
  }

  // Convert Model to Firestore Document (Map)
  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'role': role,
    'organizerId': organizerId,
    'exhibitorId': exhibitorId,
    'adminId': adminId,
  };
}