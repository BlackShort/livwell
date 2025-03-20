import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:livwell/app/auth/models/user_model.dart';

class UserPreferences {
  static final _box = Hive.box('userBox');

  static Future<void> setUserModel(UserModel user) async {
    String userJson = jsonEncode(user.toMap());
    await _box.put('user_model', userJson);
  }

  static UserModel? getUserModel() {
    final userJson = _box.get('user_model');
    if (userJson == null) return null;

    try {
      Map<String, dynamic> userMap = jsonDecode(userJson);
      return UserModel.fromMap(userMap);
    } catch (e) {
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
