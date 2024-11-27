import 'package:flutter/material.dart';
import 'package:mood_tracker/shared/bottom_nav.dart';
import 'package:mood_tracker/shared/shared.dart';
import 'package:mood_tracker/topics/topic_item.dart';

class Topics extends StatelessWidget {
  const Topics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Topics'),
      ),
      body: Scrollable(
        viewportBuilder: (context, position) => ListView(
          children: ['manic', 'happy', 'neutral', 'sad', 'depressed']
              .map((topic) => TopicItem(topic: topic))
              .toList(),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0, // Index for Topics
        onTap: (index) {
          if (index == 0) return; // Already on Topics
          switch (index) {
            case 1:
              Navigator.pushReplacementNamed(context, '/calendar');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      )
    );
  }
}
