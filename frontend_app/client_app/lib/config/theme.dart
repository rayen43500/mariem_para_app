import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales
  static const Color primaryColor = Color(0xFF4CAF50);     // Vert pharmacie
  static const Color secondaryColor = Color(0xFFF5F7FA);   // Gris très clair
  static const Color accentColor = Color(0xFF2196F3);      // Bleu médical
  static const Color backgroundColor = Color(0xFFFFFFFF);  // Fond blanc
  static const Color cardColor = Color(0xFFFFFFFF);        // Cartes blanches
  
  // Couleurs de texte
  static const Color darkTextColor = Color(0xFF1E293B);    // Texte foncé
  static const Color lightTextColor = Color(0xFF64748B);   // Texte secondaire
  static const Color whiteTextColor = Color(0xFFFFFFFF);   // Texte blanc
  
  // Couleurs d'état
  static const Color successColor = Color(0xFF22C55E);     // Vert succès
  static const Color errorColor = Color(0xFFEF4444);       // Rouge erreur
  static const Color warningColor = Color(0xFFF59E0B);     // Orange avertissement
  static const Color infoColor = Color(0xFF3B82F6);        // Bleu information

  // Polices et tailles
  static const double fontSizeSmall = 12.0;
  static const double fontSizeNormal = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 24.0;
  static const double fontSizeXXLarge = 32.0;

  // Rayons d'arrondi
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Thème clair
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      background: backgroundColor,
      surface: cardColor,
      error: errorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: whiteTextColor,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: whiteTextColor,
        fontSize: fontSizeLarge,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: whiteTextColor,
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: const TextStyle(
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
        ),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: fontSizeNormal,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: const TextStyle(
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: fontSizeXXLarge,
        fontWeight: FontWeight.bold,
        color: darkTextColor,
      ),
      displayMedium: TextStyle(
        fontSize: fontSizeXLarge,
        fontWeight: FontWeight.bold,
        color: darkTextColor,
      ),
      titleLarge: TextStyle(
        fontSize: fontSizeLarge,
        fontWeight: FontWeight.bold,
        color: darkTextColor,
      ),
      titleMedium: TextStyle(
        fontSize: fontSizeMedium,
        fontWeight: FontWeight.w600,
        color: darkTextColor,
      ),
      bodyLarge: TextStyle(
        fontSize: fontSizeMedium,
        fontWeight: FontWeight.normal,
        color: darkTextColor,
      ),
      bodyMedium: TextStyle(
        fontSize: fontSizeNormal,
        color: darkTextColor,
      ),
      bodySmall: TextStyle(
        fontSize: fontSizeSmall,
        color: lightTextColor,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: secondaryColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      labelStyle: const TextStyle(color: lightTextColor),
      hintStyle: const TextStyle(color: lightTextColor),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: lightTextColor,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  // Styles de texte constants
  static const TextStyle headingTextStyle = TextStyle(
    fontSize: fontSizeXLarge,
    fontWeight: FontWeight.bold,
    color: darkTextColor,
  );

  static const TextStyle titleTextStyle = TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.bold,
    color: darkTextColor,
  );

  static const TextStyle subtitleTextStyle = TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.w600,
    color: darkTextColor,
  );

  static const TextStyle smallTextStyle = TextStyle(
    fontSize: fontSizeSmall,
    color: lightTextColor,
  );

  static const buttonTextStyle = TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.w600,
    color: whiteTextColor,
  );

  // Décoration pour les champs de texte
  static InputDecoration textFieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: secondaryColor,
      labelStyle: const TextStyle(color: lightTextColor),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }

  // Style pour les boutons primaires
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: whiteTextColor,
    backgroundColor: primaryColor,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    textStyle: buttonTextStyle,
    elevation: 0,
  );

  // Style pour les boutons secondaires
  static final ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: const BorderSide(color: primaryColor, width: 1.5),
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    textStyle: buttonTextStyle.copyWith(color: primaryColor),
  );

  // Décoration pour les containers arrondis
  static BoxDecoration roundedBoxDecoration({Color? color, double? radius}) {
    return BoxDecoration(
      color: color ?? cardColor,
      borderRadius: BorderRadius.circular(radius ?? radiusMedium),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
} 