import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerHomeScreen extends StatefulWidget {
  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  // const OwnerHomeScreen({super.key});
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> _junkShops = [];
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchJunkShops();
  }

  // fetch junk shops
  Future<void> _fetchJunkShops() async {
    try {
      // get current user's uid
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return;
      }

      // fetch userdata from firestore db
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      // extract junkshops array
      if (userDoc.exists) {
        setState(() {
          _junkShops = List<String>.from(userDoc['junkShops'] ?? []);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load junk shops')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Junk Shop List',
              style: GoogleFonts.quicksand(
                // fontSize: 24,
                fontWeight: FontWeight.w500,
                // color: Colors.white,
              ),
            ),
          ),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Colors.orange,
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _junkShops.isEmpty
                ? const Center(
                    child: Text("No junk shops found"),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _junkShops.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {},
                        title: Text(_junkShops[index]),
                      );
                    },
                  )

        //JUNK SHOP LIST
        //make model fist
        //then provider
        //then cards

        );
  }
}
