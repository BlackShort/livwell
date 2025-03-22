import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable variables
  final RxBool _showMyOrgs = true.obs;
  final RxBool _isLoading = true.obs;
  final RxBool _isRefreshing = false.obs;
  final RxList<DocumentSnapshot> _organizations = <DocumentSnapshot>[].obs;
  final RxList<DocumentSnapshot> _opportunities = <DocumentSnapshot>[].obs;
  final RxString _selectedOrgId = ''.obs; // Selected org filter

  // Getters
  bool get showMyOrgs => _showMyOrgs.value;
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  List<DocumentSnapshot> get organizations => _organizations;
  List<DocumentSnapshot> get opportunities => _opportunities;
  String get selectedOrgId => _selectedOrgId.value;

  // Stream subscriptions
  late Stream<QuerySnapshot> _organizationsStream;
  late Stream<QuerySnapshot> _opportunitiesStream;

  // List of organizations the current user is following
  final List<String> _userOrgIds = [
    'org1',
    'org2',
    'org3',
    'org4',
    'org5',
    'org6',
    'org7',
    'org8',
    'org9',
    'org10',
  ]; // In a real app, fetch this from user profile

  @override
  void onInit() {
    super.onInit();
    // Initialize streams
    _initStreams();

    // Set loading to false after a short delay to simulate data fetching
    Future.delayed(const Duration(milliseconds: 800), () {
      setLoading(false);
    });
  }

  @override
  void onClose() {
    // Clean up will be handled by GetX automatically
    super.onClose();
  }

  void _initStreams() {
    // Setup organizations stream
    _organizationsStream = _firestore.collection('organizations').snapshots();
    _organizationsStream.listen((QuerySnapshot snapshot) {
      _organizations.value = snapshot.docs;
    });

    // Setup initial opportunities stream
    _updateOpportunitiesStream();
  }

  void toggleView(bool showMyOrgs) {
    if (_showMyOrgs.value != showMyOrgs) {
      _showMyOrgs.value = showMyOrgs;
      // Reset selected org when changing views
      _selectedOrgId.value = '';
      // Update opportunities stream when view changes
      _updateOpportunitiesStream();
    }
  }

  void _updateOpportunitiesStream() {
    Query query = _firestore.collection('volunteer_opportunities');

    // Filter based on selected tab
    if (_showMyOrgs.value) {
      // Filter by user's organizations
      query = query.where('organizationId', whereIn: _userOrgIds);
    }

    // Additional filter by selected organization if any
    if (_selectedOrgId.value.isNotEmpty) {
      query = query.where('organizationId', isEqualTo: _selectedOrgId.value);
    }

    _opportunitiesStream = query.snapshots();
    _opportunitiesStream.listen((QuerySnapshot snapshot) {
      _opportunities.value = snapshot.docs;
    });
  }

  // Toggle favorite status for an opportunity
  void toggleFavorite(String docId, bool currentStatus) {
    _firestore.collection('volunteer_opportunities').doc(docId).update({
      'isFavorite': !currentStatus,
    });
    // No need to manually update the UI, Firestore will trigger the listener
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading.value = loading;
  }

  // Filter opportunities by organization
  void filterByOrg(String orgId) {
    // If the same org is selected, clear the filter
    if (_selectedOrgId.value == orgId) {
      _selectedOrgId.value = '';
    } else {
      _selectedOrgId.value = orgId;
    }

    // Update the opportunities stream with new filter
    _updateOpportunitiesStream();
  }

  // Method to handle pull-to-refresh action for the entire page
  Future<void> refreshData() async {
    _isRefreshing.value = true;

    try {
      // Reset filters
      _selectedOrgId.value = '';

      // Fetch fresh data from Firestore
      QuerySnapshot orgSnapshot =
          await _firestore.collection('organizations').get();
      _organizations.value = orgSnapshot.docs;

      // Fetch opportunities based on current view
      Query query = _firestore.collection('volunteer_opportunities');
      if (_showMyOrgs.value) {
        query = query.where('organizationId', whereIn: _userOrgIds);
      }

      QuerySnapshot oppSnapshot = await query.get();
      _opportunities.value = oppSnapshot.docs;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh data. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isRefreshing.value = false;
    }

    return;
  }

  Future<void> shareOrganization(String docId) {
    return _firestore.collection('organizations').doc(docId).update({
      'isShared': true,
    });
  }

  void joinOrganization(String docId) {
    _firestore.collection('organizations').doc(docId).update({
      'isJoined': true,
    });
  }

  void leaveOrganization(String docId) {
    _firestore.collection('organizations').doc(docId).update({
      'isJoined': false,
    });
  }

  void deleteOrganization(String docId) {
    _firestore.collection('organizations').doc(docId).delete();
  }

  void updateOrganization(String docId, Map<String, dynamic> data) {
    _firestore.collection('organizations').doc(docId).update(data);
  }

  void createOrganization(Map<String, dynamic> data) {
    _firestore.collection('organizations').add(data);
  }
}
