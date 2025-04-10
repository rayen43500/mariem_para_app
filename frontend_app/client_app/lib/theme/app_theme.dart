import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Couleurs principales
  static const Color primaryColor = Color(0xFF5C6BC0); // Indigo plus moderne
  static const Color primaryColorLight = Color(0xFF8E99F3);
  static const Color primaryColorDark = Color(0xFF26418F);
  
  // Couleurs secondaires
  static const Color secondaryColor = Color(0xFFF5F7FF); // Fond légèrement bleuté
  static const Color accentColor = Color(0xFFFF5252);    // Rouge vif pour accent
  
  // Couleurs complémentaires
  static const Color successColor = Color(0xFF66BB6A);
  static const Color warningColor = Color(0xFFFFB74D);
  static const Color errorColor = Color(0xFFE57373);
  static const Color infoColor = Color(0xFF4FC3F7);
  
  // Couleurs de texte
  static const Color textColor = Color(0xFF212121);
  static const Color lightTextColor = Color(0xFF757575);
  static const Color ultraLightTextColor = Color(0xFFBDBDBD);
  
  // Couleurs de fond
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Colors.white;
  static const Color scaffoldBackgroundColor = Color(0xFFFAFAFA);
  
  // Couleurs de carte
  static const Color cardColor = Colors.white;
  static const Color dividerColor = Color(0xFFEEEEEE);
  
  // Statut des produits
  static const Color outOfStockColor = Color(0xFFE57373);
  static const Color lowStockColor = Color(0xFFFFB74D);
  static const Color inStockColor = Color(0xFF66BB6A);
  
  // Rayons
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  
  // Élévations
  static const double elevationSmall = 1.0;
  static const double elevationMedium = 3.0;
  static const double elevationLarge = 6.0;
  static const double elevationXLarge = 10.0;
  
  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Styles de texte
  static TextStyle get headingStyle => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
    letterSpacing: 0.2,
  );
  
  static TextStyle get subheadingStyle => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textColor,
    letterSpacing: 0.1,
  );
  
  static TextStyle get titleStyle => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textColor,
  );
  
  static TextStyle get subtitleStyle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textColor,
  );
  
  static TextStyle get bodyStyle => GoogleFonts.poppins(
    fontSize: 14,
    color: textColor,
    letterSpacing: 0.2,
  );
  
  static TextStyle get smallTextStyle => GoogleFonts.poppins(
    fontSize: 12,
    color: lightTextColor,
  );
  
  static TextStyle get captionStyle => GoogleFonts.poppins(
    fontSize: 11,
    color: lightTextColor,
    fontWeight: FontWeight.w300,
  );
  
  // Thème clair
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: const CardTheme(
        color: cardColor,
        elevation: elevationSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        buttonColor: primaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          elevation: elevationSmall,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: secondaryColor,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.poppins(
          color: lightTextColor,
          fontSize: 14,
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: headingStyle,
        headlineMedium: subheadingStyle,
        titleLarge: titleStyle,
        titleMedium: subtitleStyle,
        bodyLarge: bodyStyle,
        bodyMedium: smallTextStyle,
        bodySmall: captionStyle,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: secondaryColor,
        disabledColor: dividerColor,
        selectedColor: primaryColorLight,
        secondarySelectedColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: textColor,
        ),
        secondaryLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.white,
        ),
        brightness: Brightness.light,
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 24,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: lightTextColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
} 