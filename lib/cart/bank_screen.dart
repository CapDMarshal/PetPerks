import 'package:flutter/material.dart';

class BankScreen extends StatelessWidget {
  const BankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const _SearchAppBar(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        automaticallyImplyLeading: false, // <-- ADD THIS LINE TO REMOVE BACK BUTTON
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- 1. Popular Banks Title ---
          const Text(
            'Popular Banks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),

          // --- 2. Popular Banks Grid ---
          Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: const [
              _BankIcon(icon: Icons.account_balance),
              _BankIcon(icon: Icons.account_balance),
              _BankIcon(icon: Icons.account_balance),
              _BankIcon(icon: Icons.account_balance),
              _BankIcon(icon: Icons.account_balance),
              _BankIcon(icon: Icons.account_balance),
              _BankIcon(icon: Icons.account_balance),
              _BankIcon(icon: Icons.account_balance),
            ],
          ),
          const SizedBox(height: 24.0),

          // --- 3. All Banks Title ---
          const Text(
            'All Banks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),

          // --- 4. All Banks List (Two Columns) ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _BankListItem(name: 'Bank Of india'),
                    _BankListItem(name: 'Canara Bank'),
                    _BankListItem(name: 'IDFC Bank'),
                    _BankListItem(name: 'Catholic Syrian Bank'),
                    _BankListItem(name: 'City Union Bank'),
                    _BankListItem(name: 'Cosmos Bank'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Column 2
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _BankListItem(name: 'Bank Of Maharasthra'),
                    _BankListItem(name: 'HDFC Bank'),
                    _BankListItem(name: 'Catholic Syrian Bank'),
                    _BankListItem(name: 'Central Bank of India'),
                    _BankListItem(name: 'Corporation Bank'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32.0),

          // --- 5. Return Button ---
          OutlinedButton.icon(
            onPressed: () {
              // Navigates back to the payment screen
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, size: 20),
            label: const Text('Return'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
              side: BorderSide(color: Colors.grey[400]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- HELPER WIDGET for the Search AppBar ---
class _SearchAppBar extends StatelessWidget {
  const _SearchAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search by bank name',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

// --- HELPER WIDGET for Popular Bank Icons ---
class _BankIcon extends StatelessWidget {
  final IconData icon;
  const _BankIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    final double size = (MediaQuery.of(context).size.width - 32 - 32) / 3;

    return Container(
      width: size,
      height: size / 1.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.blue, size: 36),
    );
  }
}

// --- HELPER WIDGET for the "All Banks" list items ---
class _BankListItem extends StatelessWidget {
  final String name;
  const _BankListItem({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.arrow_forward, size: 16, color: Colors.black54),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}