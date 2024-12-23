import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTransaction extends StatefulWidget {
  final dynamic junkShopData;

  const AddTransaction({super.key, this.junkShopData});

  @override
  State<AddTransaction> createState() =>
      _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xffff6600),
        centerTitle: true,
        title: Text(
          widget.junkShopData['junkShopName'],
          style: GoogleFonts.quicksand(
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
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No inventory data available'));
          }

          // Extract inventory and categories
          final inventory = List<Map<String, dynamic>>.from(
            snapshot.data!['junkShopInventory'],
          );
          final categoryList = inventory
              .map((item) => item['category'].toString())
              .toSet()
              .toList();

          // Reset selected category if it no longer exists
          if (_selectedCategory != null &&
              !categoryList.contains(_selectedCategory)) {
            _selectedCategory = null;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a Category:',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategory,
                  hint: Text(
                    'Choose a category',
                    style: GoogleFonts.quicksand(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  items: categoryList.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  style: GoogleFonts.quicksand(
                    color: Colors.black,
                  ),
                  dropdownColor: Colors.white,
                  icon: const Icon(Icons.arrow_drop_down),
                  iconEnabledColor: const Color(0xffff6600),
                ),
                const SizedBox(height: 20),
                if (_selectedCategory != null)
                  Text(
                    'Selected Category: $_selectedCategory',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your desired functionality here
        },
        backgroundColor: const Color(0xFFfe6600),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}
