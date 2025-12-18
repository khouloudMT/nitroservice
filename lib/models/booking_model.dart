import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
}

class BookingModel {
  final String id;
  final String userId;
  final String serviceId;
  final String serviceName;
  final DateTime scheduledDate;
  final String address;
  final double latitude;
  final double longitude;
  final double totalPrice;
  final BookingStatus status;
  final String? notes;
  final String? mechanicId;
  final String? mechanicName;
  final String? mechanicPhone;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.scheduledDate,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.totalPrice,
    required this.status,
    this.notes,
    this.mechanicId,
    this.mechanicName,
    this.mechanicPhone,
    required this.createdAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      scheduledDate: (data['scheduledDate'] as Timestamp).toDate(),
      address: data['address'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      status: _parseStatus(data['status']),
      notes: data['notes'],
      mechanicId: data['mechanicId'],
      mechanicName: data['mechanicName'],
      mechanicPhone: data['mechanicPhone'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'totalPrice': totalPrice,
      'status': status.name,
      'notes': notes,
      'mechanicId': mechanicId,
      'mechanicName': mechanicName,
      'mechanicPhone': mechanicPhone,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static BookingStatus _parseStatus(String? status) {
    switch (status) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'inProgress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  String getStatusText() {
    switch (status) {
      case BookingStatus.pending:
        return 'En attente';
      case BookingStatus.confirmed:
        return 'Confirmé';
      case BookingStatus.inProgress:
        return 'En cours';
      case BookingStatus.completed:
        return 'Terminé';
      case BookingStatus.cancelled:
        return 'Annulé';
    }
  }
}