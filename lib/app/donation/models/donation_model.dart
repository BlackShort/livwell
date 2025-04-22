import 'package:cloud_firestore/cloud_firestore.dart';

// Model for NGO data
class NGOModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final double rating;
  final int donorsCount;
  final double donationAmount;
  final List<String> causes;

  NGOModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.donorsCount,
    required this.donationAmount,
    required this.causes,
  });

  factory NGOModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NGOModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      donorsCount: data['donorsCount'] ?? 0,
      donationAmount: (data['donationAmount'] ?? 0.0).toDouble(),
      causes: List<String>.from(data['causes'] ?? []),
    );
  }
}
