import 'package:flutter/material.dart';
import 'newcard_screen.dart';
import 'bank_screen.dart';
import '../services/api_service.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  // Unused but kept for structure if needed later; logic now relies on _groupValue returning full object.
  // String? _selectedPaymentMethodId;

  List<Map<String, dynamic>> _savedCards = [];
  Map<String, dynamic>? _savedUpi;
  Map<String, dynamic>? _savedWallet;

  bool _isLoading = true;
  final DataService _dataService = DataService();

  // Controllers for UPI and Wallet
  final TextEditingController _upiController = TextEditingController();
  final TextEditingController _walletController = TextEditingController();

  // Selection state
  String _groupValue = '0';

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  @override
  void dispose() {
    _upiController.dispose();
    _walletController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    final methods = await _dataService.getPaymentMethods();
    if (mounted) {
      setState(() {
        // Filter Cards
        _savedCards =
            methods.where((m) => m['type_payment'] == 'cards').toList();

        // Find existing UPI
        try {
          _savedUpi = methods.firstWhere((m) => m['type_payment'] == 'upi');
          _upiController.text = _savedUpi!['upi_id'] ?? '';
        } catch (_) {
          _savedUpi = null;
        }

        // Find existing Wallet
        try {
          _savedWallet = methods.firstWhere(
            (m) => m['type_payment'] == 'wallet',
          );
          _walletController.text = _savedWallet!['wallet_id'] ?? '+91';
        } catch (_) {
          _savedWallet = null;
        }

        _isLoading = false;

        // Auto selection logic
        if (_savedCards.isNotEmpty) {
          _groupValue = _savedCards.first['id'];
        } else {
          _groupValue = '99'; // Default to COD
        }
      });
    }
  }

  Future<void> _handleUpiContinue() async {
    final enteredId = _upiController.text.trim();
    if (enteredId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a UPI ID')));
      return;
    }

    // Check if matches existing saved UPI
    if (_savedUpi != null && _savedUpi!['upi_id'] == enteredId) {
      Navigator.pop(context, _savedUpi);
      return;
    }

    // Save as new UPI
    setState(() => _isLoading = true);
    try {
      final newMethod = await _dataService.addPaymentMethod(
        type: 'upi',
        upiId: enteredId,
      );
      if (mounted) {
        Navigator.pop(context, newMethod);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save UPI: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleWalletContinue() async {
    final enteredId = _walletController.text.trim();
    if (enteredId.isEmpty || enteredId == '+91') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Wallet ID/Number')),
      );
      return;
    }

    // Check if matches existing saved Wallet
    if (_savedWallet != null && _savedWallet!['wallet_id'] == enteredId) {
      Navigator.pop(context, _savedWallet);
      return;
    }

    // Save as new Wallet
    setState(() => _isLoading = true);
    try {
      final newMethod = await _dataService.addPaymentMethod(
        type: 'wallet',
        walletId: enteredId,
      );
      if (mounted) {
        Navigator.pop(context, newMethod);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save Wallet: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          // --- "Credit/Debit Card" Row ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Credit/Debit Card',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewCardScreen(),
                      ),
                    );
                    if (result == true) {
                      _loadPaymentMethods();
                    }
                  },
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.black,
                  ),
                  label: const Text(
                    'Add Card',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),

          // --- HORIZONTAL CARD LIST ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                if (_isLoading &&
                    _savedCards.isEmpty) // Show loading only if init
                  const Center(child: CircularProgressIndicator())
                else if (_savedCards.isEmpty)
                  Container(
                    width: 300,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: const Text('No cards added'),
                  )
                else
                  ..._savedCards.map((card) {
                    final String cardId = card['id'];
                    final bool isSelected = _groupValue == cardId;

                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: _CreditCardWidget(
                        value: cardId,
                        groupValue: _groupValue,
                        onChanged: (val) {
                          setState(() {
                            _groupValue = val!;
                          });
                        },
                        cardType: 'CREDIT CARD',
                        cardNumber: card['card_number'] ?? '****',
                        cardHolder: card['card_name'] ?? 'HOLDER',
                        expiryDate: card['expiry_date'] ?? '--/--',
                        cvv: '***',
                        color: isSelected ? Colors.black : Colors.grey[700]!,
                        logo: const Text(
                          'VISA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),

          // --- EXPANDABLE PAYMENT OPTIONS ---
          const SizedBox(height: 24.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // 1. Cash on Delivery
                _ExpandablePaymentOption(
                  id: '99',
                  groupValue: _groupValue,
                  onChanged: (id) {
                    setState(() {
                      _groupValue = id!;
                    });
                  },
                  icon: Icons.attach_money,
                  title: 'Cash on Delivery(Cash/UPI)',
                  expandedContent: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Carry on your cash payment..',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Thanx!',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // 2. Google Pay / UPI
                _ExpandablePaymentOption(
                  id: '100',
                  groupValue: _groupValue,
                  onChanged: (id) {
                    setState(() {
                      _groupValue = id!;
                      // Optionally autofill if existing when strictly selected
                    });
                  },
                  icon: Icons.payment,
                  title: 'Google Pay/Phone Pay/BHIM UPI',
                  expandedContent: _UpiContent(
                    controller: _upiController,
                    onContinue: _handleUpiContinue,
                  ),
                ),
                const SizedBox(height: 16.0),

                // 3. Payments/Wallet
                _ExpandablePaymentOption(
                  id: '101',
                  groupValue: _groupValue,
                  onChanged: (id) {
                    setState(() {
                      _groupValue = id!;
                    });
                  },
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Payments/Wallet',
                  expandedContent: _WalletContent(
                    controller: _walletController,
                    onContinue: _handleWalletContinue,
                  ),
                ),
                const SizedBox(height: 16.0),

                // 4. Netbanking
                _ExpandablePaymentOption(
                  id: '102',
                  groupValue: _groupValue,
                  onChanged: (id) {
                    setState(() {
                      _groupValue = id!;
                    });
                  },
                  icon: Icons.account_balance_outlined,
                  title: 'Netbanking',
                  expandedContent: const _NetbankingContent(),
                ),
                const SizedBox(height: 16.0),

                // 5. Midtrans
                _ExpandablePaymentOption(
                  id: '103',
                  groupValue: _groupValue,
                  onChanged: (id) {
                    setState(() {
                      _groupValue = id!;
                    });
                  },
                  icon: Icons.language,
                  title: 'Online Payment (Midtrans)',
                  expandedContent: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Pay securely via Midtrans (card, wallet, etc.)',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            // "Continue" logic for main screen
            // If the user selected 'cards', we find it.
            // If they selected '99', '100', '101', '102', we return that.
            // Note: If they selected 100/101 but didn't click content's "Continue",
            // we probably should assume they want to use the currently entered values?
            // BUT per request "clicking continue on them [content] should work like main continue".
            // So main continue handles 'saved' selections or static ones.
            // If they typed a new UPI but clicked MAIN continue, that's ambiguous.
            // For now, let's stick to the previous robust logic plus UPI/Wallet handling if they are selected.

            Map<String, dynamic>? selectedMethod;

            // 1. Check if cards
            try {
              selectedMethod = _savedCards.firstWhere(
                (m) => m['id'] == _groupValue,
              );
            } catch (_) {}

            // 2. Check if it matches our saved UPI id (which would be the groupValue if we assigned it that way, but we use '100')
            // Actually, if we use '100' for UPI, we return a static object OR the saved upi object if available?

            if (selectedMethod != null) {
              Navigator.pop(context, selectedMethod);
              return;
            }

            // Static / Other handling
            if (_groupValue == '100') {
              // If valid existing UPI, return it. Else return static generic.
              if (_savedUpi != null) {
                Navigator.pop(context, _savedUpi);
              } else {
                Navigator.pop(context, {
                  'id': '100',
                  'type_payment': 'static',
                  'title': 'UPI',
                });
              }
              return;
            }
            if (_groupValue == '101') {
              if (_savedWallet != null) {
                Navigator.pop(context, _savedWallet);
              } else {
                Navigator.pop(context, {
                  'id': '101',
                  'type_payment': 'static',
                  'title': 'Wallet',
                });
              }
              return;
            }

            // Fallback for COD / Netbanking
            String title = 'Unknown';
            if (_groupValue == '99') title = 'Cash on Delivery';
            if (_groupValue == '102') title = 'Netbanking';
            if (_groupValue == '103') {
              title = 'Midtrans';
              Navigator.pop(context, {
                'id': _groupValue,
                'type_payment': 'midtrans', // Custom type
                'title': title,
              });
              return;
            }

            Navigator.pop(context, {
              'id': _groupValue,
              'type_payment': 'static',
              'title': title,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text('Continue'),
        ),
      ),
    );
  }
}

// --- WIDGETS ---

class _CreditCardWidget extends StatelessWidget {
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;
  final String cardType;
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;
  final String cvv;
  final Color color;
  final Widget logo;

  const _CreditCardWidget({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.cardType,
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
    required this.cvv,
    required this.color,
    required this.logo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Radio<String>(
                    value: value,
                    groupValue: groupValue,
                    onChanged: onChanged,
                    activeColor: Colors.white,
                    fillColor: MaterialStateProperty.all(Colors.white),
                  ),
                  Text(
                    cardType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              logo,
            ],
          ),
          const SizedBox(height: 20.0),
          Text(
            cardNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                cardHolder,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EXP',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        expiryDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CVV',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        cvv,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpandablePaymentOption extends StatelessWidget {
  final String id;
  final String groupValue;
  final ValueChanged<String?> onChanged;
  final IconData icon;
  final String title;
  final Widget expandedContent;

  const _ExpandablePaymentOption({
    required this.id,
    required this.groupValue,
    required this.onChanged,
    required this.icon,
    required this.title,
    required this.expandedContent,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = (id == groupValue);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isSelected ? Colors.black : Colors.grey[400]!,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.5),
        child: InkWell(
          onTap: () {
            onChanged(id);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 24.0),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Radio<String>(
                      value: id,
                      groupValue: groupValue,
                      onChanged: onChanged,
                      activeColor: Colors.black,
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: Container(height: 0),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(
                        color: Colors.black,
                        thickness: 1,
                        height: 24.0,
                      ),
                      expandedContent,
                    ],
                  ),
                  crossFadeState: isSelected
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NetbankingContent extends StatelessWidget {
  const _NetbankingContent();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BankScreen()),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 50),
        side: BorderSide(color: Colors.grey[400]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      child: const Text(
        'Netbanking',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _WalletContent extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onContinue;

  const _WalletContent({required this.controller, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Link Your Wallet',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12.0),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: '+91',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.black, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
          ),
        ),
        const SizedBox(height: 12.0),
        ElevatedButton(
          onPressed: onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text(
            'Continue',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _UpiContent extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onContinue;

  const _UpiContent({required this.controller, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Link via UPI',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12.0),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter your UPI ID',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.black, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
          ),
        ),
        const SizedBox(height: 12.0),
        ElevatedButton(
          onPressed: onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text(
            'Continue',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12.0),
        Row(
          children: [
            const Icon(Icons.shield_outlined, color: Colors.green, size: 20.0),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                'Your UPI ID Will be encrypted and is 100% safe with us.',
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
