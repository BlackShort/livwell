import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ActivityController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool isLoading = true.obs;
  RxInt totalHours = 0.obs;
  RxInt totalMinutes = 0.obs;
  RxList<Map<String, dynamic>> activities = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchActivities();
  }

  Future<void> fetchActivities() async {
    try {
      isLoading.value = true;
      final userId = _auth.currentUser?.uid;

      if (userId == null) {
        activities.clear();
        totalHours.value = 0;
        totalMinutes.value = 0;
        isLoading.value = false;
        return;
      }

      final snapshot = await _firestore
          .collection('activities')
          .where('userId', isEqualTo: userId)
          .get();

      final List<Map<String, dynamic>> fetchedActivities = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      activities.assignAll(fetchedActivities);

      // Calculate total approved hours and minutes
      int hoursSum = 0;
      int minutesSum = 0;

      for (var activity in fetchedActivities) {
        if (activity['status'] == 'Approved') {
          final int hours = activity['hours'] ?? 0;
          final int minutes = activity['minutes'] ?? 0;
          hoursSum += hours;
          minutesSum += minutes;
        }
      }

      hoursSum += minutesSum ~/ 60;
      minutesSum = minutesSum % 60;

      totalHours.value = hoursSum;
      totalMinutes.value = minutesSum;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch activities: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void openAddHours() {
    // Navigate to add hours page
    Get.toNamed('/add-hours'); // Update route as needed
  }

  void openFilterOptions() {
    // Implement filter logic or navigation if required
    Get.snackbar('Filter', 'Filter options to be implemented');
  }

  void editActivity(String activityId) {
    // Navigate to edit activity page with activity ID
    Get.toNamed('/edit-activity', arguments: {'activityId': activityId});
  }
}
