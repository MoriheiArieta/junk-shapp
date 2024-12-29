import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:junk_shapp/views/screens/authentication_screens/login_screen.dart';
import 'package:junk_shapp/views/screens/buy_items.dart';
import 'package:junk_shapp/views/screens/owner_screens/add_inventory_entry.dart';
import 'package:junk_shapp/views/screens/pay_personnel.dart';
import 'package:junk_shapp/views/screens/sell_items.dart';

class NonOwnerHomeScreen extends StatefulWidget {
  final dynamic junkShopData;

  const NonOwnerHomeScreen({super.key, this.junkShopData});

  @override
  State<NonOwnerHomeScreen> createState() => _NonOwnerHomeScreenState();
}

class _NonOwnerHomeScreenState extends State<NonOwnerHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout Confirmation',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.quicksand(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.quicksand(
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: Text(
              'Logout',
              style: GoogleFonts.quicksand(
                color: const Color(0xffff6600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final NumberFormat currencyFormatter = NumberFormat("#,##0.00");
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.96),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () {
            setState(() {
              _showLogoutConfirmationDialog(context);
            });
          },
          child: const Icon(
            Icons.logout,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: const Color(0xffff6600),
        centerTitle: true,
        title: Text(
          widget.junkShopData['junkShopName'],
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('junk_shops')
            .doc(widget.junkShopData['junkShopId'])
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
                      mainAxisSize: MainAxisSize.min,
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
                              fontWeight: FontWeight.w600,
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // More widgets here
              // SERVICES
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20.0,
                              horizontal: 16,
                            ),
                            child: GridView(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 8,
                              ),
                              children: [
                                // buy items
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return BuyItems(
                                            junkShopData: junkShopData,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/icons/buy_items.png',
                                        width: screenWidth * 0.12,
                                        height: screenHeight * 0.056,
                                        color: const Color(0xfffe6600),
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 4),
                                      Flexible(
                                        child: Text(
                                          "Buy Items",
                                          style: GoogleFonts.quicksand(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.deepOrange.shade900,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                //sell items
                                InkWell(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return SellItems(
                                          junkShopData: junkShopData);
                                    }));
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/icons/sell_items.png',
                                        width: screenWidth * 0.12,
                                        height: screenHeight * 0.056,
                                        color: const Color(0xfffe6600),
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 4),
                                      Flexible(
                                        child: Text(
                                          "Sell Items",
                                          style: GoogleFonts.quicksand(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.deepOrange.shade900,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // pay personnel
                                InkWell(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return PayPersonnel(
                                          junkShopData: junkShopData);
                                    }));
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/icons/pay_personnel.png',
                                        width: screenWidth * 0.12,
                                        height: screenHeight * 0.056,
                                        color: const Color(0xfffe6600),
                                        fit: BoxFit.scaleDown,
                                      ),
                                      const SizedBox(height: 4),
                                      Flexible(
                                        child: Text(
                                          "Pay Personnel",
                                          style: GoogleFonts.quicksand(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.deepOrange.shade900,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Add inventory
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return AddInventoryEntry(
                                            junkShopData: junkShopData,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/icons/add_inventory.png',
                                        width: screenWidth * 0.12,
                                        height: screenHeight * 0.056,
                                        color: const Color(0xfffe6600),
                                        fit: BoxFit.scaleDown,
                                      ),
                                      const SizedBox(height: 4),
                                      Flexible(
                                        child: Text(
                                          "Add Item Category",
                                          style: GoogleFonts.quicksand(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.deepOrange.shade900,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'More services coming soon...',
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
