// auth/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? photoUrl;
  final DateTime createdAt;
  final List<String> interests;
  final List<String> eventsAttended;
  final List<String> nonprofitsFollowed;
  final bool isProfileComplete;

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    this.phone,
    required this.createdAt,
    this.interests = const [],
    this.eventsAttended = const [],
    this.nonprofitsFollowed = const [],
    this.isProfileComplete = false,
  });

  String get fullName => '$firstName $lastName';

  // Create from Firebase document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phone: map['phone'],
      photoUrl: map['photoUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      interests: List<String>.from(map['interests'] ?? []),
      eventsAttended: List<String>.from(map['eventsAttended'] ?? []),
      nonprofitsFollowed: List<String>.from(map['nonprofitsFollowed'] ?? []),
      isProfileComplete: map['isProfileComplete'] ?? false,
    );
  }

  // Convert to map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'photoUrl': photoUrl,
      'phone': phone,
      'createdAt': Timestamp.fromDate(createdAt),
      'interests': interests,
      'eventsAttended': eventsAttended,
      'nonprofitsFollowed': nonprofitsFollowed,
      'isProfileComplete': isProfileComplete,
    };
  }

  // Create copy with updated fields
  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? phone,
    List<String>? interests,
    List<String>? eventsAttended,
    List<String>? nonprofitsFollowed,
    bool? isProfileComplete,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      interests: interests ?? this.interests,
      eventsAttended: eventsAttended ?? this.eventsAttended,
      nonprofitsFollowed: nonprofitsFollowed ?? this.nonprofitsFollowed,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}