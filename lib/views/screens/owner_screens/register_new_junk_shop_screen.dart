import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:junk_shapp/controllers/junk_shop_controller.dart';
import 'package:uuid/uuid.dart';

class RegisterNewJunkShopScreen extends StatefulWidget {
  const RegisterNewJunkShopScreen({super.key});

  @override
  State<RegisterNewJunkShopScreen> createState() =>
      _RegisterNewJunkShopScreenState();
}

class _RegisterNewJunkShopScreenState extends State<RegisterNewJunkShopScreen> {
  final GlobalKey<FormState> _junkShopFormKey = GlobalKey<FormState>();
  final JunkShopController _junkShopController = JunkShopController();
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String _junkShopId;
  late String _junkShopName;
  late num _junkShopBalance;
  late String _junkShopImageUrl;
  File? _junkShopImage;

  bool _isLoading = false;

  // FUNCTIONS
  _uploadImageToStorage(dynamic image) async {
    try {
      Reference storageRef = _firebaseStorage
          .ref()
          .child('junk_shop_images')
          .child(const Uuid().v4());
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _junkShopImageUrl = downloadUrl;
      });
    } catch (e) {
      return Future.delayed(
        Duration.zero,
        () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xfffe7800),
                content: Text(
                  e.toString(),
                  style: GoogleFonts.lato(color: Colors.white),
                ),
              ),
            );
          }
        },
      );
    }
  }

  _registerJunkShop() async {
    // if (junkshopImage != null) { // put checker on the button
    setState(() {
      _junkShopId = const Uuid().v4();
      _isLoading = true;
    });
    await _uploadImageToStorage(_junkShopImage);
    String result = await _junkShopController.uploadToFirestore(
        _junkShopImageUrl,
        _junkShopName,
        _junkShopBalance.toDouble(),
        _junkShopId);
    if (result == 'pass') {
      try {
        final user = _auth.currentUser;

        await _firestore.collection('users').doc(user!.uid).update({
          'junkShops': FieldValue.arrayUnion([_junkShopId]),
        });
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xfffe7800),
              content: Text(
                "Junk Shop registered successfully!",
                style: GoogleFonts.lato(color: Colors.white),
              ),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xfffe7800),
                content: Text(
                  "Failed to update user's junk shops: $e",
                  style: GoogleFonts.lato(color: Colors.white),
                ),
              ),
            );
          }
        });
      }
    } else {
      if (mounted) {
        return ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xfffe7800),
            content: Text(
              result,
              style: GoogleFonts.lato(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  _pickImage(bool isCamera) async {
    final XFile? pickedImage = await _imagePicker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() {
        _junkShopImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        // automaticallyImplyLeading: false,
        title: Text(
          "Add Junk Shop",
          style: GoogleFonts.quicksand(
            fontSize: 20,
            letterSpacing: 0.1,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _junkShopFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ADD JUNKSHOP ICON HERE
                  Image.asset(
                    'assets/icons/new_junk_shop.png',
                    width: 120,
                    // height: 100,
                  ),

                  SizedBox(
                    height: screenHeight * .08,
                  ),
                  // JUNK SHOP NAME
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Junk Shop Name",
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextFormField(
                    onChanged: (value) {
                      _junkShopName = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        // validate user input to force valid input
                        return 'Enter Junk Shop Name';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      labelText: 'Enter junk shop name here',
                      labelStyle: GoogleFonts.quicksand(
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * .025,
                  ),
                  // JUNK SHOP BALANCE
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Junk Shop Balance",
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(
                          "Php",
                          style: GoogleFonts.quicksand(
                              fontSize: 16,
                              letterSpacing: 0.1,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Flexible(
                        child: TextFormField(
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              _junkShopBalance = double.parse(value);
                            } else {
                              _junkShopBalance = 0.0; // Default to 0 if empty
                            }
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              //o force valid input
                              return 'Enter your junk shop balance.';
                            } else {
                              return null;
                            }
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none),
                            labelText: 'Enter current junk shop balance here',
                            labelStyle: GoogleFonts.quicksand(
                              fontSize: 14,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * .025,
                  ),

                  // TEXT BUTTON FOR UPLOADING PICTURES
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Junk Shop Picture",
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: screenHeight * .01,
                  ),
                  _junkShopImage == null
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Upload junk shop image",
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              letterSpacing: 0.1,
                              color: const Color(0xff808080),
                              fontStyle: FontStyle.italic,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Image.file(
                          _junkShopImage!,
                          width: screenWidth * 0.9,
                          height: 172,
                          fit: BoxFit.cover,
                        ),
                  SizedBox(
                    height: screenHeight * .02,
                  ),

                  // FROM CAMERA
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        _pickImage(true);
                      },
                      child: Text(
                        'Capture photo using camera',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff103De5),
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xff103De5),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: screenHeight * .01,
                  ),

                  // FROM GALLERY
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        _pickImage(false);
                      },
                      child: Text(
                        'Pick image from gallery',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff103De5),
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xff103De5),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: screenHeight * .04,
                  ),

                  // REG BUTTON
                  SizedBox(
                    width: 316,
                    height: 48,
                    child: InkWell(
                      onTap: () async {
                        if (_junkShopFormKey.currentState!.validate()) {
                          if (_junkShopImage != null) {
                            await _registerJunkShop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xfffe7800),
                                content: Text(
                                  "Please upload junk shop photo.",
                                  style: GoogleFonts.lato(color: Colors.white),
                                ),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xfffe7800),
                              content: Text(
                                "Please enter all required fields.",
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 180,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFE7800),
                              Color(0xFFFDB777),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // design
                            Positioned(
                              left: 26,
                              top: 20,
                              child: Opacity(
                                opacity: 0.5,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 12,
                                      color: const Color(
                                        0xffffa500,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              left: 312,
                              top: 32,
                              child: Opacity(
                                opacity: 0.3,
                                child: Container(
                                  width: 5,
                                  height: 5,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              left: 280,
                              top: -12,
                              child: Opacity(
                                opacity: 0.3,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),

                            // text
                            Center(
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      "Register Junk Shop",
                                      style: GoogleFonts.quicksand(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.5),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
