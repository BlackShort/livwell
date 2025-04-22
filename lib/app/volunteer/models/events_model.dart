import 'package:cloud_firestore/cloud_firestore.dart';

// Event Model
class EventModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final String location;
  final DateTime date;
  final DateTime time;
  final int duration; // in hours
  final int spots;
  final int registeredCount;
  final String organizerId;
  final String organizerName;
  final List<String> skills;
  final bool isVirtual;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.location,
    required this.date,
    required this.time,
    required this.duration,
    required this.spots,
    required this.registeredCount,
    required this.organizerId,
    required this.organizerName,
    required this.skills,
    required this.isVirtual,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: (data['time'] as Timestamp).toDate(),
      duration: data['duration'] ?? 1,
      spots: data['spots'] ?? 0,
      registeredCount: data['registeredCount'] ?? 0,
      organizerId: data['organizerId'] ?? '',
      organizerName: data['organizerName'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      isVirtual: data['isVirtual'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'location': location,
      'date': Timestamp.fromDate(date),
      'time': Timestamp.fromDate(time),
      'duration': duration,
      'spots': spots,
      'registeredCount': registeredCount,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'skills': skills,
      'isVirtual': isVirtual,
      'createdAt': Timestamp.now(),
    };
  }
}
