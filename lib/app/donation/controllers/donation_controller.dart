import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livwell/app/donation/models/donation_model.dart';


// Controller to manage NGO data and donations
class DonationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<NGOModel> ngos = <NGOModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedCategory = 'All'.obs;
  
  final List<String> categories = [
    'All', 'Education', 'Health', 'Environment', 'Poverty', 'Children', 'Women', 'Elderly'
  ];

  @override
  void onInit() {
    super.onInit();
    fetchNGOs();
  }

  Future<void> fetchNGOs() async {
    try {
      isLoading.value = true;
      final querySnapshot = await _firestore.collection('ngos').get();
      
      final ngosList = querySnapshot.docs
          .map((doc) => NGOModel.fromFirestore(doc))
          .toList();
      
      ngos.assignAll(ngosList);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load NGOs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<NGOModel> get filteredNGOs {
    if (selectedCategory.value == 'All') {
      return ngos;
    } else {
      return ngos.where((ngo) => ngo.category == selectedCategory.value).toList();
    }
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  Future<void> navigateToNGODetail(NGOModel ngo) async {
    // Get.to(() => NGODetailPage(ngo: ngo));
  }

  Future<void> initiateDonation(NGOModel ngo) async {
    // Get.to(() => DonationFormPage(ngo: ngo));
  }
}
