import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:junk_shapp/controllers/transaction_controller.dart';
import 'package:junk_shapp/views/screens/buy_items.dart';
import 'package:junk_shapp/views/screens/owner_screens/add_inventory_entry.dart';
import 'package:junk_shapp/views/screens/register_new_staff_screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  final dynamic junkShopData;

  const OwnerHomeScreen({super.key, this.junkShopData});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TransactionController _transactionController = TransactionController();
  bool _isLoading = false; // Track loading state

  _showSnackBar(String text) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: GoogleFonts.quicksand(),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  _pop() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final NumberFormat currencyFormatter = NumberFormat("#,##0.00");
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.96),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
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
            return const Center(
              child: Text("No data available"),
            );
          }
          final junkShopData = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              // IMAGE
              SizedBox(
                height: screenHeight * 0.24,
                width: screenWidth,
                child: CachedNetworkImage(
                  imageUrl: junkShopData['junkShopImage'],
                  fit: BoxFit.cover,
                ),
              ),

              // JUNK SHOP BALANCE
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 12,
                  ),
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: Color(0xffff6600),
                    ),
                    width: screenWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 16.0,
                            left: 16,
                          ),
                          child: Text(
                            "AVAILABLE BALANCE:",
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              color: Colors.white,
                              letterSpacing: 2.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Text(
                                    "₱ ${currencyFormatter.format(junkShopData['junkShopBalance'] ?? 0)}",
                                    style: GoogleFonts.quicksand(
                                      fontSize: 28,
                                      color: Colors.white,
                                      letterSpacing: 0.1,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: InkWell(
                                  onTap: () async {
                                    // Open the dialog
                                    await showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        final TextEditingController
                                            amountController =
                                            TextEditingController();

                                        return StatefulBuilder(
                                          builder: (context, setState) {
                                            return AlertDialog(
                                              backgroundColor:
                                                  const Color(0xfffe6600),
                                              title: _isLoading == false
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Add Funds",
                                                          style: GoogleFonts
                                                              .quicksand(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 20),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.close,
                                                            color: Colors.white,
                                                          ),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                      ],
                                                    )
                                                  : Text(
                                                      "Add Funds",
                                                      style:
                                                          GoogleFonts.quicksand(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20),
                                                    ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller:
                                                        amountController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration: InputDecoration(
                                                      labelText: "Enter amount",
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      labelStyle:
                                                          GoogleFonts.quicksand(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  _isLoading
                                                      ? const CircularProgressIndicator()
                                                      : ElevatedButton(
                                                          onPressed: () async {
                                                            if (amountController
                                                                .text
                                                                .isNotEmpty) {
                                                              setState(() {
                                                                _isLoading =
                                                                    true; // Set loading state
                                                              });

                                                              double?
                                                                  enteredAmount =
                                                                  double.tryParse(
                                                                      amountController
                                                                          .text);

                                                              if (enteredAmount !=
                                                                      null &&
                                                                  enteredAmount >
                                                                      0) {
                                                                // add transaction entry
                                                                await _transactionController
                                                                    .uploadTransactionEntry(
                                                                  'Add Funds',
                                                                  enteredAmount,
                                                                  junkShopData[
                                                                      'junkShopId'],
                                                                );

                                                                // Update Firestore
                                                                await _firestore
                                                                    .collection(
                                                                        'junk_shops')
                                                                    .doc(junkShopData[
                                                                        'junkShopId'])
                                                                    .update({
                                                                  'junkShopBalance':
                                                                      FieldValue
                                                                          .increment(
                                                                              enteredAmount),
                                                                });

                                                                _pop();
                                                                _showSnackBar(
                                                                    "Funds added successfully!");
                                                              } else {
                                                                // Invalid input
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                    content:
                                                                        Text(
                                                                      "Enter a valid amount.",
                                                                      style: GoogleFonts
                                                                          .quicksand(),
                                                                    ),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
                                                                  ),
                                                                );
                                                              }

                                                              setState(() {
                                                                _isLoading =
                                                                    false; // Hide loading
                                                              });
                                                            }
                                                          },
                                                          child: Text(
                                                            "Confirm",
                                                            style: GoogleFonts.quicksand(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: const Color(
                                                                    0xfffe6600)),
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          "+  Add Funds",
                                          style: GoogleFonts.quicksand(
                                            color: const Color(0xffff6600),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // More widgets here
              // SERVICES
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20.0,
                              horizontal: 16,
                            ),
                            child: GridView(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 8,
                              ),
                              children: [
                                // Withdraw funds
                                InkWell(
                                  onTap: () async {
                                    await showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        final TextEditingController
                                            amountController =
                                            TextEditingController();

                                        return StatefulBuilder(
                                          builder: (context, setState) {
                                            return AlertDialog(
                                              // backgroundColor: Colors.white
                                              //     .withOpacity(0.96),
                                              title: _isLoading == false
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Withdraw Funds",
                                                          style: GoogleFonts
                                                              .quicksand(
                                                                  color: const Color(
                                                                      0xfffe6600),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 20),
                                                        ),
                                                        IconButton(
                                                          padding: EdgeInsets
                                                              .zero, // Removes extra padding
                                                          constraints:
                                                              const BoxConstraints(), // Reduces size constraints
                                                          icon: const Icon(
                                                            Icons.close,
                                                            color: Color(
                                                                0xfffe6600),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                      ],
                                                    )
                                                  : Text(
                                                      "Withdraw Funds",
                                                      style: GoogleFonts
                                                          .quicksand(
                                                              color: const Color(
                                                                  0xfffe6600),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20),
                                                    ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller:
                                                        amountController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration: InputDecoration(
                                                      labelText: "Enter amount",
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      labelStyle:
                                                          GoogleFonts.quicksand(
                                                        color: Colors.grey,
                                                        // fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  _isLoading
                                                      ? const CircularProgressIndicator()
                                                      : ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                const Color(
                                                                    0xfffe6600),
                                                          ),
                                                          onPressed: () async {
                                                            if (amountController
                                                                .text
                                                                .isNotEmpty) {
                                                              setState(() {
                                                                _isLoading =
                                                                    true; // Set loading state
                                                              });

                                                              double?
                                                                  enteredAmount =
                                                                  double.tryParse(
                                                                      amountController
                                                                          .text);

                                                              if (enteredAmount !=
                                                                      null &&
                                                                  enteredAmount >
                                                                      0 &&
                                                                  enteredAmount <=
                                                                      junkShopData[
                                                                          'junkShopBalance']) {
                                                                // upload transaction to db
                                                                await _transactionController
                                                                    .uploadTransactionEntry(
                                                                  'Withdraw Funds',
                                                                  -enteredAmount,
                                                                  junkShopData[
                                                                      'junkShopId'],
                                                                );

                                                                // Update Firestore
                                                                await _firestore
                                                                    .collection(
                                                                        'junk_shops')
                                                                    .doc(junkShopData[
                                                                        'junkShopId'])
                                                                    .update({
                                                                  'junkShopBalance':
                                                                      FieldValue
                                                                          .increment(
                                                                              -enteredAmount),
                                                                });

                                                                _pop();
                                                                _showSnackBar(
                                                                    "Withdraw successful!");
                                                              } else {
                                                                // Invalid input
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                    content:
                                                                        Text(
                                                                      "Enter a valid amount.",
                                                                      style: GoogleFonts
                                                                          .quicksand(),
                                                                    ),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
                                                                  ),
                                                                );
                                                              }

                                                              setState(() {
                                                                _isLoading =
                                                                    false; // Hide loading
                                                              });
                                                            }
                                                          },
                                                          child: Text(
                                                            "Confirm",
                                                            style: GoogleFonts
                                                                .quicksand(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/icons/withdraw_fund.png',
                                        width: screenWidth * 0.12,
                                        height: screenHeight * 0.056,
                                        color: const Color(0xfffe6600),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      const SizedBox(height: 4),
                                      Flexible(
                                        child: Text(
                                          "Withdraw Funds",
                                          style: GoogleFonts.quicksand(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.deepOrange.shade900,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // buy items
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return BuyItems(
                                            junkShopData: junkShopData,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/icons/buy_items.png',
                                        width: screenWidth * 0.12,
                                        height: screenHeight * 0.056,
                                        color: const Color(0xfffe6600),
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 4),
                                      Flexible(
                                        child: Text(
                                          "Buy Items",
                                          style: GoogleFonts.quicksand(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.deepOrange.shade900,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                //sell items
                                InkWell(
                                  onTap: () {},
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/icons/sell_items.png',
                                        width: screenWidth * 0.12,
                                        height: screenHeight * 0.056,
                                        color: const Color(0xfffe6600),
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 4),
                                      Flexible(
                                        child: Text(
                                          "Sell Items",
                                          style: GoogleFonts.quicksand(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.deepOrange.shade900,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // pay personnel
                                InkWell(
                                  onTap: () {},
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/icons/pay_personnel.png',
                                        width: screenWidth * 0.12,
                                        height: screenHeight * 0.056,
                                        color: const Color(0xfffe6600),
                                        fit: BoxFit.scaleDown,
                                      ),
                                      const SizedBox(height: 4),
                                      Flexible(
                                        child: Text(
                                          "Pay Personnel",
                                          style: GoogleFonts.quicksand(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.deepOrange.shade900,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Add inventory
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return AddInventoryEntry(
                                            junkShopData: junkShopData,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/icons/add_inventory.png',
                                        width: screenWidth * 0.10,
                                        height: screenHeight * 0.056,
                                        color: const Color(0xfffe6600),
                                        fit: BoxFit.scaleDown,
                                      ),
                                      const SizedBox(height: 4),
                                      Flexible(
                                        child: Text(
                                          "Add Item Category",
                                          style: GoogleFonts.quicksand(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.deepOrange.shade900,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // add personnel
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return RegisterNewStaffScreen(
                                            junkShopId:
                                                junkShopData['junkShopId'],
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/icons/add_personnel.png',
                                        width: screenWidth * 0.10,
                                        height: screenHeight * 0.056,
                                        color: const Color(0xfffe6600),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      const SizedBox(height: 4),
                                      Flexible(
                                        child: Text(
                                          "Add Personnel",
                                          style: GoogleFonts.quicksand(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.deepOrange.shade900,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'More services coming soon...',
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
