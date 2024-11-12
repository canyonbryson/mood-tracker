import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ai/services/auth.dart';
import 'package:flutter_ai/services/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Retrieves a single quiz document
  Future<Quiz> getQuiz() async {
    var ref = _db.collection('quizzes').doc('1');
    var snapshot = await ref.get();
    return Quiz.fromJson(snapshot.data() ?? {});
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

  Future<void> saveReport(Quiz quiz) {
    var user = AuthService().user;
    if (user == null) {
      return Future.error('User not logged in');
    }
    var ref = _db.collection('reports').add(
      {
        'uid': user.uid,
        'mood': quiz.mood,
        'date': DateTime.now().toIso8601String(),
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
      },
    );

    return ref.then((value) => print('Report saved'));
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
        return Report.fromJson(doc.data());
      }).toList();
    });
  }
}
