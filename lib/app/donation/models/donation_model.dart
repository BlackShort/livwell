import 'package:cloud_firestore/cloud_firestore.dart';

class NGOModel {
  final String ngoId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String imageUrl;
  final String category;
  final String registrationNumber;
  final List<String> registrationDocs;
  final List<String> fields;
  final String website;
  final String description;
  final bool isVerified;
  final double rating;
  final int donorsCount;
  final double donationAmount;
  final List<String> causes;
  final Timestamp createdAt;
  final String createdBy;

  NGOModel({
    required this.ngoId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.category,
    required this.imageUrl,
    required this.registrationNumber,
    required this.registrationDocs,
    required this.fields,
    required this.website,
    required this.description,
    required this.isVerified,
    required this.rating,
    required this.donorsCount,
    required this.donationAmount,
    required this.causes,
    required this.createdAt,
    required this.createdBy,
  });

  factory NGOModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return NGOModel(
      ngoId: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      registrationNumber: data['registrationNumber'] ?? '',
      registrationDocs: List<String>.from(data['registrationDocs'] ?? []),
      fields: List<String>.from(data['fields'] ?? []),
      website: data['website'] ?? '',
      description: data['description'] ?? '',
      isVerified: data['isVerified'] ?? false,
      rating: (data['rating'] ?? 0.0).toDouble(),
      donorsCount: data['donorsCount'] ?? 0,
      donationAmount: (data['donationAmount'] ?? 0.0).toDouble(),
      causes: List<String>.from(data['causes'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'category': category,
      'imageUrl': imageUrl,
      'registrationNumber': registrationNumber,
      'registrationDocs': registrationDocs,
      'fields': fields,
      'website': website,
      'description': description,
      'isVerified': isVerified,
      'rating': rating,
      'donorsCount': donorsCount,
      'donationAmount': donationAmount,
      'causes': causes,
      'createdAt': createdAt,
      'createdBy': createdBy,
    };
  }
}
