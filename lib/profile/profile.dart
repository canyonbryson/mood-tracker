import 'package:flutter/material.dart';
import 'package:mood_tracker/home/home.dart';
import 'package:mood_tracker/services/services.dart';

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
              const SizedBox(height: 50),
              // the user email, if logged in
              if (user.email != null) ...[
                Text('Logged in as ${user.email}'),
                const SizedBox(height: 20),
              ],
              
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
              Padding(
                padding: const EdgeInsets.only(top: 50.0, bottom: 30),
                child: Text('Dedicated to my loving wife, Sabrina.'),
              ),
            ],
          ),
        ),
      );
    } else {
      return const LoadingScreen();
    }
  }
}
