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

class _OwnerTransactionsScreenState extends State<OwnerTransactionsScreen>
    with AutomaticKeepAliveClientMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int batchSize = 10;

  List<dynamic> displayedTransactions = [];
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  void fetchMoreTransactions(List<dynamic> allTransactions) {
    if (displayedTransactions.length >= allTransactions.length) {
      setState(() {
        hasMoreData = false;
      });
      return;
    }

    int nextBatchEnd = displayedTransactions.length + batchSize;
    setState(() {
      displayedTransactions.addAll(
        allTransactions.sublist(
          displayedTransactions.length,
          nextBatchEnd > allTransactions.length
              ? allTransactions.length
              : nextBatchEnd,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final screenWidth = MediaQuery.of(context).size.width;
    String formattedDateTime =
        DateFormat('MMMM dd yyyy').format(DateTime.now());

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
      body: Column(
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
                'As of $formattedDateTime',
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
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

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: Text(
                      'No transactions found',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                // Process transactions locally without using setState
                List<dynamic> allTransactions = List<Map<String, dynamic>>.from(
                    snapshot.data!['junkShopTransactions'] ?? []);

                allTransactions.sort((a, b) {
                  DateTime dateA = DateFormat('MMMM dd yyyy HH:mm:ss a')
                      .parse(a['transactionTimestamp']);
                  DateTime dateB = DateFormat('MMMM dd yyyy HH:mm:ss a')
                      .parse(b['transactionTimestamp']);
                  return dateB.compareTo(dateA);
                });

                List<dynamic> visibleTransactions = allTransactions.sublist(
                    0, displayedTransactions.length + batchSize);

                return ListView.builder(
                  itemCount: visibleTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = visibleTransactions[index];
                    return Column(
                      children: [
                        ListTile(
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
                        ),
                        const Divider(
                          height: 0,
                          thickness: 1,
                          color: Colors.grey,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
