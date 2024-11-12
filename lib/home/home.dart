import 'package:flutter/material.dart';
import 'package:flutter_ai/login/login.dart';
import 'package:flutter_ai/services/auth.dart';
import 'package:flutter_ai/topics/topics.dart';

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
          return const Topics();
        } else {
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
    return const Center(
      child: CircularProgressIndicator(),
    );
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
