import 'dart:async';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:livwell/app/volunteer/models/events_model.dart';

class VolunteerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<EventModel> registeredEvents = <EventModel>[].obs;
  final RxList<EventModel> myEvents = <EventModel>[].obs;
  final RxBool isLoading = true.obs;

  // Stream subscriptions
  StreamSubscription? _registeredEventsSubscription;
  StreamSubscription? _myEventsSubscription;

  @override
  void onInit() {
    super.onInit();
    startStreams();
  }

  @override
  void onClose() {
    _registeredEventsSubscription?.cancel();
    _myEventsSubscription?.cancel();
    super.onClose();
  }

  void startStreams() {
    listenToRegisteredEvents();
    listenToMyEvents();
  }

  Future<void> listenToRegisteredEvents() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        registeredEvents.clear();
        isLoading.value = false;
        return;
      }

      // Cancel any existing subscription
      _registeredEventsSubscription?.cancel();

      isLoading.value = true;

      // Listen to registrations collection
      _registeredEventsSubscription = _firestore
          .collection('registrations')
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .listen(
            (registrationSnapshot) async {
              try {
                // Get event IDs from registrations
                final eventIds =
                    registrationSnapshot.docs
                        .map((doc) => doc['eventId'] as String)
                        .toList();

                if (eventIds.isEmpty) {
                  registeredEvents.clear();
                  isLoading.value = false;
                  return;
                }

                // Fetch events by batches (Firestore limits "in" queries to 10 items)
                List<EventModel> events = [];
                for (int i = 0; i < eventIds.length; i += 10) {
                  final end =
                      (i + 10 < eventIds.length) ? i + 10 : eventIds.length;
                  final batch = eventIds.sublist(i, end);

                  final eventSnapshots =
                      await _firestore
                          .collection('events')
                          .where(FieldPath.documentId, whereIn: batch)
                          .get();

                  events.addAll(
                    eventSnapshots.docs.map(
                      (doc) => EventModel.fromFirestore(doc),
                    ),
                  );
                }

                // Sort by date (most recent first)
                events.sort((a, b) => a.date.compareTo(b.date));
                registeredEvents.assignAll(events);
              } catch (e) {
                Get.snackbar('Error', 'Failed to load registered events: $e');
              } finally {
                isLoading.value = false;
              }
            },
            onError: (error) {
              Get.snackbar('Error', 'Stream error: $error');
              isLoading.value = false;
            },
          );
    } catch (e) {
      Get.snackbar('Error', 'Failed to start registered events stream: $e');
      isLoading.value = false;
    }
  }

  Future<void> listenToMyEvents() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        myEvents.clear();
        isLoading.value = false;
        return;
      }

      // Cancel any existing subscription
      _myEventsSubscription?.cancel();

      isLoading.value = true;

      // Stream of events created by current user
      _myEventsSubscription = _firestore
          .collection('events')
          .where('organizerId', isEqualTo: user.uid)
          .snapshots()
          .listen(
            (eventSnapshot) {
              try {
                final events =
                    eventSnapshot.docs
                        .map((doc) {
                          try {
                            return EventModel.fromFirestore(doc);
                          } catch (e) {
                            print('Error parsing event ${doc.id}: $e');
                            return null;
                          }
                        })
                        .where((event) => event != null)
                        .cast<EventModel>()
                        .toList();

                // Sort by date
                events.sort((a, b) => a.date.compareTo(b.date));
                myEvents.assignAll(events);
              } catch (e) {
                print('Error processing events: $e');
              } finally {
                isLoading.value = false;
              }
            },
            onError: (error) {
              Get.snackbar('Error', 'Stream error: $error');
              isLoading.value = false;
            },
          );
    } catch (e) {
      Get.snackbar('Error', 'Failed to start my events stream: $e');
      isLoading.value = false;
    }
  }

  // Pull-to-refresh function for registered events
  Future<void> refreshRegisteredEvents() async {
    // Simply restart the stream to get fresh data
    await listenToRegisteredEvents();
    return;
  }

  // Pull-to-refresh function for my events
  Future<void> refreshMyEvents() async {
    // Simply restart the stream to get fresh data
    await listenToMyEvents();
    return;
  }

  Future<void> cancelRegistration(String eventId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Find the registration document
      final registrationSnapshot =
          await _firestore
              .collection('registrations')
              .where('userId', isEqualTo: user.uid)
              .where('eventId', isEqualTo: eventId)
              .get();

      if (registrationSnapshot.docs.isNotEmpty) {
        // Delete the registration
        await _firestore
            .collection('registrations')
            .doc(registrationSnapshot.docs.first.id)
            .delete();

        // Update the event's registered count
        await _firestore.collection('events').doc(eventId).update({
          'registeredCount': FieldValue.increment(-1),
        });

        Get.snackbar('Success', 'Registration cancelled successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel registration: $e');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      // Delete the event document
      await _firestore.collection('events').doc(eventId).delete();

      // Delete related registrations
      final registrationsSnapshot =
          await _firestore
              .collection('registrations')
              .where('eventId', isEqualTo: eventId)
              .get();

      final batch = _firestore.batch();
      for (var doc in registrationsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      Get.snackbar('Success', 'Event deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete event: $e');
    }
  }

  Future<void> createEvent(EventModel event) async {
    try {
      // Add to Firestore and get document reference
      DocumentReference eventRef = await _firestore.collection('events').add({
        'title': event.title,
        'description': event.description,
        'imageUrl': event.imageUrl,
        'organizerId': event.organizerId,
        'organizerName': event.organizerName,
        'date': event.date,
        'location': event.location,
        'registeredCount': 0,
        'createdAt': Timestamp.now(),
        'likes': 0,
        'comments': 0,
        'category': event.category,
        'time': event.time,
        'duration': event.duration,
        'spots': event.spots,
        'skills': event.skills,
        'isVirtual': event.isVirtual,
      });

      // Use the generated event ID for the post
      await _firestore.collection('posts').add({
        'title': 'New Volunteer Event: ${event.title}',
        'content': event.description,
        'imageUrl': event.imageUrl,
        'authorId': event.organizerId,
        'authorName': event.organizerName,
        'type': 'event',
        'eventId': eventRef.id,
        'createdAt': Timestamp.now(),
        'likes': 0,
        'comments': 0,
      });

      Get.back();
      Get.snackbar('Success', 'Event created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create event: $e');
    }
  }
}
