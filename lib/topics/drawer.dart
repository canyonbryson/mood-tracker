import 'package:flutter/material.dart';
import 'package:mood_tracker/quiz/quiz.dart';
// import 'package:mood_tracker/services/models.dart';

// class TopicDrawer extends StatelessWidget {
//   final List<Topic> topics;
//   const TopicDrawer({super.key, required this.topics});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView.separated(
//           shrinkWrap: true,
//           itemCount: 1,
//           itemBuilder: (BuildContext context, int idx) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(top: 10, left: 10),
//                   child: Text(
//                     'Mood Quiz',
//                     // textAlign: TextAlign.left,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white70,
//                     ),
//                   ),
//                 ),
//                 QuizList()
//               ],
//             );
//           },
//           separatorBuilder: (BuildContext context, int idx) => const Divider()),
//     );
//   }
// }

class QuizList extends StatelessWidget {
  final String mood;
  const QuizList({super.key, required this.mood});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          elevation: 4,
          margin: const EdgeInsets.all(4),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => QuizScreen(mood: mood),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(
                  'Assess your mood',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                subtitle: Text(
                  'Answer a few questions',
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                // leading: QuizBadge(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
