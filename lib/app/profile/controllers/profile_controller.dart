import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:livwell/app/auth/models/user_model.dart';
import 'package:livwell/config/routes/route_names.dart';
import 'package:livwell/core/errors/custom_snackbar.dart';
import 'package:livwell/core/utils/user_preferences.dart';

class ProfileController extends GetxController {
  static ProfileController instance = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late Rx<User?> firebaseUser;
  Rxn<UserModel> userModel = Rxn<UserModel>();
  RxBool isLoading = false.obs;
  var verificationId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.userChanges());
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      final userId = _auth.currentUser?.uid ?? UserPreferences.getUserId();
      if (userId == null) return;
      final docSnapshot =
          await _firestore.collection('users').doc('user1').get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        userModel.value = UserModel.fromMap(docSnapshot.data()!);
        await UserPreferences.setUserModel(userModel.value!);
      }
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to fetch user profile: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createUserProfile(UserModel user) async {
    try {
      isLoading.value = true;
      String uid = _auth.currentUser!.uid;
      final docSnapshot = await _firestore.collection('users').doc(uid).get();

      if (!docSnapshot.exists) {
        await _firestore.collection('users').doc(uid).set(user.toMap());
        userModel.value = user;
        await UserPreferences.setUserModel(user);
        await UserPreferences.setUserId(uid);
        CustomSnackbar.showSuccess(
          title: 'Success',
          message: 'Profile created successfully',
        );
        Get.offAllNamed(AppRoute.base);
      } else {
        CustomSnackbar.showError(
          title: 'Error',
          message: 'Profile already exists',
        );
      }
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to create user profile',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserProfile(
    UserModel user, {
    String? newPhoneNumber,
  }) async {
    try {
      isLoading.value = true;
      final uid = _auth.currentUser!.uid;
      if (newPhoneNumber != null) {
        await _auth.verifyPhoneNumber(
          phoneNumber: newPhoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.currentUser!.updatePhoneNumber(credential);
            await _firestore.collection('users').doc(uid).update(user.toMap());
            userModel.value = user;
            await fetchUserProfile();
            Get.back();
            CustomSnackbar.showSuccess(
              title: 'Success',
              message: 'Profile updated successfully',
            );
          },
          verificationFailed: (e) {
            CustomSnackbar.showError(
              title: 'Error',
              message: 'Phone verification failed: ${e.message}',
            );
          },
          codeSent: (vId, _) {
            verificationId.value = vId;
          },
          codeAutoRetrievalTimeout: (vId) {
            verificationId.value = vId;
          },
        );
      } else {
        await _firestore.collection('users').doc(uid).update(user.toMap());
        userModel.value = user;
        await fetchUserProfile();
        Get.back();
        CustomSnackbar.showSuccess(
          title: 'Success',
          message: 'Profile updated successfully',
        );
      }
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to update user profile',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePhoneNumberWithOtp(String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: smsCode,
      );
      await _auth.currentUser!.updatePhoneNumber(credential);
      await fetchUserProfile();
      CustomSnackbar.showSuccess(
        title: 'Success',
        message: 'Phone number updated successfully',
      );
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to update phone number',
      );
    }
  }

  Future<void> verifyOtp(String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      Get.offAllNamed(AppRoute.base);
    } catch (e) {
      CustomSnackbar.showError(title: 'Error', message: 'Invalid OTP');
    }
  }

  Future<String?> updateProfilePhoto(String imagePath) async {
    try {
      isLoading.value = true;
      final uid = _auth.currentUser!.uid;
      final file = File(imagePath);
      final uploadTask = await _storage
          .ref('profile_photos/$uid.jpg')
          .putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      await _firestore.collection('users').doc(uid).update({
        'photoUrl': downloadUrl,
      });
      if (userModel.value != null) {
        userModel.value = userModel.value!.copyWith(photoUrl: downloadUrl);
        await UserPreferences.setUserModel(userModel.value!);
      }
      return downloadUrl;
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to upload profile photo',
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<String>> fetchDummyAvatars() async {
    try {
      final result =
          await _storage.ref('app_data/placeholder_avatar').listAll();
      return await Future.wait(result.items.map((ref) => ref.getDownloadURL()));
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to fetch dummy avatars',
      );
      return [];
    }
  }
}
