import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BuyItems extends StatefulWidget {
  final dynamic junkShopData;

  const BuyItems({super.key, this.junkShopData});

  @override
  State<BuyItems> createState() => _BuyItemsState();
}

class _BuyItemsState extends State<BuyItems> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  bool _isCustomCategory = false; // Toggle state for custom category
  final TextEditingController _customCategoryController =
      TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController(); // Quantity controller
  String? _customUnit; // State for custom unit of measurement

  bool _isLoading = false;

  @override
  void dispose() {
    _customCategoryController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _switchCategoryMode(bool isCustom) {
    setState(() {
      _isCustomCategory = isCustom;
      _customCategoryController.clear();
      _selectedCategory = null;
      _customUnit = null; // Reset custom unit
      _quantityController.clear(); // Reset quantity only on mode switch
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xffff6600),
        centerTitle: true,
        title: Text(
          "Buy Items",
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 20,
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

          // Extract data
          final junkShopData = snapshot.data!;
          final balance = junkShopData['junkShopBalance'] ?? 0.0;
          final inventory = List<Map<String, dynamic>>.from(
            junkShopData['junkShopInventory'],
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Available Balance: ₱${balance.toStringAsFixed(2)}',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 260,
                    child: Text(
                      '* Press the toggle button to switch between custom and existing categories',
                      style: GoogleFonts.quicksand(
                          textStyle:
                              const TextStyle(fontStyle: FontStyle.italic),
                          fontSize: 12,
                          // fontWeight: FontWeight.w500,
                          color: Colors.red[700]),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _isCustomCategory
                          ? Text(
                              'Add Custom Category:',
                              style: GoogleFonts.quicksand(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : Text(
                              'Select Category:',
                              style: GoogleFonts.quicksand(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                      Switch(
                        value: _isCustomCategory,
                        onChanged: _switchCategoryMode,
                        activeColor: const Color(0xffff6600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (!_isCustomCategory)
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedCategory,
                      hint: Text(
                        categoryList.isEmpty
                            ? 'No categories available'
                            : 'Select a category',
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
                              fontWeight: FontWeight.w700,
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
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (!_isCustomCategory && value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                  if (_isCustomCategory)
                    TextFormField(
                      controller: _customCategoryController,
                      decoration: InputDecoration(
                        hintText: 'Enter new category',
                        hintStyle: GoogleFonts.quicksand(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (_isCustomCategory &&
                            (value == null || value.isEmpty)) {
                          return 'Please enter a custom category';
                        }
                        return null;
                      },
                      style: GoogleFonts.quicksand(
                        color: Colors.black,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Php',
                            style: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: InputDecoration(
                                hintText: 'Enter price',
                                hintStyle: GoogleFonts.quicksand(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter price';
                                }
                                final enteredPrice = double.tryParse(value);
                                if (enteredPrice == null || enteredPrice <= 0) {
                                  return 'Price must be a positive number';
                                }
                                if (enteredPrice > balance) {
                                  return 'Price cannot exceed available balance';
                                }
                                return null;
                              },
                              style: GoogleFonts.quicksand(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: InputDecoration(
                                hintText: 'Enter quantity',
                                hintStyle: GoogleFonts.quicksand(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter quantity';
                                }
                                if (int.tryParse(value) == null ||
                                    int.parse(value) <= 0) {
                                  return 'Quantity must be a positive number';
                                }
                                return null;
                              },
                              style: GoogleFonts.quicksand(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!_isCustomCategory && _selectedCategory != null)
                            Text(
                              inventory
                                  .firstWhere(
                                      (item) =>
                                          item['category'] == _selectedCategory,
                                      orElse: () => {'unit': 'unit'})['unit']
                                  .toString(),
                              style: GoogleFonts.quicksand(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          if (_isCustomCategory)
                            DropdownButton<String>(
                              value: _customUnit,
                              hint: Text(
                                'Unit',
                                style: GoogleFonts.quicksand(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              items: ['kg', 'pc/s'].map((unit) {
                                return DropdownMenuItem<String>(
                                  value: unit,
                                  child: Text(
                                    unit,
                                    style: GoogleFonts.quicksand(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _customUnit = value;
                                });
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                      width: 300,
                      height: 48,
                      child: InkWell(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            // Handle form submission
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              // Your "Buy" logic goes here
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
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                  ),
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
                            color: const Color(0xfffe6600),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "Buy",
                                    style: GoogleFonts.quicksand(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.5),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
