// error_boundary.dart

import 'package:flutter/material.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    // Override Flutter's error handling for this subtree
    FlutterError.onError = (FlutterErrorDetails details) {
      setState(() {
        hasError = true;
      });
      // Log the error details
      FlutterError.dumpErrorToConsole(details);
      // Optionally, send errors to a logging service
    };
  }

  @override
  void dispose() {
    // Restore the original error handler when disposing
    FlutterError.onError = FlutterError.dumpErrorToConsole;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('An Error Occurred'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Something went wrong.\nPlease restart the app.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
