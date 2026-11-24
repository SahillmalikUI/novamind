import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Profile> getProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in');
    }

    final metadata = user.userMetadata ?? {};
    final name = (metadata['name'] as String?)?.trim() ?? '';
    final email = user.email ?? '';
    final createdAt = user.createdAt;

    return Profile(
      id: user.id,
      name: name.isNotEmpty ? name : email.split('@').first,
      email: email,
      createdAt: createdAt,
    );
  }

  /// Update display name and/or email
  Future<Profile> updateProfile({String? name, String? email}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final hasName = name != null && name.trim().isNotEmpty;
    final hasEmail = email != null && email.trim().isNotEmpty;

    if (!hasName && !hasEmail) {
      return getProfile();
    }

    final attrs = UserAttributes(
      email: hasEmail ? email.trim() : null,
      data: hasName ? {'name': name.trim()} : null,
    );

    final res = await _client.auth.updateUser(attrs);
    if (res.user == null) {
      throw Exception('Failed to update profile');
    }

    return getProfile();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    if (newPassword.length < 6) {
      throw Exception('New password must be at least 6 characters');
    }

    // Supabase allows authenticated user to update their password
    final res = await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );

    if (res.user == null) {
      throw Exception('Could not change your password');
    }
  }
}
