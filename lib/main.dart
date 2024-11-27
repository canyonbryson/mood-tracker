import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mood_tracker/home/home.dart';
import 'package:mood_tracker/router.dart';
import 'package:mood_tracker/services/services.dart';
import 'package:mood_tracker/theme.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'error_boundary.dart'; // Import the ErrorBoundary

void main() {
  // Ensure Flutter bindings are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase inside runZonedGuarded for capturing async errors
  runZonedGuarded(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const App());
  }, (error, stackTrace) {
    // Handle errors outside the Flutter framework
    print('Caught Dart error: $error');
    print('Stack trace: $stackTrace');
    // Optionally, send errors to a logging service like Sentry or Firebase Crashlytics
  });

  // Set up Flutter framework error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    // Log the error details
    FlutterError.dumpErrorToConsole(details);
    // Optionally, send errors to a logging service
  };
}

/// We are using a StatefulWidget such that we only create the [Future] once,
/// no matter how many times our widget rebuild.
/// If we used a [StatelessWidget], in the event where [App] is rebuilt, that
/// would re-initialize FlutterFire and make our application re-enter loading state,
/// which is undesired.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    // Define a custom error widget to display when a widget fails to build
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Log the error details
      FlutterError.dumpErrorToConsole(details);
      // Return a user-friendly error widget
      return Scaffold(
        appBar: AppBar(
          title: const Text('Something Went Wrong'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'An unexpected error occurred.\nPlease restart the app.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    };

    return MultiProvider(
      providers: [
        FutureProvider<List<Report>>(
          create: (_) => FirestoreService().getReports(),
          initialData: [],
        ),
        // Add other providers here
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: appRoutes,
        theme: appTheme,
        home: const Home(),
        navigatorObservers: [
          // Optionally, add navigator observers for analytics
        ],
        builder: (context, child) {
          // Wrap the app with ErrorBoundary for widget error handling
          return ErrorBoundary(
            child: SafeArea(child: child!),
          );
        },
      ),
    );
  }
}