import 'package:cloud_firestore/cloud_firestore.dart';

class JunkShopController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadToFirestore(
    String junkShopImageUrl,
    String junkShopName,
    double junkShopBalance,
    String junkShopId,
  ) async {
    String result = 'Failed to register junk shop.';
    try {
      // junk shop details to be stored on firebase db
      await _firestore.collection('junk_shops').doc(junkShopId).set({
        'junkShopId': junkShopId,
        'junkShopName': junkShopName,
        'junkShopBalance': junkShopBalance.toDouble(),
        'junkShopImage': junkShopImageUrl,
        'junkShopTransactions': [],
        'junkShopInventory': [],
        'junkShopStaff': [],
        'junkShopTimestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      result = 'pass';
    } catch (e) {
      result = e.toString();
    }

    return result;
  }

  Future<String> deleteJunkShop(String junkShopId) async {
    String result = 'Failed to delete junk shop.';
    try {
      await _firestore.collection('junk_shops').doc(junkShopId).delete();
      result = 'pass';
    } catch (e) {
      result = e.toString();
    }

    return result;
  }
}
