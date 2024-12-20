import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final Future<void> Function() loadingTask;
  final Widget nextPage;

  const LoadingScreen({
    required this.loadingTask,
    required this.nextPage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: loadingTask(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "Processing...",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                "An error occurred: ${snapshot.error}",
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          );
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => nextPage),
            );
          });
          return Scaffold(body: SizedBox.shrink()); // Placeholder
        }
      },
    );
  }
}
