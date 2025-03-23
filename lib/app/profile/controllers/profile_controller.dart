import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livwell/app/auth/controllers/auth_controller.dart';
import 'package:livwell/app/auth/models/user_model.dart';
import 'package:livwell/core/errors/custom_snackbar.dart';
import 'package:livwell/core/utils/user_preferences.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  
  Rx<UserModel?> userModel = Rx<UserModel?>(null);
  RxBool isLoading = false.obs;
  RxBool isEditing = false.obs;

  // Form controllers from UI
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  
  ProfileController({
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
  });
  
  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }
  
  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
  
  Future<void> loadUserProfile() async {
    try {
      isLoading(true);
      
      // First try to get user from preferences
      UserModel? user = UserPreferences.getUserModel();
      
      // If not available in preferences, fetch from database
      if (user == null) {
        final currentUser = _authController.user.value;
        if (currentUser != null) {
          user = await _authController.getUserProfile(currentUser.uid);
          
          // Save to preferences for future use
          if (user != null) {
            await UserPreferences.setUserModel(user);
            await UserPreferences.setUserId(currentUser.uid);
          }
        }
      }
      
      userModel.value = user;
      
      // Populate form controllers if user data is available
      if (user != null) {
        firstNameController.text = user.firstName;
        lastNameController.text = user.lastName;
        emailController.text = user.email;
        phoneController.text = user.phone ?? '';
      }
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to load profile: $e',
      );
    } finally {
      isLoading(false);
    }
  }
  
  void toggleEditMode() {
    isEditing(!isEditing.value);
  }
  
  Future<void> updateProfile() async {
    if (userModel.value == null) return;
    
    try {
      isLoading(true);
      
      // Create updated user model
      final updatedUser = UserModel(
        uid: userModel.value!.uid,
        email: emailController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phone: phoneController.text.trim(),
        photoUrl: userModel.value!.photoUrl,
        createdAt: userModel.value!.createdAt,
      );
      
      // Update in database
      await _authController.updateUserProfile(updatedUser);
      
      // Update in preferences
      await UserPreferences.setUserModel(updatedUser);
      
      // Update local state
      userModel.value = updatedUser;
      
      // Exit edit mode
      isEditing(false);
      
      CustomSnackbar.showSuccess(
        title: 'Success',
        message: 'Profile updated successfully',
      );
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to update profile: $e',
      );
    } finally {
      isLoading(false);
    }
  }
  
  Future<void> logout() async {
    try {
      isLoading(true);
      await _authController.signOut();
      await UserPreferences.clearUserData();
      Get.offAllNamed('/login');
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to logout: $e',
      );
    } finally {
      isLoading(false);
    }
  }
}