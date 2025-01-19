import 'package:mood_tracker/calendar/calendar.dart';
import 'package:mood_tracker/edit/edit.dart';
import 'package:mood_tracker/login/login.dart';
import 'package:mood_tracker/patterns/patterns.dart';
import 'package:mood_tracker/profile/profile.dart';
import 'package:mood_tracker/topics/topics.dart';

var appRoutes = {
  '/login': (context) => const Login(),
  '/topics': (context) => const Topics(),
  '/profile': (context) => const Profile(),
  '/calendar': (context) => const Calendar(),
  '/edit': (context) => const UpdateQuizWidget(),
  '/patterns': (context) => const PatternsPage(),
};
