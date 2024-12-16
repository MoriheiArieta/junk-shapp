import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NonOwnerHomeScreen extends StatelessWidget {
  const NonOwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: Text(
          'Non Owner Screen',
          style: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
