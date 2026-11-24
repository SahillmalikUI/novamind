import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;
  String? lastError;

  Future<bool> isLoggedIn() async {
    return _client.auth.currentSession != null;
  }

  Future<bool> signup(String name, String email, String password) async {
    lastError = null;
    try {
      final res = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim()},
      );
      if (res.user != null) {
        return true;
      }
      lastError = 'Signup failed. Please try again.';
      return false;
    } on AuthException catch (e) {
      lastError = e.message;
      return false;
    } catch (e) {
      lastError = e.toString();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    lastError = null;
    try {
      final res = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (res.session != null) {
        return true;
      }
      lastError = 'Login failed: no session created';
      return false;
    } on AuthException catch (e) {
      lastError = e.message;
      return false;
    } catch (e) {
      lastError = e.toString();
      return false;
    }
  }

  Future<String?> getToken() async {
    return _client.auth.currentSession?.accessToken;
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
