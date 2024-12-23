import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonnelController {
  // This is the controller for the personnel page
  // It will contain all the logic for the personnel page
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> registerNewStaff(
      String fullName,
      String email,
      String password,
      String staffRole,
      String profileImageUrl,
      String junkShopId) async {
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
          'staffRole': staffRole,
          'staffUid': userCredential.user!.uid,
          "profileImage": profileImageUrl,
          "isOwner": false,
          "junkShopId": junkShopId,
        },
      );

      // Add the staff ID to the junk shop's staff list
      DocumentReference junkShopRef =
          _firestore.collection('junk_shops').doc(junkShopId);

      await junkShopRef.update({
        'junkShopStaff': FieldValue.arrayUnion([userCredential.user!.uid]),
      });

      result = 'pass';
      // await _auth.signOut();
      // print(_auth.currentUser!.uid);
    } on FirebaseAuthException catch (e) {
      result = e.message.toString();
    }
    return result;
  }
}
