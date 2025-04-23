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
  final int duration;
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
    this.category = 'General',
    required this.location,
    required this.date,
    required this.time,
    this.duration = 1,
    this.spots = 10,
    required this.registeredCount,
    required this.organizerId,
    required this.organizerName,
    required this.skills,
    this.isVirtual = false,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Safely handle date fields
    DateTime dateValue;
    try {
      dateValue = data['date'] is Timestamp 
          ? (data['date'] as Timestamp).toDate() 
          : DateTime.now();
    } catch (e) {
      dateValue = DateTime.now();
    }
    
    // Safely handle time (which might be missing)
    DateTime timeValue;
    try {
      timeValue = data['time'] is Timestamp 
          ? (data['time'] as Timestamp).toDate() 
          : dateValue; // Use date as fallback
    } catch (e) {
      timeValue = dateValue;
    }
    
    // Handle skills array which might be missing
    List<String> skillsList = [];
    try {
      if (data['skills'] != null) {
        skillsList = List<String>.from(data['skills']);
      }
    } catch (e) {
      skillsList = [];
    }

    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? 'General',
      location: data['location'] ?? '',
      date: dateValue,
      time: timeValue,
      duration: data['duration'] ?? 1,
      spots: data['spots'] ?? 10,
      registeredCount: data['registeredCount'] ?? 0,
      organizerId: data['organizerId'] ?? '',
      organizerName: data['organizerName'] ?? '',
      skills: skillsList,
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