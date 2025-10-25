import 'package:dio/dio.dart';
import 'package:hipster_inc_assignment/utils/app_strings.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class UserRepository {
  final Dio _dio = Dio();

  Future<List<UserModel>> fetchUsers() async {
    final box = await Hive.openBox('usersBox');
    try {
      final response = await _dio.get(AppConstants.apiUrl);
      final users = (response.data['data'] as List)
          .map((e) => UserModel.fromJson(e))
          .toList();
      await box.clear();
      await box.addAll(users.map((e) => e.toJson()));
      return users;
    } catch (_) {
      if (box.isNotEmpty) {
        final cached = box.values.toList();
        return cached
            .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        throw Exception(AppStrings.noNetwork);
      }
    }
  }
}
