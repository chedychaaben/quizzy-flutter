// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void toggleDarkMode(bool value) {
    state = state.copyWith(isDarkMode: value);
  }

  void toggleSound(bool value) {
    state = state.copyWith(soundEnabled: value);
  }

  void toggleNotifications(bool value) {
    state = state.copyWith(notificationsEnabled: value);
  }

  void setLocale(Locale locale) {
    state = state.copyWith(locale: locale);
  }
}

@immutable
class SettingsState {
  final bool isDarkMode;
  final bool soundEnabled;
  final bool notificationsEnabled;
  final Locale locale;

  const SettingsState({
    this.isDarkMode = false,
    this.soundEnabled = true,
    this.notificationsEnabled = true,
    this.locale = const Locale('en'),
  });

  SettingsState copyWith({
    bool? isDarkMode,
    bool? soundEnabled,
    bool? notificationsEnabled,
    Locale? locale,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      locale: locale ?? this.locale,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);