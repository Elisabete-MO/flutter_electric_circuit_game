import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressState {
  const ProgressState({
    this.completedChallenges = const {},
    this.challengeStars = const {},
  });

  final Set<String> completedChallenges;
  final Map<String, int> challengeStars;

  ProgressState copyWith({
    Set<String>? completedChallenges,
    Map<String, int>? challengeStars,
  }) {
    return ProgressState(
      completedChallenges: completedChallenges ?? this.completedChallenges,
      challengeStars: challengeStars ?? this.challengeStars,
    );
  }
}

class ProgressController extends Notifier<ProgressState> {
  static const _completedKey = 'completed_challenges';

  @override
  ProgressState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final list = prefs.getStringList(_completedKey) ?? [];
    
    final Map<String, int> stars = {};
    for (final id in list) {
      stars[id] = prefs.getInt('stars_$id') ?? 1;
    }
    
    return ProgressState(
      completedChallenges: list.toSet(),
      challengeStars: stars,
    );
  }

  Future<void> markAsCompleted(String challengeId, {int stars = 3}) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final newSet = {...state.completedChallenges, challengeId};
    await prefs.setStringList(_completedKey, newSet.toList());
    
    final currentStars = state.challengeStars[challengeId] ?? 0;
    int finalStars = currentStars;
    if (stars > currentStars) {
      await prefs.setInt('stars_$challengeId', stars);
      finalStars = stars;
    }
    
    final newStars = Map<String, int>.from(state.challengeStars);
    newStars[challengeId] = finalStars;

    state = state.copyWith(
      completedChallenges: newSet,
      challengeStars: newStars,
    );
  }

  bool isCompleted(String challengeId) {
    return state.completedChallenges.contains(challengeId);
  }

  int getStars(String challengeId) {
    return state.challengeStars[challengeId] ?? 0;
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

final progressControllerProvider = NotifierProvider<ProgressController, ProgressState>(
  ProgressController.new,
);
