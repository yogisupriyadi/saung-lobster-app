import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'state/data_saung_lobster.dart';
import 'widgets/komponen_ui.dart';

void main() {
  runApp(const SaungLobsterApp());
}

class SaungLobsterApp extends StatelessWidget {
  const SaungLobsterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DataSaungLobster.instance,
      builder: (context, _) {
        final isDark = DataSaungLobster.instance.isDarkMode;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SaungLobster',
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          home: const LoginPage(),
        );
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: merah,
        brightness: brightness,
        primary: merah,
        surface: dark ? const Color(0xFF1A0D10) : Colors.white,
      ),
      scaffoldBackgroundColor: dark ? latarGelap : latarTerang,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: dark ? Colors.white : const Color(0xFF1F1215),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: dark ? const Color(0xFF1E0E11) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: dark
                ? Colors.white.withValues(alpha: 0.18)
                : merah.withValues(alpha: 0.18),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: dark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.8),
        selectedColor: merah.withValues(alpha: dark ? 0.35 : 0.18),
        side: BorderSide(
          color: dark
              ? Colors.white.withValues(alpha: 0.18)
              : merah.withValues(alpha: 0.22),
        ),
        labelStyle: TextStyle(
          color: dark ? Colors.white : const Color(0xFF1F1215),
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? const Color(0xFF281216) : const Color(0xFF2B1317),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
      ),
    );
  }
}