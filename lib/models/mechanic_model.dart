class MechanicModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final double rating;
  final List<String> specialties;
  final bool available;
  final double latitude;
  final double longitude;

  MechanicModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.rating,
    required this.specialties,
    required this.available,
    required this.latitude,
    required this.longitude,
  });

  factory MechanicModel.fromJson(Map<String, dynamic> json) {
    return MechanicModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      specialties: List<String>.from(json['specialties'] ?? []),
      available: json['available'] ?? false,
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}