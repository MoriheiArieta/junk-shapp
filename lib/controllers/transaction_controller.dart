import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TransactionController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadTransactionEntry(
      String transactionType, num amount, String junkShopId) async {
    String result = 'Failed to add transaction entry.';
    DateTime _asOf = DateTime.now();
    String _formattedDateTime =
        DateFormat('MMMM dd yyyy HH:mm:ss a').format(_asOf);
    Map<String, dynamic> entryData = {
      'transactionTimestamp': _formattedDateTime,
      'transactionType': transactionType,
      'amount': amount.toDouble()
    };
    try {
      await _firestore.collection('junk_shops').doc(junkShopId).update({
        'junkShopTransactions': FieldValue.arrayUnion([entryData])
      });
      result = 'pass';
    } catch (e) {
      result = e.toString();
    }

    return result;
  }
}
