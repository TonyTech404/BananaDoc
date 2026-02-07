import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Farmer-friendly color palette
  static const Color primaryGreen = Color(0xFF2E7D32);      // Darker, more professional green
  static const Color accentGreen = Color(0xFF4CAF50);       // Current primary
  static const Color lightGreen = Color(0xFFE8F5E8);        // Light background
  static const Color warmBeige = Color(0xFFF5F1E8);         // Warm, earth-tone background
  static const Color darkBrown = Color(0xFF3E2723);         // Text color, earth-like
  static const Color warningOrange = Color(0xFFFF8C00);     // For deficiency alerts
  static const Color successBlue = Color(0xFF1976D2);       // For healthy results
  
  // Status colors for different deficiencies
  static const Map<String, Color> deficiencyColors = {
    'healthy': Color(0xFF2E7D32),
    'nitrogen': Color(0xFFFF8C00),
    'phosphorus': Color(0xFF7B1FA2),
    'potassium': Color(0xFFE65100),
    'calcium': Color(0xFFD32F2F),
    'magnesium': Color(0xFFC2185B),
    'sulphur': Color(0xFFFFB300),
    'iron': Color(0xFF5D4037),
    'boron': Color(0xFF455A64),
    'manganese': Color(0xFF6A4C93),
    'zinc': Color(0xFF37474F),
  };

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.nunito().fontFamily,
    
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      primary: primaryGreen,
      secondary: accentGreen,
      surface: warmBeige,
      error: warningOrange,
    ),

    // AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    // Card theme
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
    ),

    // Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // FAB theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentGreen,
      foregroundColor: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Bottom navigation theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryGreen,
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Text themes
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: darkBrown,
      ),
      headlineMedium: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: darkBrown,
      ),
      titleLarge: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkBrown,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: darkBrown,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: darkBrown,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: darkBrown,
        height: 1.4,
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightGreen,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(style: BorderStyle.none),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: GoogleFonts.nunito(
        color: Colors.grey[600],
        fontSize: 16,
      ),
    ),
  );

  // Helper method to get deficiency color
  static Color getDeficiencyColor(String deficiencyType) {
    return deficiencyColors[deficiencyType.toLowerCase()] ?? Colors.grey;
  }

  // Helper method to get status-based colors
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'success':
        return primaryGreen;
      case 'warning':
        return warningOrange;
      case 'error':
      case 'critical':
        return Colors.red[600]!;
      default:
        return Colors.grey;
    }
  }
}