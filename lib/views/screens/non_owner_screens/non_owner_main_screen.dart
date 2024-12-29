import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:junk_shapp/views/screens/authentication_screens/login_screen.dart';
import 'package:junk_shapp/views/screens/non_owner_screens/non_owner_home_screen.dart';
import 'package:junk_shapp/views/screens/non_owner_screens/non_owner_personnel_screen.dart';
import 'package:junk_shapp/views/screens/non_owner_screens/non_owner_storage_screen.dart';
import 'package:junk_shapp/views/screens/owner_screens/nav_screens/owner_profile_screen.dart';

class NonOwnerMainScreen extends StatefulWidget {
  final String userId; // Pass user ID instead of the whole user object
  final dynamic junkShopData;

  const NonOwnerMainScreen(
      {super.key, required this.userId, this.junkShopData});

  @override
  State<NonOwnerMainScreen> createState() => _NonOwnerMainScreenState();
}

class _NonOwnerMainScreenState extends State<NonOwnerMainScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _pageIndex = 0;
  late List<Widget> _pages;
  Map<String, dynamic>? _userData; // To store fetched user data

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

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

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(widget.userId).get();

      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>;
          _initializePages();
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _initializePages() {
    _pages = [
      NonOwnerHomeScreen(
        junkShopData: widget.junkShopData,
      ),
      NonOwnerStorageScreen(junkShopData: widget.junkShopData),
      NonOwnerPersonnelScreen(junkShopData: widget.junkShopData),
      OwnerProfileScreen(userData: _userData), // Use fetched user data
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _showLogoutConfirmationDialog(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xfffe6600),
          iconSize: 30,
          unselectedFontSize: 10,
          selectedFontSize: 10,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black45,
          currentIndex: _pageIndex,
          onTap: (value) {
            setState(() {
              _pageIndex = value;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome_mosaic_rounded),
                label: 'Inventory'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people), label: 'Personnel'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
        body: _userData != null ? _pages[_pageIndex] : _buildLoadingScreen(),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
