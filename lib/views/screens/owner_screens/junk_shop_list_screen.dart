import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:junk_shapp/views/screens/owner_screens/widgets/junk_shop_list_item_widget.dart';

class JunkShopListScreen extends StatefulWidget {
  const JunkShopListScreen({super.key});

  @override
  State<JunkShopListScreen> createState() => _JunkShopListScreenState();
}

class _JunkShopListScreenState extends State<JunkShopListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _junkShops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserJunkShops();
  }

  Future<void> _fetchUserJunkShops() async {
    try {
      // Get the current user's ID
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception("User not logged in.");
      }

      // Get the user's document
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw Exception("User document not found.");
      }

      // Get the list of junk shop IDs from the user's 'junkShops' property
      final junkShopIds = List<String>.from(userDoc.data()?['junkShops'] ?? []);

      // Fetch the details of each junk shop
      await _fetchJunkShopDetails(junkShopIds);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load junk shops: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchJunkShopDetails(List<String> junkShopIds) async {
    List<Map<String, dynamic>> fetchedJunkShops = [];

    try {
      for (String id in junkShopIds) {
        final junkShopDoc =
            await _firestore.collection('junk_shops').doc(id).get();

        if (junkShopDoc.exists) {
          fetchedJunkShops.add({
            'id': id,
            ...junkShopDoc.data()!,
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching junk shop details: $e')),
        );
      }
    }

    setState(() {
      _junkShops = fetchedJunkShops;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.96),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.all(0),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Icon(
                Icons.blinds_closed_outlined,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(
                width: 12,
              ),
              Text(
                'Junk Shop List',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFFE7800),
      ),
      body: Stack(
        children: [
          // Main scrollable content
          Positioned.fill(
            child: Column(
              children: [
                Divider(
                  color: Colors.white.withOpacity(0.8),
                  thickness: 1.0,
                  height: 1.0,
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : _junkShops.isEmpty
                          ? const Center(
                              child: Text(
                                "No junk shops found",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 80,
                                ), // Add padding to prevent overlap
                                child: Column(
                                  children: [
                                    ListView.builder(
                                      itemCount: _junkShops.length,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final junkShopData = _junkShops[index];
                                        return JunkShopListItemWidget(
                                          junkShopData: junkShopData,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),
          // Floating button
          Positioned(
              bottom: 20,
              right: 16,
              child: InkWell(
                onTap: () {},
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    // gradient: const LinearGradient(
                    //   colors: [
                    //     Color(0xFFFE7800),
                    //     Color(0xFFFDB777),
                    //   ],
                    // ),
                    color: const Color(0xFFFE7800),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 12,
                        offset: Offset(4, 4), // Shadow position
                      ),
                    ],

                    // borderRadius:
                  ),
                  child: const Icon(
                    Icons.add_business_outlined,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
