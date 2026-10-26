import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Settings keys
class SettingsKeys {
  static const String theme = 'theme';
  static const String fontSize = 'font_size';
  static const String fontFamily = 'font_family';
  static const String useDarkMode = 'use_dark_mode';
  static const String accentColor = 'accent_color';
  static const String lineHeight = 'line_height';
}

// Theme mode enum
enum ThemeMode {
  system,
  light,
  dark,
}

// Font family enum
enum FontFamily {
  merriweather,
  inter,
  system,
}

// Settings model
class AppSettings {
  final ThemeMode themeMode;
  final double fontSize;
  final FontFamily fontFamily;
  final bool useDarkMode;
  final Color accentColor;
  final double lineHeight;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.fontSize = 17,
    this.fontFamily = FontFamily.merriweather,
    this.useDarkMode = false,
    this.accentColor = const Color(0xFF292929),
    this.lineHeight = 1.65,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? fontSize,
    FontFamily? fontFamily,
    bool? useDarkMode,
    Color? accentColor,
    double? lineHeight,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      useDarkMode: useDarkMode ?? this.useDarkMode,
      accentColor: accentColor ?? this.accentColor,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      SettingsKeys.theme: themeMode.index,
      SettingsKeys.fontSize: fontSize,
      SettingsKeys.fontFamily: fontFamily.index,
      SettingsKeys.useDarkMode: useDarkMode,
      SettingsKeys.accentColor: accentColor.value,
      SettingsKeys.lineHeight: lineHeight,
    };
  }

  // Create from map
  static AppSettings fromMap(Map<String, dynamic> map) {
    return AppSettings(
      themeMode: ThemeMode.values[map[SettingsKeys.theme] as int? ?? 0],
      fontSize: map[SettingsKeys.fontSize] as double? ?? 17,
      fontFamily: FontFamily.values[map[SettingsKeys.fontFamily] as int? ?? 0],
      useDarkMode: map[SettingsKeys.useDarkMode] as bool? ?? false,
      accentColor: Color(map[SettingsKeys.accentColor] as int? ?? 0xFF292929),
      lineHeight: map[SettingsKeys.lineHeight] as double? ?? 1.65,
    );
  }
}

// Settings repository
class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  Future<AppSettings> loadSettings() async {
    final map = _prefs.getStringMap(SettingsKeys.theme) ?? {};
    return AppSettings.fromMap(map);
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setStringMap(SettingsKeys.theme, settings.toMap());
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    final settings = await loadSettings();
    await saveSettings(settings.copyWith(themeMode: mode));
  }

  Future<void> updateFontSize(double size) async {
    final settings = await loadSettings();
    await saveSettings(settings.copyWith(fontSize: size));
  }

  Future<void> updateFontFamily(FontFamily family) async {
    final settings = await loadSettings();
    await saveSettings(settings.copyWith(fontFamily: family));
  }

  Future<void> updateUseDarkMode(bool useDark) async {
    final settings = await loadSettings();
    await saveSettings(settings.copyWith(useDarkMode: useDark));
  }

  Future<void> updateAccentColor(Color color) async {
    final settings = await loadSettings();
    await saveSettings(settings.copyWith(accentColor: color));
  }

  Future<void> updateLineHeight(double height) async {
    final settings = await loadSettings();
    await saveSettings(settings.copyWith(lineHeight: height));
  }
}

// Settings providers
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnsupportedError('SettingsRepository must be initialized with SharedPreferences');
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.read(settingsRepositoryProvider));
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const AppSettings());

  Future<void> loadSettings() async {
    try {
      final settings = await _repository.loadSettings();
      state = settings;
    } catch (e) {
      state = const AppSettings();
    }
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    await _repository.updateThemeMode(mode);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> updateFontSize(double size) async {
    await _repository.updateFontSize(size);
    state = state.copyWith(fontSize: size);
  }

  Future<void> updateFontFamily(FontFamily family) async {
    await _repository.updateFontFamily(family);
    state = state.copyWith(fontFamily: family);
  }

  Future<void> updateUseDarkMode(bool useDark) async {
    await _repository.updateUseDarkMode(useDark);
    state = state.copyWith(useDarkMode: useDark);
  }

  Future<void> updateAccentColor(Color color) async {
    await _repository.updateAccentColor(color);
    state = state.copyWith(accentColor: color);
  }

  Future<void> updateLineHeight(double height) async {
    await _repository.updateLineHeight(height);
    state = state.copyWith(lineHeight: height);
  }
}

// Theme mode provider
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider).themeMode;
});

// Font size provider
final fontSizeProvider = Provider<double>((ref) {
  return ref.watch(settingsProvider).fontSize;
});

// Font family provider
final fontFamilyProvider = Provider<FontFamily>((ref) {
  return ref.watch(settingsProvider).fontFamily;
});

// Use dark mode provider
final useDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).useDarkMode;
});

// Line height provider
final lineHeightProvider = Provider<double>((ref) {
  return ref.watch(settingsProvider).lineHeight;
});

// Accent color provider
final accentColorProvider = Provider<Color>((ref) {
  return ref.watch(settingsProvider).accentColor;
});
