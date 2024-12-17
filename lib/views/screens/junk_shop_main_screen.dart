import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class JunkShopMainScreen extends StatelessWidget {
  final dynamic junkShopData;

  JunkShopMainScreen({super.key, this.junkShopData});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final NumberFormat currencyFormatter = NumberFormat("#,##0.00");
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.96),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(0xffff6600),
        centerTitle: true,
        title: Text(
          junkShopData['junkShopName'],
          style: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('junk_shops')
            .doc(junkShopData['junkShopId'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text("No data available"),
            );
          }
          final junkShopData = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // IMAGE
              SizedBox(
                height: screenHeight * 0.24,
                width: screenWidth,
                child: CachedNetworkImage(
                  imageUrl: junkShopData['junkShopImage'],
                  fit: BoxFit.cover,
                ),
              ),

              // JUNK SHOP BALANCE
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 12,
                  ),
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: Color(0xffff6600),
                    ),
                    width: screenWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize
                          .min, // Important: constrains the column's height
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 16.0,
                            left: 16,
                          ),
                          child: Text(
                            "AVAILABLE BALANCE:",
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              color: Colors.white,
                              letterSpacing: 2.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Text(
                                    "₱ ${currencyFormatter.format(junkShopData['junkShopBalance'] ?? 0)}",
                                    style: GoogleFonts.quicksand(
                                      fontSize: 28,
                                      color: Colors.white,
                                      letterSpacing: 0.1,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Container(
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text(
                                        "+  Add Funds",
                                        style: GoogleFonts.quicksand(
                                          color: const Color(0xffff6600),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Adjust the image container
                        // SizedBox(
                        //   // aspectRatio: 16 / 8, // Adjust as needed
                        //   height: screenHeight * 0.2,
                        //   child: CachedNetworkImage(
                        //     imageUrl: junkShopData['junkShopImage'],
                        //     fit: BoxFit.cover,
                        //     width: screenWidth,
                        //   ),
                        // ),

                        // BUTTONS
                      ],
                    ),
                  ),
                ),
              ),

              // SERVICES
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  // clipBehavior: Clip.hardEdge,
                  height: screenHeight * 0.3,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    color: Colors.white,
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
