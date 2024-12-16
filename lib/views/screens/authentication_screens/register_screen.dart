import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:junk_shapp/controllers/auth_controller.dart';
import 'package:junk_shapp/controllers/junk_shop_controller.dart';
import 'package:junk_shapp/views/screens/authentication_screens/login_screen.dart';
import 'package:uuid/uuid.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //  controllers
  final GlobalKey<FormState> _userFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _junkShopFormKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();
  final PageController _pageController = PageController();
  final JunkShopController _junkShopController = JunkShopController();
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // new user input
  late String fullName;
  late String email;
  late String password;

  // new junkshop input
  late String junkShopId;
  late String junkShopName;
  late num junkShopBalance;
  File? junkshopImage;

  //temp variables to save user entry
  final Map<String, dynamic> _junkShopData = {};
  final Map<String, String> _userData = {};

  // state manipulation variables
  bool _isLoading = false;
  bool _isObscure = true;
  int _currentPage = 0;
  String _currentPageTitle = "Sign Up New Owner";

  // FUNCTIONS

  // for the sign up button; uses the register new user in _auth
  registerOwner() async {
    setState(() {
      _isLoading = true;
    });
    await registerJunkShop();
    // awaits for function return from
    String result = await _authController.registerNewOwner(
        _userData["fullName"]!,
        _userData["email"]!,
        _userData["password"]!,
        junkShopId);

    // pass? show snackbar indicating user has been successfully created: show error
    if (result == 'pass') {
      Future.delayed(
        Duration.zero,
        () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xfffe7800),
                content: Text(
                  "User: ${_userData['fullName']} and \nJunk shop: ${_junkShopData['junkShopName']} successfully created.",
                  style: GoogleFonts.lato(color: Colors.white),
                ),
              ),
            );
            if (mounted) {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return const LoginScreen();
                },
              ));
            }
          }
        },
      );
    } else {
      setState(() {
        _isLoading = false;
      });

      Future.delayed(
        Duration.zero,
        () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xfffe7800),
                content: Text(
                  result,
                  style: GoogleFonts.lato(color: Colors.white),
                ),
              ),
            );
          }
        },
      );
    }
  }

  uploadImageToStorage(dynamic image) async {
    try {
      Reference storageRef = _firebaseStorage
          .ref()
          .child('junk_shop_images')
          .child(const Uuid().v4());
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _junkShopData['junkShopImage'] = downloadUrl;
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

  // for sign up button also; this will run first to ensure junk shop is created before the user
  registerJunkShop() async {
    // if (junkshopImage != null) { // put checker on the button
    setState(() {
      junkShopId = const Uuid().v4();
      _isLoading = true;
    });
    await uploadImageToStorage(_junkShopData['junkShopImage']);
    String result = await _junkShopController.uploadToFirestore(
        _junkShopData['junkShopImage']!,
        _junkShopData['junkShopName']!,
        double.parse(_junkShopData['junkShopBalance']!),
        junkShopId);
    if (result == 'pass') {
      // setState(() {
      //   _isLoading = false;
      // });
    } // need error checking here
  }

  // for page navigation on register screen
  void _goToPage(int pageIndex) {
    setState(() {
      _currentPage = pageIndex;
    });
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // allow users to pick image from gallery or camera
  Future<void> _pickImage(bool isCamera) async {
    final XFile? pickedImage = await _imagePicker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() {
        junkshopImage = File(pickedImage.path);
        _junkShopData['junkShopImage'] = junkshopImage;
      });
      // print(junkshopImage);
      _junkShopFormKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            _currentPageTitle,
            style: GoogleFonts.quicksand(
              // fontSize: 16,
              letterSpacing: 0.1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white.withOpacity(0.96),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                _currentPage = index;
              },
              children: [
                // REGISTER USER SCREEN
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _userFormKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ADD USER LOGO HERE
                            Image.asset(
                              'assets/icons/new_user.png',
                              width: 120,
                              // height: 100,
                            ),
                            SizedBox(
                              height: screenHeight * .05,
                            ),

                            // FULL NAME
                            TextFormField(
                              initialValue: _userData['fullName'],
                              onSaved: (newValue) {
                                _userData['fullName'] = newValue!;
                              },
                              onChanged: (value) {
                                fullName = value;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  // validate user input to force valid input
                                  return 'Enter your full name';
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none),
                                labelText: 'Full Name',
                                labelStyle: GoogleFonts.quicksand(
                                  fontSize: 16,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: screenHeight * .02,
                            ),

                            // EMAIL
                            TextFormField(
                              initialValue: _userData['email'],
                              onSaved: (newValue) {
                                _userData['email'] = newValue!;
                              },
                              onChanged: (value) {
                                email = value;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  // validate user input to force valid input
                                  return 'Enter your email';
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none),
                                labelText: 'Email',
                                labelStyle: GoogleFonts.quicksand(
                                  fontSize: 16,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: screenHeight * .02,
                            ),

                            // PASSWORD
                            TextFormField(
                              initialValue: _userData['password'],
                              onSaved: (newValue) {
                                _userData['password'] = newValue!;
                              },
                              obscureText: _isObscure,
                              onChanged: (value) {
                                password = value;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  // validate user input to force valid input
                                  return 'Enter your password';
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
                                labelText: 'Password',
                                labelStyle: GoogleFonts.quicksand(
                                  fontSize: 16,
                                  letterSpacing: 0.1,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      // for hiding/showing password
                                      _isObscure = !_isObscure;
                                    });
                                  },
                                  icon: Icon(
                                    _isObscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: screenHeight * .04,
                            ),

                            // NEXT BUTTON TO REGISTER JUNK SHOP SCREEN
                            InkWell(
                              onTap: () {
                                if (_userFormKey.currentState!.validate()) {
                                  setState(() {
                                    _currentPageTitle = "Register Junk Shop";
                                  });
                                  _userFormKey.currentState!.save();
                                  // registerOwner();
                                  _goToPage(1);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: const Color(0xfffe7800),
                                      content: Text(
                                        "Please fill all required fields.",
                                        style: GoogleFonts.lato(
                                            color: Colors.white),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                width: 316,
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
                                            borderRadius:
                                                BorderRadius.circular(30),
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
                                            borderRadius:
                                                BorderRadius.circular(3),
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
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),

                                    Positioned(
                                      left: 260,
                                      top: 16,
                                      child: Opacity(
                                        opacity: 0.5,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                              "Next",
                                              style: GoogleFonts.quicksand(
                                                fontSize: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(
                              height: screenHeight * .02,
                            ),
                            // SIGN UP TEXT BUTTON
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an Account? ",
                                  style: GoogleFonts.quicksand(
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    // to login screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return const LoginScreen();
                                        },
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Sign In Here',
                                    style: GoogleFonts.quicksand(
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xff103De5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // REGISTER JUNK SHOP SCREEN
                Padding(
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
                              height: screenHeight * .02,
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
                              initialValue: _junkShopData['junkShopName'],
                              onSaved: (newValue) {
                                _junkShopData['junkShopName'] = newValue!;
                              },
                              onChanged: (value) {
                                junkShopName = value;
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
                                    borderSide: BorderSide.none),
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
                                    initialValue:
                                        _junkShopData['junkShopBalance'],
                                    onSaved: (newValue) {
                                      _junkShopData['junkShopBalance'] =
                                          newValue!;
                                    },
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        junkShopBalance = double.parse(value);
                                      } else {
                                        junkShopBalance =
                                            0.0; // Default to 0 if empty
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
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          borderSide: BorderSide.none),
                                      labelText:
                                          'Enter current junk shop balance here',
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
                            // if _imageUrl!=null?show this text:showBanner
                            junkshopImage == null
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
                                    junkshopImage!,
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
                                  // print("pressed!");
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

                            // NAV BUTTONS
                            SizedBox(
                              width: 380,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // BACK BUTTON
                                  InkWell(
                                    onTap: () {
                                      // _junkShopData['junkShopImage'] =
                                      //     junkshopImage;
                                      _junkShopFormKey.currentState!.save();
                                      // registerOwner();
                                      setState(() {
                                        _currentPageTitle = "Sign Up New Owner";
                                      });
                                      _goToPage(0);
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
                                      // BUTTON DESIGN
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
                                                  borderRadius:
                                                      BorderRadius.circular(30),
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
                                                    "Back",
                                                    style:
                                                        GoogleFonts.quicksand(
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // SIGN UP BUTTON
                                  InkWell(
                                    onTap: () async {
                                      // _junkShopData['junkShopImage'] =
                                      //     junkshopImage;
                                      if (_junkShopFormKey.currentState!
                                          .validate()) {
                                        _junkShopFormKey.currentState!.save();
                                        // await registerJunkShop();
                                        if (_junkShopData['junkShopImage'] !=
                                            null) {
                                          await registerOwner();
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor:
                                                  const Color(0xfffe7800),
                                              content: Text(
                                                "Please upload junk shop photo.",
                                                style: GoogleFonts.lato(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          );
                                        }

                                        // _goToPage(0);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            backgroundColor:
                                                const Color(0xfffe7800),
                                            content: Text(
                                              "Please enter all required fields.",
                                              style: GoogleFonts.lato(
                                                  color: Colors.white),
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
                                            Color(0xFFFDB777),
                                            Color(0xFFFE7800),
                                          ],
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          // design

                                          Positioned(
                                            left: 160,
                                            top: 32,
                                            child: Opacity(
                                              opacity: 0.3,
                                              child: Container(
                                                width: 5,
                                                height: 5,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                              ),
                                            ),
                                          ),

                                          Positioned(
                                            left: 140,
                                            top: -12,
                                            child: Opacity(
                                              opacity: 0.3,
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          ),

                                          Positioned(
                                            left: 160,
                                            top: 16,
                                            child: Opacity(
                                              opacity: 0.5,
                                              child: Container(
                                                width: 10,
                                                height: 10,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
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
                                                    "Sign Up",
                                                    style:
                                                        GoogleFonts.quicksand(
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            // SIGN IN TEXT BUTTON
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an Account? ",
                                  style: GoogleFonts.quicksand(
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    // to login screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return const LoginScreen();
                                        },
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Sign In Here',
                                    style: GoogleFonts.quicksand(
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xff103De5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // progress indicator
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCircleProgressIndicator(0),
                const SizedBox(width: 8),
                _buildCircleProgressIndicator(1),
              ],
            ),
          )
        ],
      ),
    );
  }

  // WIDGETS
  Widget _buildCircleProgressIndicator(int pageIndex) {
    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 300,
      ),
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == pageIndex ? Colors.orange : Colors.grey,
      ),
    );
  }
}
