import 'package:flutter/material.dart';

class AppTheme {
  static const Color bgColor = Color(0xFF333333);

 //untuk dark mode
  static const Color accentGold = Color(0xFFFFD700);
  //untuk light mode
  static const Color lightAccentGold = Color(0xFFB8860B);

  static const Color cardColor = Color(0xFF424242);
  static const Color textGrey = Colors.grey;
  static const Color dangerColor = Color(0xFFE57373);
  static const Color successColor = Color(0xFF81C784);

  static Color textColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  static Color primaryAccent(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? accentGold
        : lightAccentGold;
  }

  // Dark mode
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgColor,
      primaryColor: accentGold,
      cardColor: cardColor,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentGold,
        foregroundColor: bgColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: accentGold),
        titleTextStyle: TextStyle(
          color: accentGold,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  // Light mode
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      primaryColor: lightAccentGold,
      cardColor: Colors.white,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: lightAccentGold,
        foregroundColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F5F5),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: lightAccentGold),
        titleTextStyle: TextStyle(
          color: lightAccentGold,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
