import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales
  static const Color primaryColor = Color(0xFF5C6BC0); // Indigo
  static const Color secondaryColor = Color(0xFFF5F5F5); // Gris très clair
  static const Color accentColor = Color(0xFF26A69A); // Vert-bleu
  static const Color backgroundColor = Colors.white; // Fond blanc
  static const Color errorColor = Colors.red; // Couleur d'erreur
  
  // Couleurs texte
  static const Color darkTextColor = Color(0xFF212121); // Presque noir
  static const Color lightTextColor = Color(0xFF757575); // Gris
  
  // Styles de texte
  static final TextStyle titleTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: darkTextColor,
  );
  
  static final TextStyle subtitleTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: darkTextColor,
  );
  
  static final TextStyle bodyTextStyle = TextStyle(
    fontSize: 14,
    color: darkTextColor,
  );
  
  static final TextStyle captionTextStyle = TextStyle(
    fontSize: 12,
    color: lightTextColor,
  );
  
  // Styles requis par login_screen.dart
  static final TextStyle headingTextStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: darkTextColor,
  );
  
  static final TextStyle smallTextStyle = TextStyle(
    fontSize: 14,
    color: lightTextColor,
  );
  
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  );
  
  static InputDecoration textFieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: secondaryColor,
      labelStyle: TextStyle(color: lightTextColor),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }

  // Thème clair
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: Colors.white,
      background: secondaryColor,
      error: Colors.red,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 1,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: lightTextColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: secondaryColor,
      thickness: 1,
      indent: 16,
      endIndent: 16,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: secondaryColor,
      selectedColor: primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(color: darkTextColor),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      secondarySelectedColor: primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  );
} 