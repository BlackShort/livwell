import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livwell/app/auth/controllers/auth_controller.dart';
import 'package:livwell/app/auth/models/user_model.dart';
import 'package:livwell/app/auth/pages/login_page.dart';
import 'package:livwell/core/errors/custom_snackbar.dart';
import 'package:livwell/core/services/user_preferences.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  
  // State variables
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isEditing = false.obs;

  // Form controllers
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  
  ProfileController() {
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
  }
  
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
      
      // Try to get user from Hive first (local storage)
      final user = UserPreferences.getUserModel();
      
      if (user != null) {
        // Use cached user data if available
        _updateUserData(user);
      } else {
        // Fallback to fetching from database
        await _fetchUserFromDatabase();
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
  
  Future<void> _fetchUserFromDatabase() async {
    final currentUser = _authController.user.value;
    if (currentUser != null) {
      final user = await _authController.getUserProfile(currentUser.uid);
      
      if (user != null) {
        // Save to preferences for future use
        await UserPreferences.setUserModel(user);
        await UserPreferences.setUserId(currentUser.uid);
        
        // Update UI
        _updateUserData(user);
      }
    }
  }
  
  void _updateUserData(UserModel user) {
    userModel.value = user;
    
    // Populate form controllers
    firstNameController.text = user.firstName;
    lastNameController.text = user.lastName;
    emailController.text = user.email;
    phoneController.text = user.phone ?? '';
  }
  
  void toggleEditMode() {
    if (isEditing.value) {
      // Cancel edit - restore original values
      final user = userModel.value;
      if (user != null) {
        firstNameController.text = user.firstName;
        lastNameController.text = user.lastName;
        phoneController.text = user.phone ?? '';
      }
    }
    
    isEditing(!isEditing.value);
  }
  
  Future<void> updateProfile() async {
    if (userModel.value == null) return;
    
    // Form validation
    if (firstNameController.text.trim().isEmpty || 
        lastNameController.text.trim().isEmpty) {
      CustomSnackbar.showError(
        title: 'Validation Error',
        message: 'First name and last name are required',
      );
      return;
    }
    
    try {
      isLoading(true);
      
      // Create updated user model
      final updatedUser = userModel.value!.copyWith(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phone: phoneController.text.trim(),
        isProfileComplete: true,
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
      Get.offAll(() => LoginPage());
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