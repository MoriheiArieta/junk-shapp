import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:junk_shapp/views/screens/owner_screens/register_new_junk_shop_screen.dart';
import 'package:junk_shapp/views/screens/owner_screens/widgets/junk_shop_list_item_widget.dart';

class JunkShopListScreen extends StatelessWidget {
  final dynamic user;

  const JunkShopListScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    // final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white.withOpacity(0.96),
        body: const Center(
          child: Text(
            'User not logged in!',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.96),
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        // toolbarHeight: 40,
        title: Text(
          'Junk Shop List',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.w500,
            fontSize: 20,
            // letterSpacing: 0.1,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xffff6600),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (userSnapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${userSnapshot.error}',
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          final userData = userSnapshot.data?.data() as Map<String, dynamic>?;

          if (userData == null) {
            return const Center(
              child: Text(
                "No data found",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final ownerName = userData['fullName'] ?? 'Unknown Owner';
          final junkShopIds = List<String>.from(userData['junkShops'] ?? []);
          final junkShopCount = junkShopIds.length;

          return Column(
            children: [
              const Divider(
                thickness: 1,
                height: 1,
                color: Colors.deepOrange,
              ),
              // Static box with owner name and junk shop count
              Container(
                width: double.infinity,
                color: const Color(0xffff6600),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Owner: $ownerName',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        // fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    // const SizedBox(height: 4),
                    Text(
                      'Number of Junk Shops: $junkShopCount',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Divider(),
              const SizedBox(height: 8),
              // Junk shop list
              Expanded(
                child: junkShopIds.isEmpty
                    ? const Center(
                        child: Text(
                          "No junk shops found",
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('junk_shops')
                            .where(FieldPath.documentId, whereIn: junkShopIds)
                            .orderBy('junkShopTimestamp')
                            .snapshots(),
                        builder: (context, junkShopsSnapshot) {
                          if (junkShopsSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (junkShopsSnapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${junkShopsSnapshot.error}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }

                          final junkShops = junkShopsSnapshot.data?.docs ?? [];

                          if (junkShops.isEmpty) {
                            return const Center(
                              child: Text(
                                "No junk shops found",
                                style: TextStyle(fontSize: 18),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: junkShops.length,
                            itemBuilder: (context, index) {
                              final junkShopData = junkShops[index].data()
                                  as Map<String, dynamic>;

                              return JunkShopListItemWidget(
                                junkShopData: junkShopData,
                                userData: userData,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return const RegisterNewJunkShopScreen();
            },
          ));
        },
        backgroundColor: const Color(0xFFfe6600),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}
