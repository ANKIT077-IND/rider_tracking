import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _logged = 'logged_in',
      _name = 'user_name',
      _email = 'user_email';

  static Future<bool> loggedIn() async =>
      (await SharedPreferences.getInstance()).getBool(_logged) ?? false;

  static Future<void> register(
    String name,
    String email,
    String password,
  ) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_logged, true);
    await p.setString(_name, name);
    await p.setString(_email, email);
  }

  static Future<void> login(String email, String password) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_logged, true);
    await p.setString(_email, email);
    if (!(p.getString(_name)?.isNotEmpty ?? false))
      await p.setString(_name, 'Rider');
  }

  static Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_logged, false);
  }

  static Future<String> name() async =>
      (await SharedPreferences.getInstance()).getString(_name) ?? 'Rider';

  static Future<String> email() async =>
      (await SharedPreferences.getInstance()).getString(_email) ?? '';
}
