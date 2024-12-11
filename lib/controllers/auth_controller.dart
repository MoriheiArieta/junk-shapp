import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance; // for login authentication
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // for new user registration

  // LOGIN USER FUNCTION
  Future<String> loginUser(String email, String password) async {
    String result = "Failed login attempt"; // result prompt
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      result = 'pass';
    } on FirebaseAuthException catch (e) {
      print('Failed with error code: ${e.code}');
      print(e.message);
      result = e.message.toString();
    }
    return result;
  }
}
