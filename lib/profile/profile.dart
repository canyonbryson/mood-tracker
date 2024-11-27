import 'package:flutter/material.dart';
import 'package:mood_tracker/home/home.dart';
import 'package:mood_tracker/services/services.dart';
import 'package:mood_tracker/shared/bottom_nav.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    var user = AuthService().user;

    if (user != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text('Profile'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50.0, bottom: 30),
                child: Text('Hello Sabrina, I love you!'),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  child: const Text('Edit Quiz'),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/edit');
                  },
                ),
              ),
              ElevatedButton(
                child: const Text('Logout'),
                onPressed: () async {
                  await AuthService().signOut();
                  if (mounted) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (route) => false);
                  }
                },
              ),
              const Spacer(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(
        currentIndex: 2, // Index for Topics
        onTap: (index) {
          if (index == 2) return; // Already on Topics
          switch (index) {
            case 1:
              Navigator.pushReplacementNamed(context, '/calendar');
              break;
            case 0:
              Navigator.pushReplacementNamed(context, '/topics');
              break;
          }
        },)
      );
    } else {
      return const LoadingScreen();
    }
  }
}
