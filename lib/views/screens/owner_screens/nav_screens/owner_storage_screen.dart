import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:junk_shapp/views/screens/owner_screens/add_inventory_entry.dart';

class OwnerStorageScreen extends StatefulWidget {
  final dynamic junkShopData;

  const OwnerStorageScreen({super.key, this.junkShopData});
  @override
  State<OwnerStorageScreen> createState() => _OwnerStorageScreenState();
}

class _OwnerStorageScreenState extends State<OwnerStorageScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier("");

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchQueryNotifier.value = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchQueryNotifier.dispose();
    super.dispose();
  }

  Future<void> _confirmDeleteItem(Map<String, dynamic> item) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Confirm Deletion',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this item?',
                style: GoogleFonts.quicksand(),
              ),
              const SizedBox(height: 10),
              Text(
                'Category: ${item['category']}',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Stock: ${item['stock'].toStringAsFixed(2)} ${item['unit']}',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.quicksand(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(
                'Delete',
                style: GoogleFonts.quicksand(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteInventoryItem(item);
    }
  }

  Future<void> _deleteInventoryItem(Map<String, dynamic> item) async {
    try {
      await _firestore
          .collection('junk_shops')
          .doc(widget.junkShopData['junkShopId'])
          .update({
        'junkShopInventory': FieldValue.arrayRemove([item]),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Item "${item['category']}" removed successfully.',
              style: GoogleFonts.quicksand(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to remove item: $e',
              style: GoogleFonts.quicksand(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No inventory data available'));
          }

          final inventory = List<Map<String, dynamic>>.from(
            snapshot.data!['junkShopInventory'],
          );

          return Column(
            children: [
              const Divider(
                thickness: 1,
                height: 1,
                color: Colors.deepOrange,
              ),

              // SEARCH BOX
              Container(
                width: screenWidth,
                decoration: const BoxDecoration(color: Color(0xfffe6600)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Inventory",
                        style: GoogleFonts.quicksand(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.72,
                        height: screenHeight * 0.04,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            hintText: "Search inventory...",
                            hintStyle: GoogleFonts.quicksand(
                                color: Colors.white70, fontSize: 14),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // INVENTORY LIST
              Expanded(
                child: inventory.isEmpty
                    ? const Center(
                        child: Text(
                          "No items in inventory",
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ValueListenableBuilder<String>(
                        valueListenable: _searchQueryNotifier,
                        builder: (context, searchQuery, _) {
                          final filteredInventory = searchQuery.isEmpty
                              ? inventory
                              : inventory.where((item) {
                                  final category =
                                      item['category'].toString().toLowerCase();
                                  return category
                                      .contains(searchQuery.toLowerCase());
                                }).toList();

                          return filteredInventory.isEmpty
                              ? const Center(
                                  child: Text(
                                    "Item does not exist in inventory",
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredInventory.length,
                                  itemBuilder: (context, index) {
                                    final item = filteredInventory[index];
                                    return ListTile(
                                        onTap: () {},
                                        title: Text(
                                          item['category'],
                                          style: GoogleFonts.quicksand(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          "Stock: ${item['stock'].toStringAsFixed(2)} ${item['unit']}",
                                          style: GoogleFonts.quicksand(),
                                        ),
                                        shape: const Border(
                                          bottom: BorderSide(),
                                        ),
                                        trailing: IconButton(
                                            onPressed: () {
                                              _confirmDeleteItem(item);
                                            },
                                            icon: const Icon(
                                                Icons.delete_forever)));
                                  },
                                );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return AddInventoryEntry(
                junkShopData: widget.junkShopData,
              );
            },
          ));
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
