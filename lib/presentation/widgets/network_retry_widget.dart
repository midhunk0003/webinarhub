import 'package:flutter/material.dart';

class NetWorkRetry extends StatelessWidget {
  final VoidCallback onRetry;
  final String failureMessage;
  const NetWorkRetry({
    super.key,
    required this.onRetry,
    required this.failureMessage,
    this.userNameController,
    this.passwordController,
  });

  final TextEditingController? userNameController;
  final TextEditingController? passwordController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 60, color: Colors.red),
          SizedBox(height: 10),
          Text(
            failureMessage ?? "No internet connection",
            style: TextStyle(fontSize: 16, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh, color: Colors.white),
            label: Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
