import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool showMyOrgs = true.obs;
  RxList<Map<String, dynamic>> orgs = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> opportunities = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    listenToOrganizations();
    listenToOpportunities();
  }

  void toggleTab(bool value) {
    showMyOrgs.value = value;
    listenToOpportunities();
  }

  void listenToOrganizations() {
    _firestore.collection('organizations').snapshots().listen((snapshot) {
      orgs.value = snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  void listenToOpportunities() {
    Query query = _firestore.collection('volunteer_opportunities');
    if (showMyOrgs.value) {
      // Example org IDs, replace with dynamic user-based logic
      query = query.where('organizationId', whereIn: ['org1', 'org2']);
    }
    query.snapshots().listen((snapshot) {
      opportunities.value = snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    });
  }

  void toggleFavorite(String docId, bool currentStatus) {
    _firestore
        .collection('volunteer_opportunities')
        .doc(docId)
        .update({'isFavorite': !currentStatus});
  }
}
