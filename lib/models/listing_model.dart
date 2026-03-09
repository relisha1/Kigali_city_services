import 'package:cloud_firestore/cloud_firestore.dart';

class ListingModel {
  final String id;
  final String name;
  final String category;
  final String address;
  final String contactNumber;
  final String description;
  final double latitude;
  final double longitude;
  final String createdBy;
  final DateTime createdAt;
  final double rating;
  final int reviewCount;

  ListingModel({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contactNumber,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.createdAt,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  // Convert from Firestore document
  factory ListingModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ListingModel(
      id:            doc.id,
      name:          data['name']          ?? '',
      category:      data['category']      ?? '',
      address:       data['address']       ?? '',
      contactNumber: data['contactNumber'] ?? '',
      description:   data['description']  ?? '',
      latitude:      (data['latitude']    ?? 0.0).toDouble(),
      longitude:     (data['longitude']   ?? 0.0).toDouble(),
      createdBy:     data['createdBy']    ?? '',
      createdAt:     (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rating:        (data['rating']      ?? 0.0).toDouble(),
      reviewCount:   (data['reviewCount'] ?? 0).toInt(),
    );
  }

  // Convert to map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name':          name,
      'category':      category,
      'address':       address,
      'contactNumber': contactNumber,
      'description':   description,
      'latitude':      latitude,
      'longitude':     longitude,
      'createdBy':     createdBy,
      'createdAt':     FieldValue.serverTimestamp(),
      'rating':        rating,
      'reviewCount':   reviewCount,
    };
  }

  // For updating
  Map<String, dynamic> toUpdateMap() {
    return {
      'name':          name,
      'category':      category,
      'address':       address,
      'contactNumber': contactNumber,
      'description':   description,
      'latitude':      latitude,
      'longitude':     longitude,
    };
  }

  // Distance display helper
  String distanceText(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }
}
