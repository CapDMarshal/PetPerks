import 'package:flutter/material.dart';
import '../search/search_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Sample notification data
  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'New Arrivals Alert!',
      'date': '15 July 2023',
      'avatar': 'assets/beagle.jpg',
    },
    {
      'title': 'Flash Sale Announcement',
      'date': '21 July 2023',
      'avatar': 'assets/labrador.jpeg',
    },
    {
      'title': 'Exclusive Discounts Inside',
      'date': '10 March 2023',
      'avatar': 'assets/poodle.jpg',
    },
    {
      'title': 'Limited Stock - Act Fast!',
      'date': '20 September 2023',
      'avatar': 'assets/golden_retriever.jpg',
    },
    {
      'title': 'Get Ready to Shop',
      'date': '15 July 2023',
      'avatar': 'assets/dog.jpg',
    },
    {
      'title': 'Don\'t Miss Out on Savings',
      'date': '24 July 2023',
      'avatar': 'assets/beagle.jpg',
    },
    {
      'title': 'Special Offer Just for You',
      'date': '28 August 2023',
      'avatar': 'assets/labrador.jpeg',
    },
    {
      'title': 'Don\'t Miss Out on Savings',
      'date': '15 July 2023',
      'avatar': 'assets/poodle.jpg',
    },
    {
      'title': 'Get Ready to Shop',
      'date': '15 July 2023',
      'avatar': 'assets/golden_retriever.jpg',
    },
    {
      'title': 'Special Offer Just for You',
      'date': '15 July 2023',
      'avatar': 'assets/dog.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications (${notifications.length})',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          indent: 76,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Dismissible(
            key: Key('notification_$index'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 28,
              ),
            ),
            onDismissed: (direction) {
              setState(() {
                notifications.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${notification['title']} dismissed'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: _buildNotificationItem(notification),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return InkWell(
      onTap: () {
        // Handle notification tap
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opened: ${notification['title']}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade200,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  notification['avatar'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade300,
                    child: Icon(
                      Icons.pets,
                      color: Colors.grey.shade600,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification['title'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['date'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
