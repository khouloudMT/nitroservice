class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int duration; // en minutes
  final String imageUrl;
  final bool isPopular;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.duration,
    required this.imageUrl,
    this.isPopular = false,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'] ?? 60,
      imageUrl: json['imageUrl'] ?? '',
      isPopular: json['isPopular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'duration': duration,
      'imageUrl': imageUrl,
      'isPopular': isPopular,
    };
  }
}