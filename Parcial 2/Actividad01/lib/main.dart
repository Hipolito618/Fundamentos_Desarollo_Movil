import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_colors.dart';
import 'screens/inicio_screen.dart';

void main() {
  runApp(const BreakPointApp());
}

class BreakPointApp extends StatelessWidget {
  const BreakPointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BREAK POINT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundNeutral,
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      ),
      home: const InicioScreen(),
    );
  }
}
