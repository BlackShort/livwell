import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livwell/app/home/models/home_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all volunteer opportunities
  Stream<List<VolunteerOpportunity>> getOpportunities() {
    return _firestore
        .collection('volunteer_opportunities')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => VolunteerOpportunity.fromFirestore(doc))
          .toList();
    });
  }

  // Get opportunities for specific organizations
  Stream<List<VolunteerOpportunity>> getOrganizationOpportunities(List<String> orgIds) {
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
  Future<void> registerForOpportunity(String opportunityId, String userId) async {
    // Create registration record
    await _firestore.collection('registrations').add({
      'opportunityId': opportunityId,
      'userId': userId,
      'registeredAt': Timestamp.now(),
      'status': 'confirmed',
    });

    // Update spots left
    DocumentSnapshot opportunityDoc = await _firestore
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
}