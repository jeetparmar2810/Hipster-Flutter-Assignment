import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hipster_inc_assignment/utils/app_strings.dart';
import 'package:hipster_inc_assignment/utils/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

class UserRepository {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  Future<List<UserModel>> fetchUsers() async {
    Box? box;
    final String apiUrl = dotenv.env['API_URL'] ?? '';
    final String apiKey = dotenv.env['API_KEY'] ?? '';

    try {
      box = await Hive.openBox('usersBox');
      final response = await _dio.get(apiUrl,
        options: Options(
          headers: {
            'x-api-key': apiKey,
          },
        ),);
      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'Failed to load users: ${response.statusCode}',
        );
      }

      if (response.data == null || response.data['data'] == null) {
        throw Exception('Invalid API response format');
      }

      final users = (response.data['data'] as List)
          .map((e) => UserModel.fromJson(e))
          .toList();

      Logger.i('Fetched ${users.length} users from API');

      await box.clear();
      await box.addAll(users.map((e) => e.toJson()));

      Logger.i('Cached ${users.length} users in Hive');

      return users;
    } on DioException catch (e) {
      Logger.i('DioException: ${e.type}');
      Logger.i('Message: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout) {
        Logger.i('Connection timeout - Loading from cache');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        Logger.i('Receive timeout - Loading from cache');
      } else if (e.type == DioExceptionType.connectionError) {
        Logger.i('No internet connection - Loading from cache');
      } else if (e.type == DioExceptionType.badResponse) {
        Logger.i('Bad response: ${e.response?.statusCode}');
      }
      return _loadFromCache(box);
    } catch (e, stackTrace) {
      Logger.i('Unexpected error: $e');
      Logger.i('Stack trace: $stackTrace');

      return _loadFromCache(box);
    }
  }

  Future<List<UserModel>> _loadFromCache(Box? box) async {
    try {
      box ??= await Hive.openBox('usersBox');

      if (box.isEmpty) {
        Logger.i('📭 Cache is empty');
        throw Exception(AppStrings.noNetwork);
      }

      final cached = box.values.toList();
      final users = cached
          .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      Logger.i('Loaded ${users.length} users from cache');

      return users;
    } catch (e) {
      Logger.i('Failed to load from cache: $e');
      throw Exception(AppStrings.noNetwork);
    }
  }

  Future<void> clearCache() async {
    try {
      final box = await Hive.openBox('usersBox');
      await box.clear();
      Logger.i('Cache cleared');
    } catch (e) {
      Logger.i('Failed to clear cache: $e');
    }
  }

  Future<bool> hasCachedData() async {
    try {
      final box = await Hive.openBox('usersBox');
      return box.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
