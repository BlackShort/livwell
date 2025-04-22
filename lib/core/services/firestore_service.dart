import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:livwell/app/home/models/home_model.dart';
import 'package:livwell/core/services/auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = AuthServices().currentUser;

  // Get all volunteer opportunities
  Stream<List<VolunteerOpportunity>> getOpportunities() {
    return _firestore.collection('volunteer_opportunities').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => VolunteerOpportunity.fromFirestore(doc))
          .toList();
    });
  }

  // Get opportunities for specific organizations
  Stream<List<VolunteerOpportunity>> getOrganizationOpportunities(
    List<String> orgIds,
  ) {
    return _firestore
        .collection('volunteer_opportunities')
        .where('organizationId', whereIn: orgIds)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => VolunteerOpportunity.fromFirestore(doc))
              .toList();
        });
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String opportunityId, bool isFavorite) {
    return _firestore
        .collection('volunteer_opportunities')
        .doc(opportunityId)
        .update({'isFavorite': isFavorite});
  }

  // Register for an opportunity
  Future<void> registerForOpportunity(
    String opportunityId,
    String userId,
  ) async {
    // Create registration record
    await _firestore.collection('registrations').add({
      'opportunityId': opportunityId,
      'userId': userId,
      'registeredAt': Timestamp.now(),
      'status': 'confirmed',
    });

    // Update spots left
    DocumentSnapshot opportunityDoc =
        await _firestore
            .collection('volunteer_opportunities')
            .doc(opportunityId)
            .get();

    Map<String, dynamic> data = opportunityDoc.data() as Map<String, dynamic>;
    int spotsLeft = data['spotsLeft'] ?? 0;

    if (spotsLeft > 0) {
      await _firestore
          .collection('volunteer_opportunities')
          .doc(opportunityId)
          .update({'spotsLeft': spotsLeft - 1});
    }
  }

  Stream<QuerySnapshot> getNotificationsStream() {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get notifications as Future
  Future<List<QueryDocumentSnapshot>> getNotifications() async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    final snapshot =
        await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .get();

    return snapshot.docs;
  }

  // Mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    final batch = _firestore.batch();
    final notifications =
        await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .collection('notifications')
            .where('isRead', isEqualTo: false)
            .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }
}
