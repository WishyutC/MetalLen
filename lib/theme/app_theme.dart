import 'package:flutter/material.dart';

import 'app_tokens.dart';

abstract final class AppTheme {
  static ThemeData get light => _theme(Brightness.light);
  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background =
        isDark ? AppTokens.darkBackground : AppTokens.lightBackground;
    final text = isDark ? AppTokens.darkText : AppTokens.lightText;
    final muted = isDark ? AppTokens.darkMuted : AppTokens.lightMuted;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppTokens.accent,
      brightness: brightness,
      surface: background,
    ).copyWith(
      primary: AppTokens.accent,
      onPrimary: AppTokens.accentContent,
      surface: background,
      onSurface: text,
      error: AppTokens.defect,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'sans-serif',
      textTheme: ThemeData(
        brightness: brightness,
      ).textTheme.apply(bodyColor: text, displayColor: text),
      dividerColor: muted.withValues(alpha: .25),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? const Color(0xFF252B2F) : const Color(0xFFF3F5F6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLarge),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF252B2F) : const Color(0xFFF3F5F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMedium),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppTokens.accent,
        thumbColor: AppTokens.accent,
        overlayColor: AppTokens.accent.withValues(alpha: .15),
      ),
    );
  }
}
