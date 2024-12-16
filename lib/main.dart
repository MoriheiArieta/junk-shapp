import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:junk_shapp/views/screens/authentication_screens/login_screen.dart';
import 'package:junk_shapp/views/screens/authentication_screens/register_screen.dart';

void main() async {
  // make async to wafracfr firebase to intialize before running app
  WidgetsFlutterBinding
      .ensureInitialized(); //makes sure widgets are initialized

  Platform.isAndroid
      ? await Firebase.initializeApp(
          name: "initFirebase",
          options: const FirebaseOptions(
            apiKey: "AIzaSyAexWeI5_lPvR3VpbQfbVrGHPiIhOOkUSA",
            appId: "1:977880012138:android:52f759b4fe5c94411a0113",
            messagingSenderId: "977880012138",
            projectId: "junk-shapp-35eea",
            storageBucket: "gs://junk-shapp-35eea.firebasestorage.app",
          ),
        )
      : await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Junk ShApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
