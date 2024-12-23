import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:junk_shapp/views/screens/owner_main_screen.dart';

class JunkShopListItemWidget extends StatelessWidget {
  final dynamic junkShopData;

  const JunkShopListItemWidget({super.key, this.junkShopData});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final NumberFormat currencyFormatter = NumberFormat("#,##0.00");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        clipBehavior: Clip.antiAlias,
        width: screenWidth * 0.8,
        // height: screenHeight * 0.18,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.96),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: InkWell(
          
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return OwnerMainScreen(
                  junkShopData: junkShopData,
                );
              },
            ));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cached Network Image
              CachedNetworkImage(
                width: screenWidth,
                height: screenHeight * 0.12,
                imageUrl: junkShopData['junkShopImage'],
                fit: BoxFit.cover,
              ),
              SizedBox(
                height: screenHeight * 0.004,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  junkShopData['junkShopName']!,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 8),
                child: Text(
                  "Balance:₱ ${currencyFormatter.format(junkShopData['junkShopBalance'] ?? 0)}",
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
