import 'package:flutter/material.dart';
import 'package:mood_tracker/home/home.dart';
import 'package:mood_tracker/quiz/quiz_state.dart';
import 'package:mood_tracker/services/firestore.dart';
import 'package:mood_tracker/services/models.dart';
import 'package:mood_tracker/shared/progress_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class QuizScreen extends StatelessWidget {
  final String mood;
  final DateTime? date;
  final Report? existingReport; // Renamed parameter for clarity

  const QuizScreen({
    super.key,
    required this.mood,
    this.date,
    this.existingReport,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Quiz>(
      future: FirestoreService().getQuiz(mood),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return const LoadingScreen();
        } else {
          var quiz = snapshot.data!;
          return ChangeNotifierProvider(
            // Pass the existingReport to QuizState
            create: (_) => QuizState(
              mood: mood,
              quiz: quiz,
              existingReport: existingReport,
            ),
            child: Scaffold(
              appBar: AppBar(
                title: Consumer<QuizState>(
                  builder: (context, state, child) {
                    return AnimatedProgressbar(value: state.progress);
                  },
                ),
                leading: IconButton(
                  icon: const Icon(FontAwesomeIcons.xmark),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: Consumer<QuizState>(
                builder: (context, state, child) {
                  return PageView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    controller: state.controller,
                    onPageChanged: (int idx) {
                      state.progress = idx / (quiz.questions.length + 1);
                      state.update();
                    },
                    itemCount: quiz.questions.length + 2,
                    itemBuilder: (BuildContext context, int idx) {
                      if (idx == 0) {
                        return StartPage(quiz: quiz);
                      } else if (idx == quiz.questions.length + 1) {
                        return CongratsPage(
                          quiz: quiz,
                          date: date,
                          existingReport: existingReport,
                        );
                      } else {
                        // Pass questionIndex to QuestionPage
                        return QuestionPage(
                          question: quiz.questions[idx - 1],
                          questionIndex: idx - 1,
                        );
                      }
                    },
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }
}


class StartPage extends StatelessWidget {
  final Quiz quiz;
  const StartPage({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<QuizState>(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Get Ready!', style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          Expanded(child: Text('Answer a few questions to assess your mood')),
          OverflowBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: state.nextPage,
                label: const Text('Start Now!'),
                icon: const Icon(Icons.poll),
              )
            ],
          )
        ],
      ),
    );
  }
}

class CongratsPage extends StatelessWidget {
  final Quiz quiz;
  final DateTime? date;
  final Report? existingReport;

  const CongratsPage({
    super.key,
    required this.quiz,
    this.date,
    this.existingReport,
  });

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<QuizState>(context, listen: false);
    var quiz = state.quiz; // Get the updated quiz with user's answers

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Congrats! You completed the ${quiz.title} quiz',
            textAlign: TextAlign.center,
          ),
          const Divider(),
          Image.asset('assets/congrats.gif'),
          const Divider(),
          ElevatedButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            icon: const Icon(FontAwesomeIcons.check),
            label: const Text(' Mark Complete!'),
            onPressed: () {
              // Save or update the report
              FirestoreService().saveReport(
                quiz,
                date,
                existingReport?.id, // Pass report ID if editing
              );

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/topics',
                (route) => false,
              );
            },
          )
        ],
      ),
    );
  }
}

class QuestionPage extends StatefulWidget {
  final Question question;
  final int questionIndex;

  const QuestionPage({
    super.key,
    required this.question,
    required this.questionIndex,
  });

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  late TextEditingController _openAnswerController;
  bool _isSubmitting = false; // To prevent multiple submissions

  @override
  void initState() {
    super.initState();
    var state = Provider.of<QuizState>(context, listen: false);

    // Initialize the controller with existing answer if available
    String existingAnswer = state.openAnswers[widget.questionIndex];
    _openAnswerController = TextEditingController(text: existingAnswer);

    // Listen to changes and update the state accordingly
    _openAnswerController.addListener(() {
      String value = _openAnswerController.text;
      state.openAnswers[widget.questionIndex] = value;
      state.quiz.questions[widget.questionIndex].answer = value;
      state.update();
    });
  }

  @override
  void dispose() {
    _openAnswerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<QuizState>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display question text
          Text(
            widget.question.text,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          // Expanded widget containing the question input
          Expanded(
            child: _buildQuestionInput(context, state),
          ),
          const SizedBox(height: 20),
          // Submit button
          ElevatedButton.icon(
            onPressed: _isSubmitting
                ? null
                : () {
                  //save open answer if applicable
                    if (widget.question.type == 'Open Answer') {
                      state.openAnswers[widget.questionIndex] = _openAnswerController.text;
                      state.quiz.questions[widget.questionIndex].answer = _openAnswerController.text;
                      state.update();
                    }

                    // _bottomSheet(context, state);
                    // Advance to the next page after the bottom sheet is closed
                    state.nextPage();
                  },
            icon: const Icon(Icons.check),
            label: const Text('Submit'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50), // Make button full width
            ),
          ),
        ],
      ),
    );
  }

  // Unified method to build question input based on type
  Widget _buildQuestionInput(BuildContext context, QuizState state) {
    if (widget.question.type == 'Open Answer') {
      return _buildOpenAnswer(context, state);
    } else if (widget.question.type == 'Single Choice') {
      return _buildSingleChoice(context, state);
    } else if (widget.question.type == 'Multiple Choice') {
      return _buildMultipleChoice(context, state);
    } else {
      return const Text('Unknown question type');
    }
  }

  // Widget for Open Answer question type
  Widget _buildOpenAnswer(BuildContext context, QuizState state) {
    return TextField(
      controller: _openAnswerController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Your Answer',
      ),
      maxLines: null, // Allow multiple lines if needed
    );
  }

  // Widget for Single Choice question type
  Widget _buildSingleChoice(BuildContext context, QuizState state) {
    Option? selectedOption = state.singleChoiceAnswers[widget.questionIndex];

    return ListView(
      children: (widget.question.options ?? []).map((opt) {
        return RadioListTile<Option>(
          title: Text(opt.value),
          value: opt,
          groupValue: selectedOption,
          onChanged: (Option? value) {
            state.singleChoiceAnswers[widget.questionIndex] = value;
            state.quiz.questions[widget.questionIndex].selected =
                value != null ? [value] : null;
            state.update(); // Notify listeners
          },
        );
      }).toList(),
    );
  }

  // Widget for Multiple Choice question type
  Widget _buildMultipleChoice(BuildContext context, QuizState state) {
    List<Option> selectedOptions =
        List<Option>.from(state.multipleChoiceAnswers[widget.questionIndex]);

    return ListView(
      children: (widget.question.options ?? []).map((opt) {
        bool isChecked = selectedOptions.contains(opt);

        return CheckboxListTile(
          title: Text(opt.value),
          value: isChecked,
          onChanged: (bool? value) {
            if (value == true) {
              selectedOptions.add(opt);
            } else {
              selectedOptions.remove(opt);
            }
            state.multipleChoiceAnswers[widget.questionIndex] = selectedOptions;
            state.quiz.questions[widget.questionIndex].selected = selectedOptions;
            state.update(); // Notify listeners
          },
        );
      }).toList(),
    );
  }
}
