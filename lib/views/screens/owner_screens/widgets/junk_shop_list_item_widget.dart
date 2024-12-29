import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:junk_shapp/controllers/junk_shop_controller.dart';
import 'package:junk_shapp/views/screens/owner_main_screen.dart';

class JunkShopListItemWidget extends StatefulWidget {
  final dynamic junkShopData;
  final dynamic userData;

  const JunkShopListItemWidget({super.key, this.junkShopData, this.userData});

  @override
  State<JunkShopListItemWidget> createState() => _JunkShopListItemWidgetState();
}

class _JunkShopListItemWidgetState extends State<JunkShopListItemWidget> {
  // const JunkShopListItemWidget({super.key, this.junkShopData});
  _showPassSnackBar() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Junk Shop deleted successfully',
            style: GoogleFonts.quicksand(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  _showFailedSnackBar() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete Junk Shop',
            style: GoogleFonts.quicksand(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final JunkShopController _junkShopController = JunkShopController();
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
                  junkShopData: widget.junkShopData,
                  userData: widget.userData,
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
                imageUrl: widget.junkShopData['junkShopImage'],
                fit: BoxFit.cover,
              ),
              SizedBox(
                height: screenHeight * 0.004,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.junkShopData['junkShopName']!,
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Balance:₱ ${currencyFormatter.format(widget.junkShopData['junkShopBalance'] ?? 0)}",
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () async {
                        // Show confirmation dialog
                        bool? confirmDelete = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: const Text(
                                  'Are you sure you want to delete this junk shop? This action cannot be undone.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(false); // User cancels the action
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(true); // User confirms the action
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmDelete == true) {
                          // Remove the junk shop ID from the user's junkShops array
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.userData['uid'])
                              .update({
                            'junkShops': FieldValue.arrayRemove(
                                [widget.junkShopData['junkShopId']]),
                          });
                          //delete staff profile images from firebase storage
                          List<dynamic> junkShopStaff =
                              widget.junkShopData['junkShopStaff'];
                          // for (String staffId in junkShopStaff) {
                          //   await FirebaseStorage.instance
                          //       .ref()
                          //       .child('profile_images/$staffId')
                          //       .delete();
                          // }

                          // delete users from the junk shop's junkShopStaff array
                          for (String staffId in junkShopStaff) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(staffId)
                                .delete();
                          }

                          // Attempt to delete the junk shop
                          String result =
                              await _junkShopController.deleteJunkShop(
                                  widget.junkShopData['junkShopId']);

                          if (result == 'pass') {
                            _showPassSnackBar();
                          } else {
                            _showFailedSnackBar();
                          }
                        }
                      },
                      child:
                          Icon(Icons.delete_forever, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
