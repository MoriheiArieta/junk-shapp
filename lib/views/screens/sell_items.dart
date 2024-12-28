import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:junk_shapp/controllers/transaction_controller.dart';

class SellItems extends StatefulWidget {
  final dynamic junkShopData;

  const SellItems({super.key, this.junkShopData});

  @override
  State<SellItems> createState() => _SellItemsState();
}

class _SellItemsState extends State<SellItems> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();
  final TransactionController _transactionController = TransactionController();
  final TextEditingController _priceController = TextEditingController();

  String? _selectedCategory;
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

  _pop() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
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
                        'Current Balance: ₱${balance.toStringAsFixed(2)}',
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      //  LABEL +TOGGLE SWITCH
                      Text(
                        'Select Category:',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // CATEGORY DROPDOWN/TEXT FIELD
                      // const SizedBox(height: 8),
                      CategoryAutocompleteFormField(
                        categories: categoryList,
                        selectedCategory: _selectedCategory,
                        onSelected: (String? value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          if (!categoryList.contains(value)) {
                            return 'Please select a valid category';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // AVAILABLE STOCK AND UNIT LABEL
                      if (_selectedCategory != null)
                        Row(
                          children: [
                            Text(
                              'Available Stock: ',
                              style: GoogleFonts.quicksand(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${inventory.firstWhere((item) => item['category'] == _selectedCategory)['stock']} ${inventory.firstWhere((item) => item['category'] == _selectedCategory)['unit']}',
                              style: GoogleFonts.quicksand(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.green,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),

                      // QUANTITY AND PRICE
                      Column(
                        children: [
                          // QUANTITY
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Quantity to Sell",
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
                                    if (double.tryParse(value) == null ||
                                        double.parse(value) <= 0) {
                                      return 'Quantity must be a positive number';
                                    }

                                    // check if quantity is greater than stock
                                    if (_selectedCategory != null) {
                                      final categoryIndex =
                                          inventory.indexWhere((item) =>
                                              item['category'] ==
                                              _selectedCategory);
                                      if (categoryIndex >= 0) {
                                        final stock = inventory[categoryIndex]
                                                ['stock'] ??
                                            0;
                                        if (double.parse(value) > stock) {
                                          return 'Quantity exceeds available stock';
                                        }
                                      }
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
                              if (_selectedCategory != null)
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
                            ],
                          ),

                          const SizedBox(height: 16),

                          // PRICE
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Selling Price",
                              style: GoogleFonts.quicksand(
                                fontSize: 16,
                                letterSpacing: 0.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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

                      // SELL BUTTON
                      Center(
                        child: SizedBox(
                          width: 300,
                          height: 48,
                          child: InkWell(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                // Get the category name and unit based on selection mode
                                String categoryName = _selectedCategory!;
                                String unit = inventory.firstWhere((item) =>
                                    item['category']! == categoryName)['unit']!;
                                double quantity =
                                    double.tryParse(_quantityController.text) ??
                                        0;
                                double newBalance = balance + enteredPrice;

                                // Show confirmation dialog
                                bool? confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Confirm Sale',
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
                                    if (_selectedCategory == null ||
                                        _selectedCategory!.isEmpty) {
                                      throw Exception(
                                          'Selected category cannot be empty');
                                    }
                                    categoryName = _selectedCategory!;

                                    final categoryIndex = inventory.indexWhere(
                                        (item) =>
                                            item['category'] == categoryName);

                                    if (categoryIndex >= 0) {
                                      final existingItem =
                                          inventory[categoryIndex];
                                      unit = existingItem['unit'] ?? '';
                                      final updatedQuantity =
                                          (existingItem['stock'] ?? 0) -
                                              double.parse(
                                                  _quantityController.text);

                                      await _firestore
                                          .collection('junk_shops')
                                          .doc(
                                              widget.junkShopData['junkShopId'])
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
                                          .doc(
                                              widget.junkShopData['junkShopId'])
                                          .update({
                                        'junkShopInventory':
                                            FieldValue.arrayUnion(
                                                [updatedItem]),
                                        'junkShopBalance':
                                            balance + enteredPrice,
                                      });
                                    }

                                    // Create transaction entry with quantity and unit
                                    if (categoryName.isNotEmpty &&
                                        unit.isNotEmpty) {
                                      final quantity = _quantityController.text;
                                      await _transactionController
                                          .uploadTransactionEntry(
                                        'Sell ($quantity $unit) $categoryName',
                                        enteredPrice!,
                                        widget.junkShopData['junkShopId'],
                                      );
                                    }

                                    // Clear form after successful submission

                                    setState(() {
                                      _selectedCategory = null;
                                    });

                                    _quantityController.clear();
                                    _priceController
                                        .clear(); // Clear price after successful purchase

                                    // Show success message
                                    _showSuccessSnackBar('Sale successful!');
                                  } catch (e) {
                                    _showErrorSnackBar(e);
                                  } finally {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    _pop();
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
                                        "SELL",
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

class CategoryAutocompleteFormField extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String?) onSelected;
  final String? Function(String?)? validator;

  const CategoryAutocompleteFormField({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: selectedCategory ?? ''),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return categories;
        }
        return categories.where((category) => category
            .toLowerCase()
            .contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: onSelected,
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController controller,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: categories.isEmpty
                ? 'No categories available'
                : 'Type or select a category',
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
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_drop_down),
              color: const Color(0xffff6600),
              onPressed: () {
                if (!focusNode.hasFocus) {
                  focusNode.requestFocus();
                }
              },
            ),
          ),
          validator: validator,
          style: GoogleFonts.quicksand(
            color: Colors.black,
          ),
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        void Function(String) onSelected,
        Iterable<String> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: Container(
              width: MediaQuery.of(context).size.width - 32,
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return InkWell(
                    onTap: () {
                      onSelected(option);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        option,
                        style: GoogleFonts.quicksand(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
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
