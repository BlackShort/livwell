import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:livwell/app/auth/models/user_model.dart';

class UserPreferences {
  static final _box = Hive.box('userBox');

  // Save user model with error handling
  static Future<void> setUserModel(UserModel user) async {
    try {
      String userJson = jsonEncode(user.toMap());
      await _box.put('user_model', userJson);
    } catch (e) {
      print('Error saving user model: $e');
    }
  }

  // Get user model with improved error handling
  static UserModel? getUserModel() {
    try {
      final userJson = _box.get('user_model');
      if (userJson == null) return null;

      Map<String, dynamic> userMap = jsonDecode(userJson);
      return UserModel.fromMap(userMap);
    } catch (e) {
      print('Error getting user model: $e');
      return null;
    }
  }

  static Future<void> setUserId(String userId) async {
    await _box.put('user_id', userId);
  }

  static String? getUserId() {
    return _box.get('user_id');
  }

  static Future<void> clearUserData() async {
    await _box.delete('user_model');
    await _box.delete('user_id');
  }
}
