import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingState {
  final bool isCompleted;
  final bool hasChosenMetro;

  OnboardingState({
    required this.isCompleted,
    required this.hasChosenMetro,
  });

  factory OnboardingState.initial() {
    return OnboardingState(
      isCompleted: false,
      hasChosenMetro: false,
    );
  }
}

class OnboardingStateNotifier extends StateNotifier<OnboardingState> {
  OnboardingStateNotifier() : super(OnboardingState.initial()) {
    _loadOnboardingState();
  }

  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyMetroChosen = 'metro_chosen';

  Future<void> _loadOnboardingState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isCompleted = prefs.getBool(_keyOnboardingCompleted) ?? false;
      final hasChosenMetro = prefs.getBool(_keyMetroChosen) ?? false;

      state = OnboardingState(
        isCompleted: isCompleted,
        hasChosenMetro: hasChosenMetro,
      );
    } catch (e) {
      // If error, assume onboarding not completed
      state = OnboardingState.initial();
    }
  }

  Future<void> markOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyOnboardingCompleted, true);

      state = OnboardingState(
        isCompleted: true,
        hasChosenMetro: state.hasChosenMetro,
      );
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> markMetroChosen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyMetroChosen, true);

      state = OnboardingState(
        isCompleted: state.isCompleted,
        hasChosenMetro: true,
      );
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyOnboardingCompleted);
      await prefs.remove(_keyMetroChosen);

      state = OnboardingState.initial();
    } catch (e) {
      // Handle error silently
    }
  }
}

final onboardingStateProvider =
    StateNotifierProvider<OnboardingStateNotifier, OnboardingState>((ref) {
  return OnboardingStateNotifier();
});
