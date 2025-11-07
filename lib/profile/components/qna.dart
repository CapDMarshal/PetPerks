import 'package:flutter/material.dart';

class QnAPage extends StatefulWidget {
  const QnAPage({super.key});

  @override
  State<QnAPage> createState() => _QnAPageState();
}

class _QnAPageState extends State<QnAPage> {
  final List<QnAItem> _qnaItems = [
    QnAItem(
      question: 'What is included with my purchase?',
      answer:
          'Package have the HTML files, SCSS files, CSS files, JS files, Well Define Documentation, Fonts and Icons, Responsive Designs, Image Assets, Customization Options, and many more.',
      isExpanded: true,
    ),
    QnAItem(
      question: 'What features does PetPerks offer?',
      answer:
          'PetPerks offers a wide range of features including online shopping for pet supplies, order tracking, coupons and discounts, saved addresses, multiple payment options, and customer support.',
      isExpanded: false,
    ),
    QnAItem(
      question: 'Can I customize the template\'s design?',
      answer:
          'Yes, you can fully customize the template\'s design including colors, fonts, layouts, and components to match your brand identity.',
      isExpanded: false,
    ),
    QnAItem(
      question: 'Is the template SEO-friendly?',
      answer:
          'Yes, the template is built with SEO best practices in mind, including proper HTML structure, meta tags, and fast loading times.',
      isExpanded: false,
    ),
    QnAItem(
      question: 'Are there pre-designed page templates included?',
      answer:
          'Yes, the package includes multiple pre-designed page templates for common pages like home, products, cart, checkout, profile, and more.',
      isExpanded: false,
    ),
    QnAItem(
      question: 'Does PetPerks provide customer support?',
      answer:
          'Yes, we provide comprehensive customer support through email, live chat, and phone. Our support team is available 24/7 to assist you.',
      isExpanded: false,
    ),
    QnAItem(
      question: 'Is coding knowledge required to use PetPerks?',
      answer:
          'Basic HTML, CSS, and JavaScript knowledge is helpful but not required. The template is well-documented and easy to customize.',
      isExpanded: false,
    ),
    QnAItem(
      question: 'How can I get started with PetPerks?',
      answer:
          'Simply download the package, extract the files, and follow the documentation to get started. You can customize the template according to your needs.',
      isExpanded: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Questions & Answers',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _qnaItems.length,
        itemBuilder: (context, index) {
          final item = _qnaItems[index];
          return _buildQnACard(item, index);
        },
      ),
    );
  }

  Widget _buildQnACard(QnAItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: item.isExpanded ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            item.question,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: item.isExpanded ? Colors.white : Colors.black,
            ),
          ),
          trailing: Icon(
            item.isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: item.isExpanded ? Colors.white : Colors.black,
            size: 20,
          ),
          initiallyExpanded: item.isExpanded,
          onExpansionChanged: (bool expanded) {
            setState(() {
              // Collapse all items
              for (var qna in _qnaItems) {
                qna.isExpanded = false;
              }
              // Expand the current item
              item.isExpanded = expanded;
            });
          },
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                border: Border.all(color: Colors.transparent),
              ),
              child: Text(
                item.answer,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QnAItem {
  final String question;
  final String answer;
  bool isExpanded;

  QnAItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}
