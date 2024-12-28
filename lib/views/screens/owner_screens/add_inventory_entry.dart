import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:junk_shapp/controllers/inventory_controller.dart';

class AddInventoryEntry extends StatefulWidget {
  final dynamic junkShopData;

  const AddInventoryEntry({super.key, this.junkShopData});

  @override
  State<AddInventoryEntry> createState() => _AddInventoryEntryState();
}

class _AddInventoryEntryState extends State<AddInventoryEntry> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final InventoryController _controller = InventoryController();
  final List<String> unitList = ["kg", "pc/s"];

  late String _category;
  late num _stock;
  String? _unit; // Nullable to handle no initial selection

  bool _isLoading = false;

  _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.quicksand(),
        ),
        backgroundColor: color,
      ),
    );
  }

  _pop() {
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white.withOpacity(0.96),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xffff6600),
        centerTitle: true,
        title: Text(
          "Add Item Category",
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _key,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ADD INVENTORY ICON
                  Image.asset(
                    'assets/icons/add_inventory.png',
                    width: 120,
                    color: const Color(0xfffe6600),
                  ),
                  const SizedBox(height: 20),

                  // CATEGORY NAME
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Category",
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextFormField(
                    onChanged: (value) => _category = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Enter Category Name' : null,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      labelText: 'Enter category name here',
                      labelStyle: GoogleFonts.quicksand(
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // STOCK AND UNIT
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Stock",
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      // Stock Count Field
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (value) {
                            setState(() {
                              // Safely parse the input
                              if (value.isNotEmpty) {
                                _stock = double.tryParse(value)!;
                              } else {
                                _stock = 0.0; // Default to 0 if empty
                              }
                            });
                          },
                          validator: (value) {
                            // Check if value is empty or cannot be parsed to a valid number
                            if (value == null ||
                                value.isEmpty ||
                                double.tryParse(value) == null) {
                              return 'Enter a valid stock count';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            labelText: 'Stock count',
                            labelStyle: GoogleFonts.quicksand(
                              fontSize: 14,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Unit Dropdown
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: _unit,
                          hint: Text(
                            'Unit',
                            style: GoogleFonts.quicksand(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          items: unitList
                              .map(
                                (unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(
                                    unit,
                                    style: GoogleFonts.quicksand(fontSize: 16),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() => _unit = value),
                          validator: (value) =>
                              value == null ? 'Select a unit' : null,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 32,
                  ),

                  // ADD BUTTON
                  SizedBox(
                    width: 316,
                    height: 48,
                    child: InkWell(
                      onTap: () async {
                        if (_key.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            // Check if the category already exists
                            final snapshot = await FirebaseFirestore.instance
                                .collection('junk_shops')
                                .doc(widget.junkShopData['junkShopId'])
                                .get();

                            if (snapshot.exists) {
                              final inventory = List<Map<String, dynamic>>.from(
                                  snapshot['junkShopInventory']);
                              final categoryExists = inventory.any((item) =>
                                  item['category'].toString().toLowerCase() ==
                                  _category.toLowerCase());

                              if (categoryExists) {
                                _showSnackBar(
                                    "Category already exists. Please enter a different category.",
                                    Colors.red);

                                // Reset loading state and exit early
                                setState(() {
                                  _isLoading = false;
                                });
                                return;
                              }
                            }

                            await _controller.uploadInventoryEntry(
                              _category,
                              _stock,
                              _unit!,
                              widget.junkShopData['junkShopId'],
                            );

                            _showSnackBar("Inventory entry added successfully!",
                                Colors.green);
                            _pop();
                          } catch (e) {
                            _showSnackBar("Error: ${e.toString()}", Colors.red);
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                "Please enter all required fields.",
                                style: GoogleFonts.lato(color: Colors.white),
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 180,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFE7800),
                              Color(0xFFFDB777),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // design
                            Positioned(
                              left: 26,
                              top: 20,
                              child: Opacity(
                                opacity: 0.5,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 12,
                                      color: const Color(
                                        0xffffa500,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              left: 312,
                              top: 32,
                              child: Opacity(
                                opacity: 0.3,
                                child: Container(
                                  width: 5,
                                  height: 5,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              left: 280,
                              top: -12,
                              child: Opacity(
                                opacity: 0.3,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),

                            // text
                            Center(
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      "Add",
                                      style: GoogleFonts.quicksand(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.5),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
