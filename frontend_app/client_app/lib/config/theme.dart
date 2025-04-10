import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales pour parapharmacie
  static const Color primaryColor = Color(0xFF4CAF50);      // Vert médical
  static const Color accentColor = Color(0xFF42A5F5);       // Bleu apaisant
  static const Color secondaryColor = Color(0xFFF5F5F5);    // Gris très clair
  static const Color darkGreenColor = Color(0xFF2E7D32);    // Vert foncé
  static const Color lightGreenColor = Color(0xFFAED581);   // Vert clair
  static const Color errorColor = Color(0xFFE53935);        // Rouge erreur

  // Couleurs neutres
  static const Color textColor = Color(0xFF424242);         // Gris foncé pour le texte
  static const Color lightTextColor = Color(0xFF757575);    // Gris pour texte secondaire
  static const Color backgroundColor = Color(0xFFFAFAFA);   // Fond presque blanc
  static const Color cardColor = Colors.white;
  static const Color dividerColor = Color(0xFFEEEEEE);

  // Styles de texte
  static TextStyle get headingTextStyle => const TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    color: textColor,
    letterSpacing: 0.5,
  );

  static TextStyle get titleTextStyle => const TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    color: textColor,
    letterSpacing: 0.3,
  );

  static TextStyle get subtitleTextStyle => const TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    color: textColor,
  );

  static TextStyle get bodyTextStyle => const TextStyle(
    fontSize: 16.0,
    color: textColor,
  );

  static TextStyle get smallTextStyle => const TextStyle(
    fontSize: 14.0,
    color: lightTextColor,
  );

  // Style des boutons
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    elevation: 2,
  );

  // Style des champs de texte
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
      labelStyle: const TextStyle(color: lightTextColor),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }

  // Thème complet de l'application
  static ThemeData get theme => ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardTheme: const CardTheme(
      color: cardColor,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle,
    ),
    textTheme: TextTheme(
      displayLarge: headingTextStyle,
      displayMedium: titleTextStyle,
      bodyLarge: subtitleTextStyle,
      bodyMedium: bodyTextStyle,
      bodySmall: smallTextStyle,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.white,
    ),
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),
  );
} 