import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerProfileScreen extends StatefulWidget {
  final dynamic junkShopData;

  const OwnerProfileScreen({super.key, this.junkShopData});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> _getUserData() async {
    try {
      final userId = _auth.currentUser?.uid;

      if (userId == null) {
        throw Exception('No user is logged in.');
      }

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();

      if (userData == null) {
        throw Exception('User data not found.');
      }

      return userData;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: GoogleFonts.quicksand(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xffff6600),
        centerTitle: true,
        title: FutureBuilder<Map<String, dynamic>?>(
          future: _getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }
            if (snapshot.hasError) {
              return const Text('Error loading data');
            }
            final userData = snapshot.data;
            return Text(
              userData?['fullName'] ?? 'Unknown User',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
      body: Center(
        child: Text(
          'Owner Profile Screen',
          style: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
