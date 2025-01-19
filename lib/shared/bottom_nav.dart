// bottom_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Define your AppColors in a separate file or inline
class AppColors {
  static const Color purple = Colors.deepPurple;
  static const Color grey = Colors.grey;
  static const Color white = Colors.white;
}

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: AppColors.purple,
      unselectedItemColor: AppColors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.pencil,
            size: 20,
          ),
          label: 'Track',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.calendarDay,
            size: 20,
          ),
          label: 'Calendar',
        ),
        // Patterns page
        BottomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.chartLine,
            size: 20,
          ),
          label: 'Patterns',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.circleUser,
            size: 20,
          ),
          label: 'Profile',
        ),
      ],
      onTap: onTap,
      type: BottomNavigationBarType.fixed, // Ensures all items are displayed
    );
  }
}
