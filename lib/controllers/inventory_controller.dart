import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadInventoryEntry(
      String category, num stock, String unit, String junkShopId) async {
    String result = 'Failed to add inventory entry.';
    Map<String, dynamic> entryData = {
      'category': category,
      'stock': stock.toDouble(),
      'unit': unit
    };
    try {
      await _firestore.collection('junk_shops').doc(junkShopId).update({
        'junkShopInventory': FieldValue.arrayUnion([entryData])
      });
      result = 'pass';
    } catch (e) {
      result = e.toString();
    }

    return result;
  }
}
