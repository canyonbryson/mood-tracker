import 'package:flutter_ai/calendar/calendar.dart';
import 'package:flutter_ai/edit/edit.dart';
import 'package:flutter_ai/login/login.dart';
import 'package:flutter_ai/profile/profile.dart';
import 'package:flutter_ai/topics/topics.dart';

var appRoutes = {
  '/login': (context) => const Login(),
  '/topics': (context) => const Topics(),
  '/profile': (context) => const Profile(),
  '/calendar': (context) => const Calendar(),
  '/edit': (context) => const UpdateQuizWidget(),
};
