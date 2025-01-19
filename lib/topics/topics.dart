import 'package:flutter/material.dart';
import 'package:mood_tracker/topics/topic_item.dart';

class Topics extends StatelessWidget {
  const Topics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Today's Mood"),
      ),
      // The rest is just a list (no bottom nav bar, no separate route switching)
      body: ListView(
        children: ['manic', 'happy', 'neutral', 'sad', 'depressed']
            .map((topic) => TopicItem(topic: topic))
            .toList(),
      ),
    );
  }
}
