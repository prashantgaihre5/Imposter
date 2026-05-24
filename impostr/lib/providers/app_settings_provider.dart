import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final bool vibrationEnabled;
  final bool animationsEnabled;
  final bool lowPerformanceMode;
  final bool adsEnabled;
  final bool personalizedAds;

  const AppSettings({
    this.vibrationEnabled = true,
    this.animationsEnabled = true,
    this.lowPerformanceMode = false,
    this.adsEnabled = false,
    this.personalizedAds = false,
  });

  AppSettings copyWith({
    bool? vibrationEnabled,
    bool? animationsEnabled,
    bool? lowPerformanceMode,
    bool? adsEnabled,
    bool? personalizedAds,
  }) {
    return AppSettings(
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      lowPerformanceMode: lowPerformanceMode ?? this.lowPerformanceMode,
      adsEnabled: adsEnabled ?? this.adsEnabled,
      personalizedAds: personalizedAds ?? this.personalizedAds,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  static const _vibrationKey = 'settings_vibration_enabled';
  static const _animationsKey = 'settings_animations_enabled';
  static const _lowPerformanceKey = 'settings_low_performance_mode';
  static const _adsKey = 'settings_ads_enabled';
  static const _personalizedAdsKey = 'settings_personalized_ads';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      vibrationEnabled: prefs.getBool(_vibrationKey) ?? true,
      animationsEnabled: prefs.getBool(_animationsKey) ?? true,
      lowPerformanceMode: prefs.getBool(_lowPerformanceKey) ?? false,
      adsEnabled: prefs.getBool(_adsKey) ?? false,
      personalizedAds: prefs.getBool(_personalizedAdsKey) ?? false,
    );
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> setVibrationEnabled(bool value) async {
    state = state.copyWith(vibrationEnabled: value);
    await _save(_vibrationKey, value);
  }

  Future<void> setAnimationsEnabled(bool value) async {
    state = state.copyWith(animationsEnabled: value);
    await _save(_animationsKey, value);
  }

  Future<void> setLowPerformanceMode(bool value) async {
    state = state.copyWith(lowPerformanceMode: value);
    await _save(_lowPerformanceKey, value);
  }

  Future<void> setAdsEnabled(bool value) async {
    state = state.copyWith(adsEnabled: value);
    await _save(_adsKey, value);
  }

  Future<void> setPersonalizedAds(bool value) async {
    state = state.copyWith(personalizedAds: value);
    await _save(_personalizedAdsKey, value);
  }
}

final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});
