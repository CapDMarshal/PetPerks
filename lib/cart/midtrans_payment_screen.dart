import 'package:flutter/material.dart';
import 'package:midtrans_snap/midtrans_snap.dart';
import 'package:midtrans_snap/models.dart';

class MidtransPaymentScreen extends StatefulWidget {
  final String snapToken;
  final String
      clientKey; // In production, avoid passing this if possible, but required by widget

  const MidtransPaymentScreen({
    super.key,
    required this.snapToken,
    required this.clientKey,
  });

  @override
  State<MidtransPaymentScreen> createState() => _MidtransPaymentScreenState();
}

class _MidtransPaymentScreenState extends State<MidtransPaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: MidtransSnap(
        mode: MidtransEnvironment.sandbox, // Switch to .production when ready
        token: widget.snapToken,
        midtransClientKey: widget.clientKey,
        onPageFinished: (url) {
          debugPrint('Midtrans Page Loaded: $url');
        },
        onPageStarted: (url) {
          debugPrint('Midtrans Loading: $url');
        },
        onResponse: (result) {
          // Result comes as a JSON object
          debugPrint('Midtrans Result: ${result.toJson()}');
          /*
            Possible transaction_status:
            - capture/settlement: Success
            - pending: Pending
            - deny/expire/cancel: Failed
           */

          Navigator.pop(context, result.toJson());
        },
      ),
    );
  }
}
