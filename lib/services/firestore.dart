import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mood_tracker/services/auth.dart';
import 'package:mood_tracker/services/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Retrieves a single quiz document
  Future<Quiz> getQuiz(String mood) async {
    var ref = _db.collection('quizzes').doc('1');
    var snapshot = await ref.get();
    Quiz q = Quiz.fromJson(snapshot.data() ?? {});
    //set mood
    q.mood = mood;
    return q;
  }

  Future<void> updateQuiz(Quiz quiz) {
    var ref = _db.collection('quizzes').doc("1");
    var q = {
      'questions': quiz.questions
          .map(
            (q) => {
              'text': q.text,
              'type': q.type,
              'options': q.options?.map((o) => o.toJson()).toList(),
              'answer': q.answer,
              'selected': q.selected?.map((o) => o.toJson()).toList(),
            },
          )
          .toList(),
      'mood': quiz.mood,
      'title': quiz.title,
      'description': quiz.description,
      'id': quiz.id,
    };
    return ref.set(q, SetOptions(merge: false));
  }

  Future<void> saveReport(Quiz quiz, DateTime? date, String? reportId) async {
    var user = AuthService().user;
    if (user == null) {
      return Future.error('User not logged in');
    }
    final reportData = {
        'uid': user.uid,
        'mood': quiz.mood,
        'date': date != null ? date.toIso8601String() : DateTime.now().toIso8601String(),
        'questions': quiz.questions
            .map(
              (q) => {
                'text': q.text,
                'type': q.type,
                'options': q.options?.map((o) => o.toJson()).toList(),
                'answer': q.answer,
                'selected': q.selected?.map((o) => o.toJson()).toList(),
              },
            )
            .toList(),
      };
    // print all open answers
    print('\n\nAnswers:\n');
    quiz.questions.forEach((q) {
      if (q.type.toLowerCase() == 'open answer') {
        print(q.answer);
      }
    });
    print(reportData['date']);
    print(reportId);
    if (reportId != null) {
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(reportId)
          .set(reportData, SetOptions(merge: false));
    } else {
      await FirebaseFirestore.instance
          .collection('reports')
          .add(reportData);
    }
  }

  // get reports for last month
  Future<List<Report>> getReports() {
    var user = AuthService().user;
    if (user == null) {
      return Future.error('User not logged in');
    }
    var ref = _db
        .collection('reports')
        .where('uid', isEqualTo: user.uid)
        .where('date',
            isGreaterThanOrEqualTo:
                DateTime.now().subtract(Duration(days: 30)).toIso8601String())
        .orderBy('date', descending: true);

    return ref.get().then((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        print('\n\nID: ${doc.id}\n\n');
        
        return Report.fromJson(data);
      }).toList();
    });
  }
}
