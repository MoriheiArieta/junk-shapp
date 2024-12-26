import 'package:flutter/material.dart';
import 'package:junk_shapp/views/screens/owner_screens/nav_screens/owner_home_screen.dart';
import 'package:junk_shapp/views/screens/owner_screens/nav_screens/owner_personnel_screen.dart';
import 'package:junk_shapp/views/screens/owner_screens/nav_screens/owner_profile_screen.dart';
import 'package:junk_shapp/views/screens/owner_screens/nav_screens/owner_storage_screen.dart';
import 'package:junk_shapp/views/screens/owner_screens/nav_screens/owner_transactions_screen.dart';

class OwnerMainScreen extends StatefulWidget {
  final dynamic junkShopData;
  final dynamic userData;

  const OwnerMainScreen({super.key, this.junkShopData, this.userData});

  // const OwnerMainScreen({super.key, this.junkShopData});

  @override
  State<OwnerMainScreen> createState() => _OwnerMainScreenState();
}

class _OwnerMainScreenState extends State<OwnerMainScreen> {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _pageIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      OwnerHomeScreen(
        junkShopData: widget.junkShopData,
      ),
      OwnerStorageScreen(junkShopData: widget.junkShopData),
      OwnerTransactionsScreen(
        junkShopData: widget.junkShopData,
      ),
      OwnerPersonnelScreen(junkShopData: widget.junkShopData),
      OwnerProfileScreen(userData: widget.userData),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              icon: Icon(Icons.assignment), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Personnel'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: _pages[_pageIndex],
    );
  }
}
