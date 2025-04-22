import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:livwell/app/causes/models/cause_model.dart';

class CauseController extends GetxController {
  final RxList<CauseModel> causes = <CauseModel>[].obs;
  final RxBool isLoading = false.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _initCauses();
    loadUserInterests();
  }

  void _initCauses() {
    causes.value = [
      CauseModel(
        id: 'climate',
        name: 'Climate',
        icon: Icons.wb_sunny,
        color: Colors.orange.shade100,
        selectedColor: Colors.orange,
      ),
      CauseModel(
        id: 'animals',
        name: 'Animals',
        icon: Icons.pets,
        color: Colors.grey.shade100,
        selectedColor: Colors.orange,
      ),
      CauseModel(
        id: 'food',
        name: 'Food',
        icon: Icons.restaurant,
        color: Colors.grey.shade100,
        selectedColor: Colors.orange,
      ),
      CauseModel(
        id: 'arts',
        name: 'Arts & Culture',
        icon: Icons.palette,
        color: Colors.grey.shade100,
        selectedColor: Colors.orange,
      ),
      CauseModel(
        id: 'health',
        name: 'Health',
        icon: Icons.favorite,
        color: Colors.grey.shade100,
        selectedColor: Colors.orange,
      ),
      CauseModel(
        id: 'water',
        name: 'Water & Sanitation',
        icon: Icons.waves,
        color: Colors.orange.shade100,
        selectedColor: Colors.orange,
      ),
      CauseModel(
        id: 'poverty',
        name: 'Poverty',
        icon: Icons.attach_money,
        color: Colors.grey.shade100,
        selectedColor: Colors.orange,
      ),
      CauseModel(
        id: 'education',
        name: 'Education',
        icon: Icons.book,
        color: Colors.orange.shade100,
        selectedColor: Colors.orange,
      ),
      CauseModel(
        id: 'equality',
        name: 'Equality',
        icon: Icons.balance,
        color: Colors.grey.shade100,
        selectedColor: Colors.orange,
      ),
      CauseModel(
        id: 'energy',
        name: 'Energy',
        icon: Icons.bolt,
        color: Colors.grey.shade100,
        selectedColor: Colors.orange,
      ),
      CauseModel(
        id: 'community',
        name: 'Community Development',
        icon: Icons.business,
        color: Colors.grey.shade100,
        selectedColor: Colors.orange,
      ),
      CauseModel(
        id: 'conservation',
        name: 'Conservation',
        icon: Icons.eco,
        color: Colors.grey.shade100,
        selectedColor: Colors.orange,
      ),
      CauseModel(
        id: 'peace',
        name: 'Peace & Justice',
        icon: Icons.safety_check,
        color: Colors.grey.shade100,
        selectedColor: Colors.orange,
      ),
      CauseModel(
        id: 'family',
        name: 'Family',
        icon: Icons.family_restroom,
        color: Colors.grey.shade100,
        selectedColor: Colors.orange,
      ),
      CauseModel(
        id: 'crisis',
        name: 'Crisis',
        icon: Icons.warning,
        color: Colors.orange.shade100,
        selectedColor: Colors.orange,
      ),
      CauseModel(
        id: 'refugees',
        name: 'Refugees',
        icon: Icons.flight_takeoff,
        color: Colors.grey.shade100,
        selectedColor: Colors.orange,
      ),
      CauseModel(
        id: 'homeless',
        name: 'Homeless',
        icon: Icons.key,
        color: Colors.grey.shade100,
        selectedColor: Colors.orange,
      ),
      CauseModel(
        id: 'consumption',
        name: 'Consumption',
        icon: Icons.autorenew,
        color: Colors.grey.shade100,
        selectedColor: Colors.orange,
      ),
    ];
  }

  // Change from private to public
  Future<void> loadUserInterests() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        final userData =
            await _firestore.collection('users').doc(user.uid).get();

        if (userData.exists && userData.data()!.containsKey('interests')) {
          final List<dynamic> interests = userData.data()!['interests'];

          // Update the selected state based on user's interests
          for (int i = 0; i < causes.length; i++) {
            final cause = causes[i];
            if (interests.contains(cause.id)) {
              causes[i] = cause.copyWith(isSelected: true);
            } else {
              causes[i] = cause.copyWith(isSelected: false);
            }
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load your interests');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleCause(int index) {
    final cause = causes[index];
    causes[index] = cause.copyWith(isSelected: !cause.isSelected);
    _updateUserInterests();
  }

  Future<void> _updateUserInterests() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final selectedCauseIds =
            causes
                .where((cause) => cause.isSelected)
                .map((cause) => cause.id)
                .toList();

        await _firestore.collection('users').doc(user.uid).update({
          'interests': selectedCauseIds,
        });

        Get.snackbar(
          'Success',
          'Your interests have been updated',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update your interests');
    }
  }
}
