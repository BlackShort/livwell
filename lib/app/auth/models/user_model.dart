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

  // Create from Firebase document with improved timestamp handling
  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Handle timestamp conversion safely
    DateTime parseTimestamp(dynamic value) {
      if (value == null) {
        return DateTime.now();
      } else if (value is Timestamp) {
        return value.toDate();
      } else if (value is DateTime) {
        return value;
      } else if (value is String) {
        // Try to parse string as ISO 8601 date
        try {
          return DateTime.parse(value);
        } catch (_) {
          return DateTime.now();
        }
      } else if (value is int) {
        // Assume milliseconds since epoch
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else if (value is Map) {
        // Handle potential serialized timestamp objects
        if (value.containsKey('seconds') && value.containsKey('nanoseconds')) {
          return Timestamp(
            value['seconds'] as int, 
            value['nanoseconds'] as int
          ).toDate();
        }
      }
      return DateTime.now();
    }

    // Parse lists safely
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((item) => item?.toString() ?? '').toList();
      }
      return [];
    }

    return UserModel(
      uid: map['uid']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      firstName: map['firstName']?.toString() ?? '',
      lastName: map['lastName']?.toString() ?? '',
      phone: map['phone']?.toString(),
      photoUrl: map['photoUrl']?.toString(),
      createdAt: parseTimestamp(map['createdAt']),
      interests: parseStringList(map['interests']),
      eventsAttended: parseStringList(map['eventsAttended']),
      nonprofitsFollowed: parseStringList(map['nonprofitsFollowed']),
      isProfileComplete: map['isProfileComplete'] == true,
    );
  }

  // Convert to map for Firebase with safe timestamp conversion
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'photoUrl': photoUrl,
      'phone': phone,
      // Fix nullable check
      'createdAt': createdAt,
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

  // Add equality operator for comparing objects
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          uid == other.uid &&
          email == other.email;
  
  @override
  int get hashCode => uid.hashCode ^ email.hashCode;
}