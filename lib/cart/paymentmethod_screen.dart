import 'package:flutter/material.dart';
import 'newcard_screen.dart';
import 'bank_screen.dart'; // <-- 1. ADD THIS IMPORT

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int _selectedCardId = 0;

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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewCardScreen(),
                      ),
                    );
                  },
                  icon:
                      const Icon(Icons.add_circle_outline, color: Colors.black),
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
                _CreditCardWidget(
                  cardId: 0,
                  groupValue: _selectedCardId,
                  onChanged: (id) {
                    setState(() {
                      _selectedCardId = id!;
                    });
                  },
                  cardType: 'CREDIT CARD',
                  cardNumber: '**** **** **** 4532',
                  cardHolder: 'ROOPA SMITH',
                  expiryDate: '14/07',
                  cvv: '012',
                  color: Colors.black,
                  logo: const Text(
                    'VISA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                _CreditCardWidget(
                  cardId: 1,
                  groupValue: _selectedCardId,
                  onChanged: (id) {
                    setState(() {
                      _selectedCardId = id!;
                    });
                  },
                  cardType: 'DEBIT CARD',
                  cardNumber: '**** **** **** 5678',
                  cardHolder: 'ROOPA SMITH',
                  expiryDate: '12/08',
                  cvv: '321',
                  color: Colors.grey[700]!,
                  logo: const Text(
                    'VISA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
                  id: 99,
                  groupValue: _selectedCardId,
                  onChanged: (id) {
                    setState(() {
                      _selectedCardId = id!;
                    });
                  },
                  icon: Icons.attach_money,
                  title: 'Cash on Delivery(Cash/UPI)',
                  expandedContent: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Carry on your cash payment..',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Thanx!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // 2. Google Pay / UPI
                _ExpandablePaymentOption(
                  id: 100,
                  groupValue: _selectedCardId,
                  onChanged: (id) {
                    setState(() {
                      _selectedCardId = id!;
                    });
                  },
                  icon: Icons.payment,
                  title: 'Google Pay/Phone Pay/BHIM UPI',
                  expandedContent: const _UpiContent(),
                ),
                const SizedBox(height: 16.0),

                // 3. Payments/Wallet
                _ExpandablePaymentOption(
                  id: 101,
                  groupValue: _selectedCardId,
                  onChanged: (id) {
                    setState(() {
                      _selectedCardId = id!;
                    });
                  },
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Payments/Wallet',
                  expandedContent: const _WalletContent(),
                ),
                const SizedBox(height: 16.0),

                // 4. Netbanking
                _ExpandablePaymentOption(
                  id: 102,
                  groupValue: _selectedCardId,
                  onChanged: (id) {
                    setState(() {
                      _selectedCardId = id!;
                    });
                  },
                  icon: Icons.account_balance_outlined,
                  title: 'Netbanking',
                  expandedContent: const _NetbankingContent(),
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
            print('Continue pressed! Selected option ID: $_selectedCardId');
            Navigator.pop(context);
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

// --- _CreditCardWidget (Unchanged) ---
class _CreditCardWidget extends StatelessWidget {
  final int cardId;
  final int groupValue;
  final ValueChanged<int?> onChanged;
  final String cardType;
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;
  final String cvv;
  final Color color;
  final Widget logo;

  const _CreditCardWidget({
    required this.cardId,
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
                  Radio<int>(
                    value: cardId,
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

// --- _ExpandablePaymentOption (Unchanged) ---
class _ExpandablePaymentOption extends StatelessWidget {
  final int id;
  final int groupValue;
  final ValueChanged<int?> onChanged;
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
                    Radio<int>(
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

// --- _NetbankingContent (MODIFIED) ---
class _NetbankingContent extends StatelessWidget {
  const _NetbankingContent();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      // --- 2. MODIFIED OnPressed ---
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BankScreen(),
          ),
        );
      },
      // --- END MODIFICATION ---
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 50),
        side: BorderSide(color: Colors.grey[400]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: const Text(
        'Netbanking',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// --- _WalletContent (Unchanged) ---
class _WalletContent extends StatelessWidget {
  const _WalletContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Link Your Wallet',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12.0),
        TextFormField(
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
          onPressed: () {},
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

// --- _UpiContent (Unchanged) ---
class _UpiContent extends StatelessWidget {
  const _UpiContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Link via UPI',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12.0),
        TextFormField(
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
          onPressed: () {},
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
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}