import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:junk_shapp/controllers/auth_controller.dart';
import 'package:junk_shapp/views/screens/authentication_screens/register_screen.dart';
import 'package:junk_shapp/views/screens/non_owner_screens/non_owner_home_screen.dart';
import 'package:junk_shapp/views/screens/owner_screens/junk_shop_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // controllers
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();

  // user input
  late String email;
  late String password;

  // state manipulation variables
  bool _isLoading = false;
  bool _isObscure = true; // to hide password user input
  bool _isOwner = false;

  // functions
  loginUser() async {
    setState(() {
      _isLoading = true; // to show circularProgressIndicator
    });
    String result = await _authController.loginUser(
        email, password); // to call loginUser from auth controller
    if (result == 'pass') {
      _isOwner = await _authController.getIsOwner(email);

      Future.delayed(
        Duration.zero,
        () {
          if (mounted) {
            if (_isOwner == true) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return JunkShopListScreen();
                  },
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const NonOwnerHomeScreen();
                  },
                ),
              );
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xfffe7800),
                content: Text(
                  "Successfully Logged In!",
                  style: GoogleFonts.lato(color: Colors.white),
                ),
              ),
            );
          }
        },
      );
      setState(() {
        _isLoading = false;
      });
    } else {
      // failed login attempts
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      // backgroundColor: Color(0xff32de84),
      backgroundColor: Colors.white.withOpacity(0.96),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logos/junkshapp_logo_circle.png',
                    width: screenWidth * 0.36,
                  ),

                  SizedBox(
                    height: screenHeight * .04,
                  ),
                  //LOGO
                  Image.asset(
                    'assets/logos/junkshapp_logo_horizontal_oow_transparent.png',
                    width: screenWidth * 0.88,
                  ),

                  SizedBox(
                    height: screenHeight * .04,
                  ),
                  // EMAIL
                  // Align(
                  //   alignment: Alignment.topLeft,
                  //   child: Text(
                  //     "Email",
                  //     style: GoogleFonts.quicksand(
                  //         // fontSize: 24,
                  //         fontWeight: FontWeight.w600,
                  //         letterSpacing: 0.2),
                  //   ),
                  // ),
                  TextFormField(
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
                  // Align(
                  //   alignment: Alignment.topLeft,
                  //   child: Text(
                  //     "Password",
                  //     style: GoogleFonts.quicksand(
                  //         // fontSize: 24,
                  //         fontWeight: FontWeight.w600,
                  //         letterSpacing: 0.2),
                  //   ),
                  // ),
                  TextFormField(
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
                          _isObscure ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * .04,
                  ),
                  // LOGIN BUTTON
                  InkWell(
                    onTap: () {
                      //LOGIN USER
                      if (_formKey.currentState!.validate()) {
                        loginUser();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xfffe7800),
                            content: Text(
                              "Failed to Log In.",
                              style: GoogleFonts.lato(color: Colors.white),
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
                                    "Sign In",
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
                        "Need an Account? ",
                        style: GoogleFonts.quicksand(
                          letterSpacing: 1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          // to register screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const RegisterScreen();
                              },
                            ),
                          );
                        },
                        child: Text(
                          'Sign Up Here',
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

            // Text(
            //   "Login",
            // style: GoogleFonts.quicksand(
            //   fontSize: 24,
            //   fontWeight: FontWeight.bold,
            // ),
            // ),
          ),
        ),
      ),
    );
  }
}
