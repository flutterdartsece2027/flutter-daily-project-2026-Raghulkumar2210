import 'package:flutter/material.dart';

class AppTheme {
  // Primary palette — deep violet to indigo
  static const Color primary      = Color(0xFF6C3CE1);
  static const Color primaryLight = Color(0xFF9B72F5);
  static const Color primaryDark  = Color(0xFF4A22B8);

  // Secondary — teal
  static const Color secondary = Color(0xFF00C6AE);

  // Status colors
  static const Color success = Color(0xFF00C48C);
  static const Color error   = Color(0xFFFF5A5F);
  static const Color warning = Color(0xFFFFAA00);
  static const Color info    = Color(0xFF3ABFF8);

  // Surfaces
  static const Color surface  = Color(0xFFF4F6FD);
  static const Color cardBg   = Colors.white;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C3CE1), Color(0xFF3A7EFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF1A0533), Color(0xFF6C3CE1), Color(0xFF3A7EFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient adminGradient = LinearGradient(
    colors: [Color(0xFF0D0D2B), Color(0xFF1B1464), Color(0xFF2E0854)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient studentCardGradient = LinearGradient(
    colors: [Color(0xFF6C3CE1), Color(0xFF3A7EFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00C48C), Color(0xFF00A3C4)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFFAA00), Color(0xFFFF6B00)],
  );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: surface,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          color: cardBg,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE8ECF4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE8ECF4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: error),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          labelStyle: const TextStyle(color: Color(0xFF8A94A6)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: primary.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                  color: primary, fontSize: 12, fontWeight: FontWeight.w600);
            }
            return const TextStyle(color: Color(0xFF8A94A6), fontSize: 12);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: primary);
            }
            return const IconThemeData(color: Color(0xFF8A94A6));
          }),
        ),
      );
}
