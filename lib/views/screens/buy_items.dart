import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:junk_shapp/controllers/inventory_controller.dart';
import 'package:junk_shapp/controllers/transaction_controller.dart';

class BuyItems extends StatefulWidget {
  final dynamic junkShopData;

  const BuyItems({super.key, this.junkShopData});

  @override
  State<BuyItems> createState() => _BuyItemsState();
}

class _BuyItemsState extends State<BuyItems> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _customCategoryController =
      TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final InventoryController _inventoryController = InventoryController();
  final TransactionController _transactionController = TransactionController();
  final TextEditingController _priceController = TextEditingController();

  bool _isCustomCategory = false; // Toggle state for custom category
  String? _selectedCategory;
  String? _customUnit; // State for custom unit of measurement
  num? enteredPrice;

  bool _isLoading = false;

  _showErrorSnackBar(dynamic e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Error: ${e.toString()}",
          style: GoogleFonts.lato(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          message,
          style: GoogleFonts.lato(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  bool _categoryExists(String category, List<Map<String, dynamic>> inventory) {
    return inventory.any((item) =>
        item['category'].toString().toLowerCase() == category.toLowerCase());
  }

  @override
  void dispose() {
    _customCategoryController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _switchCategoryMode(bool isCustom) {
    setState(() {
      _isCustomCategory = isCustom;
      _customCategoryController.clear();
      _quantityController.clear(); // Reset quantity only on mode switch
      _selectedCategory = null;
      _priceController.clear();
      _customUnit = null; // Reset custom unit
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
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // BALANCE
                      Text(
                        'Available Balance: ₱${balance.toStringAsFixed(2)}',
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // TOOL TIP
                      SizedBox(
                        width: double.infinity,
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

                      //  LABEL +TOGGLE SWITCH
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _isCustomCategory
                              ? Text(
                                  'Add Custom Category:',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 16,
                                    letterSpacing: 0.2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  'Select Category:',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 16,
                                    letterSpacing: 0.2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          Switch(
                            value: _isCustomCategory,
                            onChanged: _switchCategoryMode,
                            activeColor: const Color(0xffff6600),
                          ),
                        ],
                      ),

                      // CATEGORY DROPDOWN/TEXT FIELD
                      // const SizedBox(height: 8),
                      if (!_isCustomCategory)
                        DropdownButtonFormField<String>(
                          iconEnabledColor: const Color(0xffff6600),
                          iconDisabledColor: Colors.grey,
                          isExpanded: true,
                          value: _selectedCategory,
                          hint: Text(
                            categoryList.isEmpty
                                ? 'No categories available'
                                : 'Select a category',
                            style: GoogleFonts.quicksand(
                              color: Colors.grey[600],
                              fontSize: 14,
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
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
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
                            fillColor: Colors.white,
                            filled: true,
                            hintStyle: GoogleFonts.quicksand(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
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

                      // PRICE
                      Column(
                        children: [
                          // QUANTITY
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Quantity",
                              style: GoogleFonts.quicksand(
                                fontSize: 16,
                                letterSpacing: 0.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d*')),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Enter quantity',
                                    hintStyle: GoogleFonts.quicksand(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
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

                              // UNIT MEASUREMENT
                              if (!_isCustomCategory &&
                                  _selectedCategory != null)
                                Text(
                                  inventory
                                      .firstWhere(
                                          (item) =>
                                              item['category'] ==
                                              _selectedCategory,
                                          orElse: () =>
                                              {'unit': 'unit'})['unit']
                                      .toString(),
                                  style: GoogleFonts.quicksand(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              if (_isCustomCategory)
                                SizedBox(
                                  width: 100,
                                  child: DropdownButtonFormField<String>(
                                    iconEnabledColor: const Color(0xffff6600),
                                    iconDisabledColor: Colors.grey,
                                    value: _customUnit,
                                    hint: Text(
                                      'Unit',
                                      style: GoogleFonts.quicksand(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    items: ['kg', 'pc/s'].map((unit) {
                                      return DropdownMenuItem<String>(
                                        value: unit,
                                        child: Text(
                                          unit,
                                          style: GoogleFonts.quicksand(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _customUnit = value;
                                      });
                                    },
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
                          const SizedBox(height: 16),
                          // PRICE
                          Row(
                            children: [
                              Text(
                                'Php',
                                style: GoogleFonts.quicksand(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    letterSpacing: 0.2),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _priceController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d*')),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Enter price',
                                    fillColor: Colors.white,
                                    filled: true,
                                    hintStyle: GoogleFonts.quicksand(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter price';
                                    }
                                    enteredPrice = double.tryParse(value);
                                    if (enteredPrice == null ||
                                        enteredPrice! <= 0) {
                                      return 'Price must be a positive number';
                                    }
                                    if (enteredPrice! > balance) {
                                      return 'Price cannot exceed available balance';
                                    }
                                    return null;
                                  },
                                  style: GoogleFonts.quicksand(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                      // BUY BUTTON
                      Center(
                        child: SizedBox(
                          width: 300,
                          height: 48,
                          child: InkWell(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                // Get the category name and unit based on selection mode
                                String categoryName = _isCustomCategory
                                    ? _customCategoryController.text.trim()
                                    : _selectedCategory ?? '';
                                String unit = _isCustomCategory
                                    ? _customUnit ?? ''
                                    : inventory.firstWhere((item) =>
                                            item['category'] ==
                                            categoryName)['unit'] ??
                                        '';
                                double quantity =
                                    double.tryParse(_quantityController.text) ??
                                        0;
                                double newBalance = balance - enteredPrice;

                                // Show confirmation dialog
                                bool? confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Confirm Purchase',
                                        style: GoogleFonts.quicksand(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Please confirm the following details:',
                                            style: GoogleFonts.lato(),
                                          ),
                                          const SizedBox(height: 16),
                                          _DetailRow('Category:', categoryName),
                                          _DetailRow(
                                              'Quantity:', '$quantity $unit'),
                                          _DetailRow('Price:',
                                              'PHP ${enteredPrice?.toStringAsFixed(2)}'),
                                          const Divider(),
                                          _DetailRow(
                                            'New Balance:',
                                            'PHP ${newBalance.toStringAsFixed(2)}',
                                            isHighlighted: true,
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: Text(
                                            'Cancel',
                                            style: GoogleFonts.lato(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: Text(
                                            'Confirm',
                                            style: GoogleFonts.lato(
                                              color: const Color(0xfffe6600),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmed == true) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  try {
                                    if (_isCustomCategory) {
                                      categoryName =
                                          _customCategoryController.text.trim();
                                      unit = _customUnit ?? '';
                                      if (categoryName.isEmpty) {
                                        throw Exception(
                                            'Category name cannot be empty');
                                      }
                                      if (unit.isEmpty) {
                                        throw Exception(
                                            'Unit must be selected');
                                      }

                                      // Check if category already exists
                                      if (_categoryExists(
                                          categoryName, inventory)) {
                                        throw Exception(
                                            'Category "$categoryName" already exists. Please switch to "Select Category" mode to update existing items.');
                                      }

                                      await _inventoryController
                                          .uploadInventoryEntry(
                                        categoryName,
                                        double.parse(_quantityController.text),
                                        unit,
                                        widget.junkShopData['junkShopId'],
                                      );

                                      await _firestore
                                          .collection('junk_shops')
                                          .doc(
                                              widget.junkShopData['junkShopId'])
                                          .update({
                                        'junkShopBalance':
                                            balance - enteredPrice,
                                      });
                                    } else {
                                      if (_selectedCategory == null ||
                                          _selectedCategory!.isEmpty) {
                                        throw Exception(
                                            'Selected category cannot be empty');
                                      }
                                      categoryName = _selectedCategory!;

                                      final categoryIndex =
                                          inventory.indexWhere((item) =>
                                              item['category'] == categoryName);

                                      if (categoryIndex >= 0) {
                                        final existingItem =
                                            inventory[categoryIndex];
                                        unit = existingItem['unit'] ?? '';
                                        final updatedQuantity =
                                            (existingItem['stock'] ?? 0) +
                                                double.parse(
                                                    _quantityController.text);

                                        await _firestore
                                            .collection('junk_shops')
                                            .doc(widget
                                                .junkShopData['junkShopId'])
                                            .update({
                                          'junkShopInventory':
                                              FieldValue.arrayRemove(
                                                  [existingItem]),
                                        });

                                        final updatedItem = {
                                          ...existingItem,
                                          'stock': updatedQuantity,
                                        };

                                        await _firestore
                                            .collection('junk_shops')
                                            .doc(widget
                                                .junkShopData['junkShopId'])
                                            .update({
                                          'junkShopInventory':
                                              FieldValue.arrayUnion(
                                                  [updatedItem]),
                                          'junkShopBalance':
                                              balance - enteredPrice,
                                        });
                                      }
                                    }

                                    // Create transaction entry with quantity and unit
                                    if (categoryName.isNotEmpty &&
                                        unit.isNotEmpty) {
                                      final quantity = _quantityController.text;
                                      await _transactionController
                                          .uploadTransactionEntry(
                                        'Buy ($quantity $unit) $categoryName',
                                        -enteredPrice!,
                                        widget.junkShopData['junkShopId'],
                                      );
                                    }

                                    // Clear form after successful submission
                                    if (_isCustomCategory) {
                                      _customCategoryController.clear();
                                      setState(() {
                                        _customUnit = null;
                                      });
                                    } else {
                                      setState(() {
                                        _selectedCategory = null;
                                      });
                                    }
                                    _quantityController.clear();
                                    _priceController
                                        .clear(); // Clear price after successful purchase

                                    // Show success message
                                    _showSuccessSnackBar(
                                        'Purchase successful!');
                                  } catch (e) {
                                    _showErrorSnackBar(e);
                                  } finally {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
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
                                        "BUY",
                                        style: GoogleFonts.quicksand(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 2,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Helper widget for showing detail rows in the confirmation dialog
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _DetailRow(this.label, this.value, {this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.lato(
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
              color: isHighlighted ? const Color(0xfffe6600) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
