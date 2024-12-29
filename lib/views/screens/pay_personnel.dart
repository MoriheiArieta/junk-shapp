import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:junk_shapp/controllers/transaction_controller.dart';

class PayPersonnel extends StatefulWidget {
  final dynamic junkShopData;

  const PayPersonnel({super.key, this.junkShopData});

  @override
  State<PayPersonnel> createState() => _PayPersonnelState();
}

class _PayPersonnelState extends State<PayPersonnel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _paymentController = TextEditingController();
  final TransactionController _transactionController = TransactionController();

  String? _selectedPersonnel;
  num? _paymentAmount;

  bool _isLoading = false;

  Future<List<String>> _fetchPersonnelNames(List<dynamic> junkShopStaff) async {
    List<String> names = [];
    for (String staffUid in junkShopStaff) {
      try {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(staffUid).get();
        if (userSnapshot.exists) {
          names.add(userSnapshot['fullName']);
        }
      } catch (e) {
        debugPrint('Error fetching user: $e');
      }
    }
    return names;
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

  _pop() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xffff6600),
        centerTitle: true,
        title: Text(
          "Pay Personnel",
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
            return const Center(child: Text('No personnel data available'));
          }

          final junkShopData = snapshot.data!.data() as Map<String, dynamic>;
          final balance = junkShopData['junkShopBalance'] ?? 0;
          final junkShopStaff =
              List<String>.from(junkShopData['junkShopStaff'] ?? []);

          return FutureBuilder<List<String>>(
            future: _fetchPersonnelNames(junkShopStaff),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final personnelNames = futureSnapshot.data ?? [];

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
                          const SizedBox(height: 16),

                          // PERSONNEL NAMES DROPDOWN
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Select a Personnel",
                              style: GoogleFonts.quicksand(
                                fontSize: 16,
                                letterSpacing: 0.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          PersonnelAutocompleteDropdown(
                            categories: personnelNames,
                            selectedCategory: _selectedPersonnel,
                            onSelected: (String? value) {
                              _selectedPersonnel = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select personnel';
                              }
                              if (!personnelNames.contains(value)) {
                                return 'Please select valid personnel';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // PAYMENT AMOUNT
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Payment Amount",
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
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _paymentController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d*')),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Enter payment amount',
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
                                    _paymentAmount = double.tryParse(value);

                                    if (_paymentAmount == null ||
                                        _paymentAmount! <= 0) {
                                      return 'Payment must be a positive number';
                                    }

                                    if (_paymentAmount! > balance) {
                                      return 'Payment must not exceed available balance';
                                    }

                                    return null;
                                  },
                                  style: GoogleFonts.quicksand(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // PAY BUTTON
                          Center(
                            child: SizedBox(
                              width: 300,
                              height: 48,
                              child: InkWell(
                                onTap: () async {
                                  if (_formKey.currentState!.validate()) {
                                    // NEW BALANCE UPON PAYMENT
                                    double newBalance =
                                        balance - _paymentAmount;

                                    // CONFIRMATION DIALOG
                                    bool? confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            'Confirm Payment',
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
                                              _DetailRow('Personnel:',
                                                  _selectedPersonnel!),
                                              _DetailRow('Payment Amount:',
                                                  'PHP ${_paymentAmount!.toStringAsFixed(2)}'),
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
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: Text(
                                                'Cancel',
                                                style: GoogleFonts.lato(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: Text(
                                                'Confirm',
                                                style: GoogleFonts.lato(
                                                  color:
                                                      const Color(0xfffe6600),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    // ON CONFIRM
                                    if (confirmed == true) {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      try {
                                        // record transaction
                                        String result =
                                            await _transactionController
                                                .uploadTransactionEntry(
                                                    'Pay $_selectedPersonnel',
                                                    -_paymentAmount!,
                                                    widget.junkShopData[
                                                        'junkShopId']);
                                        if (result == 'pass') {
                                          // UPDATE JUNK SHOP BALANCE
                                          await _firestore
                                              .collection('junk_shops')
                                              .doc(widget
                                                  .junkShopData['junkShopId'])
                                              .update({
                                            'junkShopBalance':
                                                balance - _paymentAmount!
                                          });
                                        }

                                        // CLEAR FORMS AFTER SUCCESSFUL SUBMISSION
                                        setState(() {
                                          _paymentController.clear();
                                          _selectedPersonnel = null;
                                        });

                                        _showSuccessSnackBar(
                                            "Payment successful!");
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
                                            color: Colors.white)
                                        : Text(
                                            "PAY",
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PersonnelAutocompleteDropdown extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String?) onSelected;
  final String? Function(String?)? validator;

  const PersonnelAutocompleteDropdown({
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
                ? 'No personnel available'
                : 'Type or select a personnel',
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
