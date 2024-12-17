import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance; // for login authentication
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  get currentUserId => null; // for new user registration

  // LOGIN USER FUNCTION
  Future<String> loginUser(String email, String password) async {
    String result = "Failed login attempt"; // result prompt
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      result = 'pass';
    } on FirebaseAuthException catch (e) {
      result = e.message.toString();
    }
    return result;
  }

  // RESISTER USER
  // make async to ensure user is registerd on firestore
  Future<String> registerNewOwner(
      String fullName, String email, String password, String junkShopId) async {
    String result = 'Failed sign up attempt';
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      await _firestore
          .collection(
              'users') // create/access collection from firestore db for storage
          .doc(userCredential.user!
              .uid) // fetch uid from firestore db for editing user properties
          .set(
        {
          // set the user properties to store on firestore db
          'fullName': fullName,
          'email': email,
          'uid': userCredential.user!.uid,
          "profileImage": '',
          "isOwner": true,
          "junkShops": [junkShopId],
        },
      );

      result = 'pass';
    } on FirebaseAuthException catch (e) {
      result = e.message.toString();
    }
    return result;
  }

  // GET USER DATA FOR ROUTING TO PROPER SCREENS
  Future<bool> getIsOwner(String email) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users') // Adjust to your Firestore collection name
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Extract the `isOwner` property from the user data
        Map<String, dynamic> userData =
            snapshot.docs.first.data() as Map<String, dynamic>;
        return userData['isOwner']; // Return the `isOwner` property
      }
    } catch (e) {
      // print("Error fetching isOwner: $e");/
    }
    return false; // Return null if there's an error or no matching document
  }
}
