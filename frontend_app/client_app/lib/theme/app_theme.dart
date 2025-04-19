import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Nouvelle palette de couleurs pour parapharmacie
  static const Color primaryColor = Color(0xFF1E88E5);     // Bleu médical/pharma
  static const Color primaryColorLight = Color(0xFF64B5F6); // Bleu clair
  static const Color primaryColorDark = Color(0xFF0D47A1);  // Bleu foncé
  
  // Vert médical/pharmacie comme accent
  static const Color accentColor = Color(0xFF26A69A);       // Vert turquoise médical
  static const Color accentColorLight = Color(0xFF80CBC4);  // Vert clair
  
  // Couleurs secondaires
  static const Color secondaryColor = Color(0xFFF5F9FF);    // Fond légèrement bleuté
  
  // Couleurs complémentaires
  static const Color successColor = Color(0xFF66BB6A);      // Vert
  static const Color warningColor = Color(0xFFFFB74D);      // Orange
  static const Color errorColor = Color(0xFFEF5350);        // Rouge atténué
  static const Color infoColor = Color(0xFF42A5F5);         // Bleu info
  
  // Couleurs de texte
  static const Color textColor = Color(0xFF263238);         // Bleu-gris très foncé
  static const Color lightTextColor = Color(0xFF607D8B);    // Bleu-gris
  static const Color ultraLightTextColor = Color(0xFFB0BEC5); // Bleu-gris clair
  
  // Couleurs de fond
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Colors.white;
  static const Color scaffoldBackgroundColor = Color(0xFFF8FAFD); // Gris très légèrement bleuté
  
  // Couleurs de carte
  static const Color cardColor = Colors.white;
  static const Color dividerColor = Color(0xFFECEFF1);      // Bleu-gris très clair
  
  // Statut des produits
  static const Color outOfStockColor = Color(0xFFEF5350);   // Rouge atténué
  static const Color lowStockColor = Color(0xFFFFB74D);     // Orange
  static const Color inStockColor = Color(0xFF66BB6A);      // Vert
  
  // Nouvelles couleurs pour catégories
  static const Color categoryBlue = Color(0xFF42A5F5);      // Bleu
  static const Color categoryGreen = Color(0xFF66BB6A);     // Vert
  static const Color categoryPurple = Color(0xFF9575CD);    // Violet
  static const Color categoryOrange = Color(0xFFFFB74D);    // Orange
  static const Color categoryRed = Color(0xFFEF5350);       // Rouge
  static const Color categoryTeal = Color(0xFF26A69A);      // Turquoise
  static const Color categoryPink = Color(0xFFF06292);      // Rose
  static const Color categoryIndigo = Color(0xFF5C6BC0);    // Indigo
  
  // Rayons
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 20.0;
  
  // Élévations
  static const double elevationSmall = 1.0;
  static const double elevationMedium = 2.0;
  static const double elevationLarge = 4.0;
  static const double elevationXLarge = 8.0;
  
  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Styles de texte améliorés
  static TextStyle get headingStyle => GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
    letterSpacing: 0.3,
  );
  
  static TextStyle get subheadingStyle => GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textColor,
    letterSpacing: 0.2,
  );
  
  static TextStyle get titleStyle => GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textColor,
    letterSpacing: 0.1,
  );
  
  static TextStyle get subtitleStyle => GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textColor,
  );
  
  static TextStyle get bodyStyle => GoogleFonts.nunito(
    fontSize: 15,
    color: textColor,
    letterSpacing: 0.2,
  );
  
  static TextStyle get smallTextStyle => GoogleFonts.nunito(
    fontSize: 13,
    color: lightTextColor,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle get captionStyle => GoogleFonts.nunito(
    fontSize: 12,
    color: lightTextColor,
    fontWeight: FontWeight.w400,
  );
  
  // Décoration pour les champs de texte
  static InputDecoration textFieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: secondaryColor,
      labelStyle: GoogleFonts.nunito(
        color: lightTextColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
  
  // Style pour les boutons primaires
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: primaryColor,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    textStyle: GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
    elevation: 2,
    shadowColor: primaryColor.withOpacity(0.4),
  );
  
  // Thème clair amélioré
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
        centerTitle: false,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: elevationSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        shadowColor: Colors.black.withOpacity(0.05),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          elevation: elevationSmall,
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          shadowColor: primaryColor.withOpacity(0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.nunito(
          color: lightTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelStyle: GoogleFonts.nunito(
          color: lightTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
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
        labelStyle: GoogleFonts.nunito(
          fontSize: 13,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: GoogleFonts.nunito(
          fontSize: 13,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        brightness: Brightness.light,
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 24,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: lightTextColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      iconTheme: const IconThemeData(
        color: lightTextColor,
        size: 24,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        circularTrackColor: secondaryColor,
      ),
    );
  }
} 