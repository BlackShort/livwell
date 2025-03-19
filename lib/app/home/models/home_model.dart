import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteerOpportunity {
  final String id;
  final String title;
  final String organization;
  final String location;
  final DateTime date;
  final String time;
  final int shifts;
  final int spotsLeft;
  final String imageUrl;
  final bool isFavorite;
  final String orgIconType; // For displaying the correct icon

  VolunteerOpportunity({
    required this.id,
    required this.title,
    required this.organization,
    required this.location,
    required this.date,
    required this.time,
    required this.shifts,
    required this.spotsLeft,
    required this.imageUrl,
    this.isFavorite = false,
    this.orgIconType = 'eco',
  });

  factory VolunteerOpportunity.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return VolunteerOpportunity(
      id: doc.id,
      title: data['title'] ?? '',
      organization: data['organization'] ?? '',
      location: data['location'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] ?? '',
      shifts: data['shifts'] ?? 0,
      spotsLeft: data['spotsLeft'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      isFavorite: data['isFavorite'] ?? false,
      orgIconType: data['orgIconType'] ?? 'eco',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'organization': organization,
      'location': location,
      'date': Timestamp.fromDate(date),
      'time': time,
      'shifts': shifts,
      'spotsLeft': spotsLeft,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
      'orgIconType': orgIconType,
    };
  }
}

