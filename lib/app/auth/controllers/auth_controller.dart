import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:livwell/app/auth/models/user_model.dart';
import 'package:livwell/core/errors/custom_snackbar.dart';
import 'package:livwell/core/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthServices _authService = AuthServices();
  
  RxBool isLoading = false.obs;
  Rxn<User> user = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_authService.authStateChanges);
  }

  // Sign in with email and password
  Future<void> signIn(Map<String, dynamic> userData) async {
    try {
      isLoading(true);
      final userCredential = await _authService.signInWithEmailAndPassword(
        userData['email'],
        userData['password'],
      );

      if (userCredential.user != null) {
        CustomSnackbar.showSuccess(
          title: 'Success',
          message: 'Logged in successfully',
        );
      }
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: e.toString(),
      );
    } finally {
      isLoading(false);
    }
  }

  // Sign up with email and password
  Future<void> signUp(Map<String, dynamic> userData) async {
    try {
      isLoading(true);
      final userCredential = await _authService.createUserWithEmailAndPassword(
        userData['email'],
        userData['password'],
      );

      if (userCredential.user != null) {
        await _authService.createUserProfile({
          'uid': userCredential.user!.uid,
          'email': userData['email'],
          'firstName': userData['firstName'],
          'lastName': userData['lastName'],
        });

        await _authService.updateUserDisplayName(
          userCredential.user!,
          '${userData['firstName']} ${userData['lastName']}',
        );

        CustomSnackbar.showSuccess(
          title: 'Success',
          message: 'Account created successfully',
        );
      }
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: e.toString(),
      );
    } finally {
      isLoading(false);
    }
  }

  // Sign in with Google
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

        // Create user profile
        await _authService.createUserProfile({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email ?? '',
          'firstName': firstName,
          'lastName': lastName,
          'photoUrl': userCredential.user!.photoURL,
        });
      }
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: e.toString(),
      );
    } finally {
      isLoading(false);
    }
  }

  // Sign in with Apple
  Future<void> signInWithApple() async {
    try {
      isLoading(true);
      final userCredential = await _authService.signInWithApple();

      // Check if this is a new user
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        final displayName = userCredential.user?.displayName ?? '';
        final names = displayName.split(' ');
        final firstName = names.isNotEmpty ? names.first : '';
        final lastName = names.length > 1 ? names.last : '';

        // Create user profile
        await _authService.createUserProfile({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email ?? '',
          'firstName': firstName,
          'lastName': lastName,
          'photoUrl': userCredential.user!.photoURL,
        });

        // Update display name if needed
        if (displayName.isEmpty) {
          await _authService.updateUserDisplayName(
            userCredential.user!,
            '$firstName $lastName',
          );
        }
      }
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: e.toString(),
      );
    } finally {
      isLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      isLoading(true);
      await _authService.signOut();
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: e.toString(),
      );
    } finally {
      isLoading(false);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      isLoading(true);
      await _authService.resetPassword(email);
      CustomSnackbar.showSuccess(
        title: 'Success',
        message: 'Password reset email sent',
      );
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: e.toString(),
      );
    } finally {
      isLoading(false);
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      isLoading(true);
      return await _authService.getUserProfile(uid);
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: e.toString(),
      );
      return null;
    } finally {
      isLoading(false);
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      isLoading(true);
      await _authService.updateUserProfile(user);
      CustomSnackbar.showSuccess(
        title: 'Success',
        message: 'Profile updated successfully',
      );
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: e.toString(),
      );
    } finally {
      isLoading(false);
    }
  }
}