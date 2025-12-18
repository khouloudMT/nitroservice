import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profilePictureBase64;
  final bool isPremium;
  final DateTime? premiumEndDate;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profilePictureBase64,
    this.isPremium = false,
    this.premiumEndDate,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      profilePictureBase64: data['profilePictureBase64'],
      isPremium: data['isPremium'] ?? false,
      premiumEndDate: data['premiumEndDate'] != null
          ? (data['premiumEndDate'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profilePictureBase64': profilePictureBase64,
      'isPremium': isPremium,
      'premiumEndDate': premiumEndDate != null 
          ? Timestamp.fromDate(premiumEndDate!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? profilePictureBase64,
    bool? isPremium,
    DateTime? premiumEndDate,
  }) {
    return UserModel(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePictureBase64: profilePictureBase64 ?? this.profilePictureBase64,
      isPremium: isPremium ?? this.isPremium,
      premiumEndDate: premiumEndDate ?? this.premiumEndDate,
      createdAt: this.createdAt,
    );
  }

  bool get hasProfilePicture => 
      profilePictureBase64 != null && profilePictureBase64!.isNotEmpty;
}