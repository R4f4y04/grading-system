import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final Future<Map<String, dynamic>> Function() loadingTask;
  final Widget Function(Map<String, dynamic>) nextPage;

  const LoadingScreen({
    required this.loadingTask,
    required this.nextPage,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: loadingTask(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => nextPage(snapshot.data!),
              ),
            );
          });
          return Container();
        }
      },
    );
  }
}
