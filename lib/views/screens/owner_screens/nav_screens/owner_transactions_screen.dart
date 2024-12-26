import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class OwnerTransactionsScreen extends StatefulWidget {
  final dynamic junkShopData;

  const OwnerTransactionsScreen({super.key, this.junkShopData});

  @override
  State<OwnerTransactionsScreen> createState() =>
      _OwnerTransactionsScreenState();
}

class _OwnerTransactionsScreenState extends State<OwnerTransactionsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _sortTransactions(List<dynamic> transactions) {
    // Convert to List<Map<String, dynamic>> and parse timestamps
    List<Map<String, dynamic>> sortableTransactions =
        transactions.map((transaction) {
      return Map<String, dynamic>.from(transaction);
    }).toList();

    // Sort the transactions
    sortableTransactions.sort((a, b) {
      DateTime dateA = DateFormat('MMMM dd yyyy HH:mm:ss a')
          .parse(a['transactionTimestamp']);
      DateTime dateB = DateFormat('MMMM dd yyyy HH:mm:ss a')
          .parse(b['transactionTimestamp']);
      return dateB.compareTo(dateA); // Descending order (most recent first)
    });

    return sortableTransactions;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    DateTime _asOf = DateTime.now();
    String _formattedDateTime = DateFormat('MMMM dd yyyy').format(_asOf);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xffff6600),
        centerTitle: true,
        title: Text(
          widget.junkShopData['junkShopName'],
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('junk_shops')
            .doc(widget.junkShopData['junkShopId'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No transactions available'));
          }

          final transactions = _sortTransactions(
            List<dynamic>.from(snapshot.data!['junkShopTransactions']),
          );

          if (transactions.isEmpty) {
            return const Center(
                child: Text(
              'No transactions found',
              style: TextStyle(fontSize: 18),
            ));
          }

          return Column(
            children: [
              const Divider(
                thickness: 1,
                height: 1,
                color: Colors.deepOrange,
              ),
              Container(
                width: screenWidth,
                decoration: const BoxDecoration(color: Color(0xfffe6600)),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 12, left: 16),
                  child: Text(
                    'As of $_formattedDateTime',
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return ListTile(
                      title: Text(
                        transaction['transactionTimestamp'],
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        transaction['transactionType'],
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      shape: const Border(
                        bottom: BorderSide(),
                      ),
                      trailing: transaction['amount'].isNegative
                          ? Text(
                              transaction['amount'].toString(),
                              style: GoogleFonts.quicksand(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent.shade700,
                              ),
                            )
                          : Text(
                              "+${transaction['amount'].toString()}",
                              style: GoogleFonts.quicksand(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
