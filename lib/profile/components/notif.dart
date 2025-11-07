import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      NotificationItem(
        title: 'New Arrivals Alert!',
        date: '15 July 2023',
        color: Colors.yellow[700]!,
        iconColor: Colors.yellow[700]!,
      ),
      NotificationItem(
        title: 'Flash Sale Announcement',
        date: '21 July 2023',
        color: Colors.teal[400]!,
        iconColor: Colors.teal[400]!,
      ),
      NotificationItem(
        title: 'Exclusive Discounts Inside',
        date: '10 March 2023',
        color: Colors.red[700]!,
        iconColor: Colors.red[700]!,
      ),
      NotificationItem(
        title: 'Limited Stock - Act Fast!',
        date: '20 September 2023',
        color: Colors.red[300]!,
        iconColor: Colors.red[300]!,
      ),
      NotificationItem(
        title: 'Get Ready to Shop',
        date: '15 July 2023',
        color: Colors.purple[400]!,
        iconColor: Colors.purple[400]!,
      ),
      NotificationItem(
        title: 'Don\'t Miss Out on Savings',
        date: '24 July 2023',
        color: Colors.yellow[700]!,
        iconColor: Colors.yellow[700]!,
      ),
      NotificationItem(
        title: 'Special Offer Just for You',
        date: '28 August 2023',
        color: Colors.teal[400]!,
        iconColor: Colors.teal[400]!,
      ),
      NotificationItem(
        title: 'Don\'t Miss Out on Savings',
        date: '15 July 2023',
        color: Colors.red[700]!,
        iconColor: Colors.red[700]!,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications (12)',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 1,
          color: Colors.black12,
        ),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(
            context,
            notification.title,
            notification.date,
            notification.color,
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    String title,
    String date,
    Color backgroundColor,
  ) {
    return Container(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          // Handle notification tap
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.pets,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String date;
  final Color color;
  final Color iconColor;

  NotificationItem({
    required this.title,
    required this.date,
    required this.color,
    required this.iconColor,
  });
}
