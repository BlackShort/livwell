import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SearchControl extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxBool _isSearchActive = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxList<DocumentSnapshot> _searchResults = <DocumentSnapshot>[].obs;
  final RxBool _isLoading = false.obs;
  
  bool get isSearchActive => _isSearchActive.value;
  String get searchQuery => _searchQuery.value;
  List<DocumentSnapshot> get searchResults => _searchResults;
  bool get isLoading => _isLoading.value;
  
  void activateSearch() {
    _isSearchActive.value = true;
  }
  
  void deactivateSearch() {
    _isSearchActive.value = false;
    _searchQuery.value = '';
    _searchResults.clear();
  }
  
  void updateSearchQuery(String query) {
    _searchQuery.value = query;
    if (query.isEmpty) {
      _searchResults.clear();
    } else {
      _performSearch();
    }
  }
  
  void clearSearchQuery() {
    _searchQuery.value = '';
    _searchResults.clear();
  }
  
  void _performSearch() async {
    _isLoading.value = true;
    
    try {
      String normalizedQuery = _searchQuery.value.toLowerCase().trim();
      
      // Search organizations
      QuerySnapshot orgSnapshot = await _firestore.collection('organizations').get();
      List<DocumentSnapshot> matchingOrgs = orgSnapshot.docs.where((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String name = (data['name'] ?? '').toLowerCase();
        String description = (data['description'] ?? '').toLowerCase();
        return name.contains(normalizedQuery) || description.contains(normalizedQuery);
      }).toList();
      
      // Search opportunities
      QuerySnapshot oppSnapshot = await _firestore.collection('volunteer_opportunities').get();
      List<DocumentSnapshot> matchingOpps = oppSnapshot.docs.where((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String title = (data['title'] ?? '').toLowerCase();
        String organization = (data['organization'] ?? '').toLowerCase();
        String location = (data['location'] ?? '').toLowerCase();
        
        return title.contains(normalizedQuery) || 
               organization.contains(normalizedQuery) || 
               location.contains(normalizedQuery);
      }).toList();
      
      // Combine results (organizations first, then opportunities)
      _searchResults.value = [...matchingOrgs, ...matchingOpps];
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to perform search. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Helper method to determine if an item is an organization or opportunity
  bool isOrganization(DocumentSnapshot doc) {
    return doc.reference.path.startsWith('organizations/');
  }
}