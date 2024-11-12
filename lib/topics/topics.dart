import 'package:flutter/material.dart';
import 'package:flutter_ai/shared/bottom_nav.dart';
import 'package:flutter_ai/shared/shared.dart';
import 'package:flutter_ai/topics/topic_item.dart';

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
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
