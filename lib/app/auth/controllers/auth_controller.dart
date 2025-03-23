import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:livwell/app/auth/models/user_model.dart';
import 'package:livwell/core/errors/custom_snackbar.dart';
import 'package:livwell/core/services/auth_service.dart';
import 'package:livwell/core/services/user_preferences.dart';
import 'package:livwell/config/routes/route_names.dart';

class AuthController extends GetxController {
  final AuthServices _authService = AuthServices();

  RxBool isLoading = false.obs;
  Rxn<User> user = Rxn<User>();
  Rxn<UserModel> userModel = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    // Bind to Firebase Auth state changes
    user.bindStream(_authService.authStateChanges);
    
    // React to auth state changes
    ever(user, _handleAuthChanged);
    
    // Try to load cached user on startup
    _loadCachedUser();
  }
  
  // Load cached user on startup
  void _loadCachedUser() async {
    UserModel? cachedUser = UserPreferences.getUserModel();
    if (cachedUser != null) {
      userModel.value = cachedUser;
    }
  }
  
  // Handle auth state changes
  void _handleAuthChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      isLoading(true);
      try {
        // User logged in - fetch profile from Firestore
        final userProfile = await _authService.getUserProfile(firebaseUser.uid);
        
        if (userProfile != null) {
          // Found profile, save to Hive
          userModel.value = userProfile;
          await UserPreferences.setUserModel(userProfile);
          await UserPreferences.setUserId(firebaseUser.uid);
        } else {
          // No profile found - should never happen but handle gracefully
          CustomSnackbar.showError(
            title: 'Profile Error',
            message: 'Failed to load user profile. Please try logging in again.',
          );
          await signOut();
        }
      } catch (e) {
        CustomSnackbar.showError(
          title: 'Error',
          message: 'Failed to load user profile: ${e.toString()}',
        );
      } finally {
        isLoading(false);
      }
    } else {
      // User logged out
      userModel.value = null;
      await UserPreferences.clearUserData();
    }
  }

  // Sign in with email and password
  Future<void> signIn(Map<String, dynamic> userData) async {
    try {
      isLoading(true);
      
      // Sign in with Firebase
      final userCredential = await _authService.signInWithEmailAndPassword(
        userData['email'],
        userData['password'],
      );

      if (userCredential.user != null) {
        // Auth state listener will handle profile loading
        CustomSnackbar.showSuccess(
          title: 'Success',
          message: 'Logged in successfully',
        );
        
        Get.offAllNamed(AppRoute.base);
      }
    } catch (e) {
      CustomSnackbar.showError(title: 'Error', message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Sign up with email and password
  Future<void> signUp(Map<String, dynamic> userData) async {
    try {
      isLoading(true);
      
      // Create Firebase account
      final userCredential = await _authService.createUserWithEmailAndPassword(
        userData['email'],
        userData['password'],
      );

      if (userCredential.user != null) {
        // Create user profile data
        final userProfileData = {
          'uid': userCredential.user!.uid,
          'email': userData['email'],
          'firstName': userData['firstName'],
          'lastName': userData['lastName'],
        };
        
        // Create user in Firestore first
        final userModel = await _authService.createUserProfile(userProfileData);
        
        // Update display name in Firebase Auth
        await _authService.updateUserDisplayName(
          userCredential.user!,
          '${userData['firstName']} ${userData['lastName']}',
        );
        
        // Save to local storage
        this.userModel.value = userModel;
        await UserPreferences.setUserModel(userModel);
        await UserPreferences.setUserId(userCredential.user!.uid);

        CustomSnackbar.showSuccess(
          title: 'Success',
          message: 'Account created successfully',
        );
        
        // Navigate to home page
        Get.offAllNamed(AppRoute.base);
      }
    } catch (e) {
      CustomSnackbar.showError(title: 'Error', message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Sign in with Google - Improved
  Future<void> signInWithGoogle() async {
    try {
      isLoading(true);
      final userCredential = await _authService.signInWithGoogle();

      // Check if this is a new user
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        // Extract user details from Google account
        final displayName = userCredential.user?.displayName ?? '';
        final names = displayName.split(' ');
        final firstName = names.isNotEmpty ? names.first : '';
        final lastName = names.length > 1 ? names.last : '';

        // Create user profile data
        final userProfileData = {
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email ?? '',
          'firstName': firstName,
          'lastName': lastName,
          'photoUrl': userCredential.user!.photoURL,
        };
        
        // Create user in Firestore first
        final newUserModel = await _authService.createUserProfile(userProfileData);
        
        // Save to local storage
        userModel.value = newUserModel;
        await UserPreferences.setUserModel(newUserModel);
        await UserPreferences.setUserId(userCredential.user!.uid);
        
        CustomSnackbar.showSuccess(
          title: 'Welcome',
          message: 'Account created successfully',
        );
      } else {
        // Auth state listener will handle profile loading
        CustomSnackbar.showSuccess(
          title: 'Success',
          message: 'Logged in successfully',
        );
      }
      
      // Navigate to home page
      Get.offAllNamed(AppRoute.home);
    } catch (e) {
      CustomSnackbar.showError(title: 'Error', message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Sign in with Apple - Improved
  Future<void> signInWithApple() async {
    try {
      isLoading(true);
      final userCredential = await _authService.signInWithApple();

      // Check if this is a new user
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        // Extract name from Apple credential if available
        String firstName = '';
        String lastName = '';
        
        // Apple may not provide displayName so handle this better
        if (userCredential.user?.displayName != null) {
          final names = userCredential.user!.displayName!.split(' ');
          firstName = names.isNotEmpty ? names.first : '';
          lastName = names.length > 1 ? names.last : '';
        } else {
          // Default names if not provided
          firstName = 'Apple';
          lastName = 'User';
        }

        // Create user profile data
        final userProfileData = {
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email ?? '',
          'firstName': firstName,
          'lastName': lastName,
          'photoUrl': userCredential.user!.photoURL,
        };
        
        // Create user in Firestore first
        final newUserModel = await _authService.createUserProfile(userProfileData);
        
        // Update display name if needed
        if (userCredential.user?.displayName == null) {
          await _authService.updateUserDisplayName(
            userCredential.user!,
            '$firstName $lastName',
          );
        }
        
        // Save to local storage
        userModel.value = newUserModel;
        await UserPreferences.setUserModel(newUserModel);
        await UserPreferences.setUserId(userCredential.user!.uid);
        
        CustomSnackbar.showSuccess(
          title: 'Welcome',
          message: 'Account created successfully',
        );
      } else {
        // Auth state listener will handle profile loading
        CustomSnackbar.showSuccess(
          title: 'Success',
          message: 'Logged in successfully',
        );
      }
      
      // Navigate to home page
      Get.offAllNamed(AppRoute.home);
    } catch (e) {
      CustomSnackbar.showError(title: 'Error', message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Sign out - Improved
  Future<void> signOut() async {
    try {
      isLoading(true);
      
      // Clear local data first
      userModel.value = null;
      await UserPreferences.clearUserData();
      
      // Then sign out from Firebase
      await _authService.signOut();
      
      // Navigate to login page
      Get.offAllNamed(AppRoute.login);
    } catch (e) {
      CustomSnackbar.showError(title: 'Error', message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Reset password - Improved error handling
  Future<void> resetPassword(String email) async {
    try {
      isLoading(true);
      await _authService.resetPassword(email);
      CustomSnackbar.showSuccess(
        title: 'Success',
        message: 'Password reset email sent to $email',
      );
    } catch (e) {
      CustomSnackbar.showError(title: 'Error', message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Get user profile - This is now primarily handled by the auth state listener
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      isLoading(true);
      final profile = await _authService.getUserProfile(uid);
      if (profile != null) {
        userModel.value = profile;
        await UserPreferences.setUserModel(profile);
      }
      return profile;
    } catch (e) {
      CustomSnackbar.showError(title: 'Error', message: e.toString());
      return null;
    } finally {
      isLoading(false);
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel updatedUser) async {
    try {
      isLoading(true);
      
      // Update in Firestore first
      await _authService.updateUserProfile(updatedUser);
      
      // Then update local
      userModel.value = updatedUser;
      await UserPreferences.setUserModel(updatedUser);
      
      CustomSnackbar.showSuccess(
        title: 'Success',
        message: 'Profile updated successfully',
      );
    } catch (e) {
      CustomSnackbar.showError(title: 'Error', message: e.toString());
    } finally {
      isLoading(false);
    }
  }
}