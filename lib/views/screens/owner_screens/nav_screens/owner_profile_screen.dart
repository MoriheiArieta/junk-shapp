// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:junk_shapp/views/screens/authentication_screens/login_screen.dart';

class OwnerProfileScreen extends StatefulWidget {
  final dynamic userData;

  const OwnerProfileScreen({super.key, this.userData});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  _returnToLogin() {
    // Navigate back to the login screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xffff6600),
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: CachedNetworkImageProvider(
                        widget.userData?['profileImage'] ??
                            'https://www.pngkey.com/png/detail/202-2024792_user-profile-icon-png-download-fa-user-circle.png',
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              widget.userData?['fullName'] ?? 'Unknown User',
                              style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          widget.userData?['email'] ?? 'Unknown Email',
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        toolbarHeight: screenHeight * 0.24,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Text(
            'Profile services will be available soon...',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              // fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 12),
          child: Container(
            decoration: const BoxDecoration(
              // only add a border on top side to make it look like a divider
              border: Border(
                top: BorderSide(
                  color: Colors.grey,
                  width: 0.5,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 8),
              child: InkWell(
                onTap: () async {
                  final bool? confirmed = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Confirm Logout',
                          style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold),
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
                              style: GoogleFonts.quicksand(color: Colors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
                              'Log Out',
                              style: GoogleFonts.quicksand(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  // Proceed with logout if confirmed
                  if (confirmed == true) {
                    // Perform the logout action
                    // Replace this with your sign-out logic if you're using Firebase Authentication
                    await FirebaseAuth.instance.signOut();
                    _returnToLogin();
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: Color(0xffff6600)),
                    const SizedBox(width: 10),
                    Text(
                      'Log Out',
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xffff6600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )

          // ElevatedButton(
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: const Color(0xffff6600),
          //     padding: const EdgeInsets.symmetric(vertical: 15),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(30),
          //     ),
          //   ),
          //   onPressed: () {
          //     // Add your logout logic here
          //   },
          //   child: Text(
          //     'Log Out',
          //     style: GoogleFonts.quicksand(
          //       fontSize: 18,
          //       fontWeight: FontWeight.bold,
          //       color: Colors.white,
          //     ),
          //   ),
          // ),
          ),
    );
  }
}
