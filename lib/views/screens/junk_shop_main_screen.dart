import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JunkShopMainScreen extends StatelessWidget {
  final dynamic junkShopData;

  const JunkShopMainScreen({super.key, this.junkShopData});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          junkShopData['junkShopName'],
          style: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: screenHeight * 0.24,
            width: screenWidth,
            child: CachedNetworkImage(
              imageUrl: junkShopData['junkShopImage'],
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              // clipBehavior: Clip.antiAlias,
              color: Color(0xfffe7800),
              height: screenHeight * 0.2,
              width: screenWidth,
              child: Text("Available balance here"),
            ),
          ),
        ],
      ),
    );
  }
}
