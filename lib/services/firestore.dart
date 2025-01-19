import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mood_tracker/services/auth.dart';
import 'package:mood_tracker/services/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Quiz> getQuiz(String mood) async {
    final user = AuthService().user;
    final String? userId = user?.uid;

    if (userId == null) {
      // User is not logged in. Return quiz with doc('1') after setting mood.
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await _db.collection('quizzes').doc('1').get();

      if (!docSnapshot.exists) {
        throw Exception('Quiz with doc ID 1 does not exist.');
      }

      Map<String, dynamic> quizData = docSnapshot.data()!;
      quizData['mood'] = mood; // Set mood

      Quiz quiz = Quiz.fromJson(quizData);
      return quiz;
    } else {
      // User is logged in. Check for existing quiz with uid = userId.
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _db
          .collection('quizzes')
          .where('uid', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Quiz with uid = userId exists. Set mood and uid, then return.
        DocumentSnapshot<Map<String, dynamic>> userQuizSnapshot =
            querySnapshot.docs.first;

        Map<String, dynamic> userQuizData = userQuizSnapshot.data()!;
        userQuizData['mood'] = mood; // Set mood
        userQuizData['uid'] = userId; // Ensure uid is set

        Quiz userQuiz = Quiz.fromJson(userQuizData);
        return userQuiz;
      } else {
        // No quiz exists for this user. Retrieve quiz with doc('1'), set mood and uid, create new quiz, and return it.
        DocumentSnapshot<Map<String, dynamic>> docSnapshot =
            await _db.collection('quizzes').doc('1').get();

        if (!docSnapshot.exists) {
          throw Exception('Quiz with doc ID 1 does not exist.');
        }

        Map<String, dynamic> defaultQuizData = docSnapshot.data()!;
        defaultQuizData['mood'] = mood; // Set mood
        defaultQuizData['uid'] = userId; // Set uid

        // Optionally, remove any fields that should be unique per user if necessary
        // For example, remove 'id' if it's not required
        defaultQuizData.remove('id');

        // Create a new quiz document for the user
        DocumentReference<Map<String, dynamic>> newQuizRef =
            await _db.collection('quizzes').add(defaultQuizData);

        // Retrieve the newly created quiz
        DocumentSnapshot<Map<String, dynamic>> newQuizSnapshot =
            await newQuizRef.get();

        if (!newQuizSnapshot.exists) {
          throw Exception('Failed to create a new quiz for the user.');
        }

        Map<String, dynamic> newQuizData = newQuizSnapshot.data()!;
        Quiz newUserQuiz = Quiz.fromJson(newQuizData);
        return newUserQuiz;
      }
    }
  }


  Future<void> updateQuiz(Quiz quiz) {
    var userId = AuthService().user?.uid;
    if (userId == null) {
      return Future.error('User not logged in');
    }
    var ref = _db.collection('quizzes').doc(quiz.id);
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
      'uid': quiz.uid,
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
        
        return Report.fromJson(data);
      }).toList();
    });
  }

  Future<List<Report>> getReportsForMonth(DateTime month) async {
    var user = AuthService().user;
    if (user == null) return Future.error('User not logged in');
    var start = DateTime(month.year, month.month, 1);
    var end = DateTime(month.year, month.month + 1, 0);
    var ref = _db
        .collection('reports')
        .where('uid', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThanOrEqualTo: end.toIso8601String())
        .orderBy('date', descending: true);

    var snapshot = await ref.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Report.fromJson(data);
    }).toList();
  }
}

extension PatternReports on FirestoreService {
  Future<List<Report>> getReportsForLast7Days() async {
    return _getReportsSince(DateTime.now().subtract(const Duration(days: 7)));
  }

  Future<List<Report>> getReportsForLast30Days() async {
    return _getReportsSince(DateTime.now().subtract(const Duration(days: 30)));
  }

  Future<List<Report>> getAllReports() async {
    // Get all reports for the user, no time constraints
    var user = AuthService().user;
    if (user == null) return Future.error('User not logged in');
    var ref = _db
        .collection('reports')
        .where('uid', isEqualTo: user.uid)
        .orderBy('date', descending: true);

    var snapshot = await ref.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Report.fromJson(data);
    }).toList();
  }

  Future<List<Report>> _getReportsSince(DateTime since) async {
    var user = AuthService().user;
    if (user == null) return Future.error('User not logged in');
    var ref = _db
        .collection('reports')
        .where('uid', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: since.toIso8601String())
        .orderBy('date', descending: true);

    var snapshot = await ref.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Report.fromJson(data);
    }).toList();
  }
}
