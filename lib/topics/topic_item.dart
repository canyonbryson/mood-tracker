import 'package:flutter/material.dart';
import 'package:mood_tracker/topics/drawer.dart';

class TopicItem extends StatelessWidget {
  final String topic;
  const TopicItem({super.key, required this.topic});

  static const Map<String, String> topicImages = {
    'manic': 'manic.jpeg',
    'happy': 'happy.jpeg',
    'neutral': 'neutral.jpeg',
    'sad': 'sad.jpeg',
    'depressed': 'depressed.png',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20, top: 4),
      child: Hero(
        tag: topic,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => TopicScreen(topic: topic),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  child: Image.asset(
                    'assets/images/${topicImages[topic]}',
                    fit: BoxFit.contain,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(
                      topic.toUpperCase(),
                      style: const TextStyle(
                        height: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TopicScreen extends StatelessWidget {
  final String topic;

  const TopicScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: ListView(children: [
        Hero(
          tag: topic,
          child: Image.asset('assets/images/${TopicItem.topicImages[topic]}',
              width: MediaQuery.of(context).size.width),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              topic.toUpperCase(),
              style: const TextStyle(
                  height: 2, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        QuizList(mood: topic)
      ]),
    );
  }
}
