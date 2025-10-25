import '../utils/app_strings.dart';

class AuthRepository {
  Future<bool> login(String email, String password) async {
    await Future.delayed(Duration(milliseconds: AppStrings.loginDelayMs));
    return email == AppStrings.testEmail && password == AppStrings.testPassword;
  }
}