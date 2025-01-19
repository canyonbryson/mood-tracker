import 'package:flutter/material.dart';
import 'package:mood_tracker/calendar/calendar.dart';
import 'package:mood_tracker/login/login.dart';
import 'package:mood_tracker/patterns/patterns.dart';
import 'package:mood_tracker/profile/profile.dart';
import 'package:mood_tracker/services/auth.dart';
import 'package:mood_tracker/shared/shared.dart';
import 'package:mood_tracker/topics/topics.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        } else if (snapshot.hasError) {
          return const Center(
            child: ErrorMessage(),
          );
        } else if (snapshot.hasData) {
          /// If user is logged in, show the main shell (which includes Topics, etc.)
          return const MainScreen();
        } else {
          /// If user not logged in, show login screen
          return const Login();
        }
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class ErrorMessage extends StatelessWidget {
  final dynamic message;
  const ErrorMessage({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Text(message.toString());
  }
}



/// The main shell screen that holds:
/// - An IndexedStack of pages (Topics, Calendar, Patterns, Profile).
/// - A persistent BottomNavigationBar that stays in place on page changes.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  /// The pages for each bottom nav item
  final List<Widget> _pages = [
    const Topics(),    // index 0
    const Calendar(),  // index 1 (example placeholder)
    const PatternsPage(),  // index 2 (example placeholder)
    const Profile(),   // index 3 (example placeholder)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // This bottom bar never re-builds or re-animates out on page change
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
