import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile.dart';
import '../services/profile_service.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

final profileProvider = FutureProvider.autoDispose<Profile>((ref) async {
  final service = ref.read(profileServiceProvider);
  return service.getProfile();
});
