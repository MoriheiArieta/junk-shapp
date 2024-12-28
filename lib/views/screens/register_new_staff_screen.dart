import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:junk_shapp/controllers/personnel_controller.dart';
import 'package:uuid/uuid.dart';

class RegisterNewStaffScreen extends StatefulWidget {
  final String junkShopId;

  const RegisterNewStaffScreen({super.key, required this.junkShopId});
  // const RegisterNewStaffScreen({super.key});

  @override
  State<RegisterNewStaffScreen> createState() => _RegisterNewStaffScreenState();
}

class _RegisterNewStaffScreenState extends State<RegisterNewStaffScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final PersonnelController _personnelController = PersonnelController();

  late String _fullName;
  late String _email;
  late String _password;
  late String _profileImageUrl = '';
  late String _staffRole;
  File? _profileImage;

  bool _isLoading = false;
  bool _isObscure = true;
  // bool _isCamera = true;

  // FUNCTIONS
  // upload _profileImage to firebase storage
  _uploadImageToStorage(dynamic image) async {
    try {
      // Upload image to firebase storage
      TaskSnapshot snapshot = await _firebaseStorage
          .ref('profile_images/${const Uuid().v4()}')
          .putFile(image)
          .whenComplete(() => null);

      // Get the download url of the uploaded image
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _profileImageUrl = downloadUrl;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              e.toString(),
              style: GoogleFonts.lato(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  // register new staff
  _registerNewStaff() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Upload profile image to firebase storage
      await _uploadImageToStorage(_profileImage!);

      // Register new staff
      String result = await _personnelController.registerNewStaff(
        _fullName,
        _email,
        _password,
        _staffRole,
        _profileImageUrl,
        widget.junkShopId,
      );

      if (result == 'pass') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                'Staff registered successfully.',
                style: GoogleFonts.lato(color: Colors.white),
              ),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                result,
                style: GoogleFonts.lato(color: Colors.white),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              e.toString(),
              style: GoogleFonts.lato(color: Colors.white),
            ),
          ),
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(0xfffe6600)),

        centerTitle: true,
        // backgroundColor: Colors.transparent,
        // automaticallyImplyLeading: false,
        title: Text(
          "Add Personnel",
          style: GoogleFonts.quicksand(
            fontSize: 20,
            letterSpacing: 0.1,
            fontWeight: FontWeight.bold,
            color: const Color(0xfffe6600),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ADD PERSONNEL ICON HERE
                  // Image.asset(
                  //   'assets/icons/add_personnel.png',
                  //   color: const Color(0xfffe6600),
                  //   width: 120,
                  //   fit: BoxFit.cover,
                  // ),

                  // PERSONNEL PROFILE IMAGE
                  Center(
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            //prompt user to select image from gallery or camera
                            return AlertDialog(
                              title: Text(
                                'Select Image Source',
                                style: GoogleFonts.quicksand(
                                  fontSize: 18,
                                  letterSpacing: 0.2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.camera),
                                    title: Text(
                                      'Camera',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 16,
                                        letterSpacing: 0.2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final pickedFile =
                                          await _imagePicker.pickImage(
                                              source: ImageSource.camera);
                                      if (pickedFile != null) {
                                        setState(() {
                                          _profileImage = File(pickedFile.path);
                                        });
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.photo),
                                    title: Text(
                                      'Gallery',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 16,
                                        letterSpacing: 0.2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final pickedFile =
                                          await _imagePicker.pickImage(
                                              source: ImageSource.gallery);
                                      if (pickedFile != null) {
                                        setState(() {
                                          _profileImage = File(pickedFile.path);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Column(
                        children: [
                          _profileImage != null
                              ? Container(
                                  width: screenWidth * .5,
                                  height: screenHeight * .25,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                      image: FileImage(_profileImage!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: screenWidth * .3,
                                  height: screenHeight * .15,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color:
                                        const Color(0xff808080).withOpacity(.2),
                                  ),
                                  child: const Icon(Icons.camera_alt),
                                ),
                          SizedBox(
                            height: screenHeight * .01,
                          ),
                          Text(
                            "Upload Profile Image",
                            style: GoogleFonts.quicksand(
                              fontSize: 16,
                              letterSpacing: 0.2,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    height: screenHeight * .02,
                  ),

                  // PERSONNEL FULL NAME
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Full Name",
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextFormField(
                    onChanged: (value) {
                      _fullName = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        // validate user input to force valid input
                        return 'Enter Full Name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      labelText: 'Enter full name here',
                      labelStyle: GoogleFonts.quicksand(
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),

                  // PERSONNEL ROLE
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Role",
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextFormField(
                    onChanged: (value) {
                      _staffRole = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        // validate user input to force valid input
                        return 'Enter Personnel Role';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      labelText: 'Eg. Cashier, Driver, etc.',
                      labelStyle: GoogleFonts.quicksand(
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: screenHeight * .01,
                  ),

                  // PERSONNEL EMAIL
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Email",
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextFormField(
                    onChanged: (value) {
                      _email = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        // validate user input to force valid input
                        return 'Enter Email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      labelText: 'Enter email here',
                      labelStyle: GoogleFonts.quicksand(
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: screenHeight * .01,
                  ),

                  // PERSONNEL PASSWORD
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Password",
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextFormField(
                    obscureText: _isObscure,
                    onChanged: (value) {
                      _password = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        // validate user input to force valid input
                        return 'Enter Password';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      labelText: 'Enter password here',
                      labelStyle: GoogleFonts.quicksand(
                        fontSize: 14,
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
                          _isObscure ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: screenHeight * .01,
                  ),

                  SizedBox(
                    height: screenHeight * .01,
                  ),

                  // REG BUTTON
                  SizedBox(
                    width: 316,
                    height: 48,
                    child: InkWell(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          if (_profileImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  "Please select a profile image.",
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                            return;
                          } else {
                            await _registerNewStaff();
                            // print(_auth.currentUser!.uid);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
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
                          color: const Color(0xfffe6600),
                        ),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  "Register Personnel",
                                  style: GoogleFonts.quicksand(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5),
                                ),
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
