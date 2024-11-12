import 'package:flutter/material.dart';
import 'package:flutter_ai/home/home.dart';
import 'package:flutter_ai/quiz/quiz_state.dart';
import 'package:flutter_ai/services/firestore.dart';
import 'package:flutter_ai/services/models.dart';
import 'package:flutter_ai/shared/progress_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuizState(),
      child: FutureBuilder<Quiz>(
        future: FirestoreService().getQuiz(),
        builder: (context, snapshot) {
          var state = Provider.of<QuizState>(context);

          if (!snapshot.hasData || snapshot.hasError) {
            return const LoadingScreen();
          } else {
            var quiz = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                title: AnimatedProgressbar(value: state.progress),
                leading: IconButton(
                  icon: const Icon(FontAwesomeIcons.xmark),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: PageView.builder(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                controller: state.controller,
                onPageChanged: (int idx) =>
                    state.progress = (idx / (quiz.questions.length + 1)),
                itemBuilder: (BuildContext context, int idx) {
                  if (idx == 0) {
                    return StartPage(quiz: quiz);
                  } else if (idx == quiz.questions.length + 1) {
                    return CongratsPage(quiz: quiz);
                  } else {
                    return QuestionPage(question: quiz.questions[idx - 1]);
                  }
                },
              ),
            );
          }
        },
      ),
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
  const CongratsPage({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
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
              FirestoreService().saveReport(quiz);
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

class QuestionPage extends StatelessWidget {
  final Question question;
  const QuestionPage({super.key, required this.question});

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
            question.text,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          // Display different widgets based on question type
          if (question.type == 'Open Answer')
            _buildOpenAnswer(context, state)
          else if (question.type == 'Single Choice')
            _buildSingleChoice(context, state)
          else if (question.type == 'Multiple Choice')
            _buildMultipleChoice(context, state)
          else
            const Text('Unknown question type'),
          const Spacer(),
          // Display Submit button whihc opens bottom sheet if correct
          ElevatedButton.icon(
            onPressed: () {
              _bottomSheet(context, state);
            },
            icon: const Icon(Icons.check),
            label: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  // Widget for Open Answer question type
  Widget _buildOpenAnswer(BuildContext context, QuizState state) {
    return TextField(
      onChanged: (value) {
        state.answer = value;
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Your Answer',
      ),
    );
  }

  // Widget for Single Choice question type
  Widget _buildSingleChoice(BuildContext context, QuizState state) {
    return Expanded(
      child: ListView(
        children: (question.options ?? []).map((opt) {
          return RadioListTile<Option>(
            title: Text(opt.value),
            value: opt,
            groupValue: state.selectedOption,
            onChanged: (Option? value) {
              state.selectedOption = value;
              state.update(); // Notify listeners
            },
          );
        }).toList(),
      ),
    );
  }

  // Widget for Multiple Choice question type
  Widget _buildMultipleChoice(BuildContext context, QuizState state) {
    return Expanded(
      child: ListView(
        children: (question.options ?? []).map((opt) {
          return CheckboxListTile(
            title: Text(opt.value),
            value: state.selectedOptions.contains(opt),
            onChanged: (bool? value) {
              if (value == true) {
                state.selectedOptions.add(opt);
              } else {
                state.selectedOptions.remove(opt);
              }
              state.update(); // Notify listeners
            },
          );
        }).toList(),
      ),
    );
  }

  /// Bottom sheet shown when Question is answered
  _bottomSheet(BuildContext context, QuizState state) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Good Job!'),
              Text(
                "Let's go to the next question",
                style: const TextStyle(fontSize: 18, color: Colors.white54),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text(
                  'Onward!',
                  style: const TextStyle(
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  state.nextPage();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
