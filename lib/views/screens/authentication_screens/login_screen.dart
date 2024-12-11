import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * .04,
                  ),
                  // LOGIN BUTTON
                  InkWell(
                    onTap: () {
                      //LOGIN USER
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
                            child: Text(
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
                          //REGISTER USER
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
