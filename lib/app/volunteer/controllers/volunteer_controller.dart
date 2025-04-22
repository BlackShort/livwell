import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:livwell/app/volunteer/models/events_model.dart';


// Volunteer Controller
class VolunteerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final RxList<EventModel> registeredEvents = <EventModel>[].obs;
  final RxList<EventModel> myEvents = <EventModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRegisteredEvents();
    fetchMyEvents();
  }

  Future<void> fetchRegisteredEvents() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      
      if (user != null) {
        // Get registrations for current user
        final registrationSnapshot = await _firestore
            .collection('registrations')
            .where('userId', isEqualTo: user.uid)
            .get();
        
        // Get event IDs from registrations
        final eventIds = registrationSnapshot.docs.map((doc) => doc['eventId'] as String).toList();
        
        if (eventIds.isEmpty) {
          registeredEvents.clear();
          return;
        }
        
        // Fetch events by batches (Firestore limits "in" queries to 10 items)
        List<EventModel> events = [];
        for (int i = 0; i < eventIds.length; i += 10) {
          final end = (i + 10 < eventIds.length) ? i + 10 : eventIds.length;
          final batch = eventIds.sublist(i, end);
          
          final eventSnapshots = await _firestore
              .collection('events')
              .where(FieldPath.documentId, whereIn: batch)
              .get();
          
          events.addAll(eventSnapshots.docs.map((doc) => EventModel.fromFirestore(doc)));
        }
        
        // Sort by date (most recent first)
        events.sort((a, b) => a.date.compareTo(b.date));
        registeredEvents.assignAll(events);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load registered events: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMyEvents() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      
      if (user != null) {
        final eventSnapshots = await _firestore
            .collection('events')
            .where('organizerId', isEqualTo: user.uid)
            .orderBy('date')
            .get();
        
        final events = eventSnapshots.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
        myEvents.assignAll(events);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load your events: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelRegistration(String eventId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      // Find the registration document
      final registrationSnapshot = await _firestore
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
          'registeredCount': FieldValue.increment(-1)
        });
        
        // Remove from local list
        registeredEvents.removeWhere((event) => event.id == eventId);
        
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
      final registrationsSnapshot = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .get();
      
      final batch = _firestore.batch();
      for (var doc in registrationsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      // Remove from local list
      myEvents.removeWhere((event) => event.id == eventId);
      
      Get.snackbar('Success', 'Event deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete event: $e');
    }
  }

  Future<void> createEvent(EventModel event) async {
    try {
      // Add to Firestore
      await _firestore.collection('events').add(event.toFirestore());
      
      // Create a post about this event
      await _firestore.collection('posts').add({
        'title': 'New Volunteer Event: ${event.title}',
        'content': event.description,
        'imageUrl': event.imageUrl,
        'authorId': event.organizerId,
        'authorName': event.organizerName,
        'type': 'event',
        'eventId': event.id,
        'createdAt': Timestamp.now(),
        'likes': 0,
        'comments': 0,
      });
      
      // Refresh events
      fetchMyEvents();
      
      Get.back();
      Get.snackbar('Success', 'Event created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create event: $e');
    }
  }
}
