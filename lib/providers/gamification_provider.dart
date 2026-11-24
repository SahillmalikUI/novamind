import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GamificationState {
  final int xp;
  final int streakDays;
  final int focusMinutesTotal;
  final List<String> unlockedBadges;
  final bool hasCalibrated;

  const GamificationState({
    required this.xp,
    required this.streakDays,
    required this.focusMinutesTotal,
    required this.unlockedBadges,
    this.hasCalibrated = false,
  });

  int get level => (xp / 200).floor() + 1;
  int get currentLevelXp => xp % 200;
  int get nextLevelXp => 200;
  double get levelProgress => (currentLevelXp / nextLevelXp).clamp(0.0, 1.0);

  String get rankTitle {
    switch (level) {
      case 1:
        return 'Neural Initiate';
      case 2:
        return 'Cyber Apprentice';
      case 3:
        return 'Synapse Runner';
      case 4:
        return 'Quantum Architect';
      default:
        return 'Cognitive Polymath 💎';
    }
  }

  GamificationState copyWith({
    int? xp,
    int? streakDays,
    int? focusMinutesTotal,
    List<String>? unlockedBadges,
    bool? hasCalibrated,
  }) {
    return GamificationState(
      xp: xp ?? this.xp,
      streakDays: streakDays ?? this.streakDays,
      focusMinutesTotal: focusMinutesTotal ?? this.focusMinutesTotal,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      hasCalibrated: hasCalibrated ?? this.hasCalibrated,
    );
  }
}

class GamificationNotifier extends StateNotifier<GamificationState> {
  static const _storage = FlutterSecureStorage();

  GamificationNotifier()
      : super(const GamificationState(
          xp: 250,
          streakDays: 1,
          focusMinutesTotal: 25,
          unlockedBadges: ['neural_initiate', 'speed_demon'],
          hasCalibrated: false,
        )) {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final rawXp = await _storage.read(key: 'user_xp');
      final rawStreak = await _storage.read(key: 'user_streak');
      final rawFocus = await _storage.read(key: 'user_focus_mins');
      final rawBadges = await _storage.read(key: 'user_badges');
      final rawCalibrated = await _storage.read(key: 'user_calibrated');

      final badges = rawBadges != null && rawBadges.isNotEmpty
          ? rawBadges.split(',').where((b) => b.isNotEmpty).toList()
          : state.unlockedBadges;

      state = state.copyWith(
        xp: int.tryParse(rawXp ?? '') ?? state.xp,
        streakDays: int.tryParse(rawStreak ?? '') ?? state.streakDays,
        focusMinutesTotal:
            int.tryParse(rawFocus ?? '') ?? state.focusMinutesTotal,
        unlockedBadges: badges,
        hasCalibrated: rawCalibrated == 'true',
      );
    } catch (_) {}
  }

  Future<void> addXp(int amount) async {
    final newXp = state.xp + amount;
    state = state.copyWith(xp: newXp);
    await _storage.write(key: 'user_xp', value: newXp.toString());
  }

  Future<void> addFocusSession(int minutes) async {
    final newTotal = state.focusMinutesTotal + minutes;
    final earnedXp = minutes * 2;
    final newXp = state.xp + earnedXp;

    final badges = List<String>.from(state.unlockedBadges);
    if (!badges.contains('deep_diver')) {
      badges.add('deep_diver');
      await _storage.write(key: 'user_badges', value: badges.join(','));
    }

    state = state.copyWith(
      focusMinutesTotal: newTotal,
      xp: newXp,
      unlockedBadges: badges,
    );

    await _storage.write(key: 'user_focus_mins', value: newTotal.toString());
    await _storage.write(key: 'user_xp', value: newXp.toString());
  }

  Future<void> unlockBadge(String badgeId) async {
    if (!state.unlockedBadges.contains(badgeId)) {
      final updated = [...state.unlockedBadges, badgeId];
      state = state.copyWith(unlockedBadges: updated);
      await _storage.write(key: 'user_badges', value: updated.join(','));
    }
  }

  Future<void> completeCalibration({
    required String goal,
    required int focusMinutes,
  }) async {
    final newXp = state.xp + 100;
    final badges = List<String>.from(state.unlockedBadges);
    if (!badges.contains('neural_initiate')) {
      badges.add('neural_initiate');
    }

    state = state.copyWith(
      xp: newXp,
      hasCalibrated: true,
      unlockedBadges: badges,
    );

    await _storage.write(key: 'user_xp', value: newXp.toString());
    await _storage.write(key: 'user_calibrated', value: 'true');
    await _storage.write(key: 'user_badges', value: badges.join(','));
    await _storage.write(key: 'user_goal', value: goal);
    await _storage.write(key: 'user_target_focus', value: focusMinutes.toString());
  }
}

final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
  return GamificationNotifier();
});
