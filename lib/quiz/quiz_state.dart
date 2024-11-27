import 'package:flutter/material.dart';
import 'package:mood_tracker/services/models.dart';

class QuizState extends ChangeNotifier {
  final String mood;
  final Quiz quiz;
  final Report? existingReport;
  final PageController controller = PageController();
  double progress = 0.0;

  // For tracking answers per question
  List<String> openAnswers = [];
  List<Option?> singleChoiceAnswers = [];
  List<List<Option>> multipleChoiceAnswers = [];

  QuizState({
    required this.mood,
    required this.quiz,
    this.existingReport,
  }) {
    // Initialize answer lists based on the number of questions
    openAnswers = List<String>.filled(quiz.questions.length, '');
    singleChoiceAnswers = List<Option?>.filled(quiz.questions.length, null);
    multipleChoiceAnswers =
        List<List<Option>>.generate(quiz.questions.length, (_) => []);

    // If existingReport is provided, pre-fill the answers
    if (existingReport != null) {
      for (int i = 0; i < quiz.questions.length; i++) {
        Question question = quiz.questions[i];
        Question reportQuestion = existingReport!.questions[i];

        if (question.type == 'Open Answer') {
          openAnswers[i] = reportQuestion.answer ?? '';
          quiz.questions[i].answer = reportQuestion.answer;
        } else if (question.type == 'Single Choice') {
          if (reportQuestion.selected != null &&
              reportQuestion.selected!.isNotEmpty) {
            singleChoiceAnswers[i] = reportQuestion.selected!.first;
            quiz.questions[i].selected = [reportQuestion.selected!.first];
          }
        } else if (question.type == 'Multiple Choice') {
          multipleChoiceAnswers[i] = reportQuestion.selected ?? [];
          quiz.questions[i].selected = reportQuestion.selected;
        }
      }
    }
  }

  void nextPage() {
    controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  void update() {
    notifyListeners();
  }
}
