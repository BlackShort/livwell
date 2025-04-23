import 'dart:async';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livwell/app/donation/models/donation_model.dart';
import 'package:flutter/material.dart';

// Controller to manage NGO data and donations
class DonationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<NGOModel> ngos = <NGOModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxBool isRefreshing = false.obs;

  // For stream subscription management
  StreamSubscription<QuerySnapshot>? _ngoSubscription;

  final List<String> categories = [
    'All',
    'Education',
    'Health',
    'Environment',
    'Poverty',
    'Children',
    'Women',
    'Elderly',
  ];

  @override
  void onInit() {
    super.onInit();
    setupNGOStream();
  }

  void setupNGOStream() {
    isLoading.value = true;

    // Cancel any existing subscription
    _ngoSubscription?.cancel();

    // Set up stream listener for real-time updates
    _ngoSubscription = _firestore
        .collection('orgs')
        .snapshots()
        .listen(
          (QuerySnapshot querySnapshot) {
            final ngosList =
                querySnapshot.docs
                    .map((doc) => NGOModel.fromFirestore(doc))
                    .toList();

            ngos.assignAll(ngosList);
            isLoading.value = false;
            isRefreshing.value = false;
          },
          onError: (error) {
            isLoading.value = false;
            isRefreshing.value = false;
            Get.snackbar(
              'Error',
              'Failed to load NGOs: $error',
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900,
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        );
  }

  // Method to handle pull-to-refresh
  Future<void> refreshNGOs() async {
    isRefreshing.value = true;
    setupNGOStream();
  }

  List<NGOModel> get filteredNGOs {
    if (selectedCategory.value == 'All') {
      return ngos;
    } else {
      return ngos.where((ngo) {
        return ngo.category.trim().toLowerCase() ==
            selectedCategory.value.trim().toLowerCase();
      }).toList();
    }
  }

  void changeCategory(String category) {
    selectedCategory.value = category;

    if (category != 'All') {
      for (var ngo in ngos) {
        ngo.category.trim().toLowerCase() == category.trim().toLowerCase();
      }
    }
  }

  Future<void> navigateToNGODetail(NGOModel ngo) async {
    // Get.to(() => NGODetailPage(ngo: ngo));
  }

  Future<void> initiateDonation(NGOModel ngo) async {
    // Get.to(() => DonationFormPage(ngo: ngo));
  }

  @override
  void onClose() {
    // Cancel stream subscription when controller is closed
    _ngoSubscription?.cancel();
    super.onClose();
  }
}
