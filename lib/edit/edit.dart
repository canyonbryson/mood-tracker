// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_ai/services/firestore.dart';
import 'package:flutter_ai/services/models.dart';

class UpdateQuizWidget extends StatefulWidget {
  const UpdateQuizWidget({super.key});

  @override
  UpdateQuizWidgetState createState() => UpdateQuizWidgetState();
}

class UpdateQuizWidgetState extends State<UpdateQuizWidget> {
  final _formKey = GlobalKey<FormState>();
  late Quiz _quiz;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      _quiz = await FirestoreService().getQuiz();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Handle the error appropriately
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load quiz: $e')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _updateQuiz() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await FirestoreService().updateQuiz(_quiz);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quiz updated successfully')),
        );
      } catch (e) {
        // Handle the error appropriately
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update quiz: $e')),
        );
      }
    }
  }

  void _addQuestion() {
    setState(() {
      _quiz.questions.add(Question(type: 'Open Answer', options: []));
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _quiz.questions.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Quiz'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Quiz Title
                    TextFormField(
                      initialValue: _quiz.title,
                      decoration: InputDecoration(labelText: 'Quiz Title'),
                      onSaved: (value) {
                        _quiz.title = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    // Description
                    TextFormField(
                      initialValue: _quiz.description,
                      decoration: InputDecoration(labelText: 'Description'),
                      onSaved: (value) {
                        _quiz.description = value ?? '';
                      },
                    ),
                    // Mood
                    TextFormField(
                      initialValue: _quiz.mood,
                      decoration: InputDecoration(labelText: 'Mood'),
                      onSaved: (value) {
                        _quiz.mood = value ?? '';
                      },
                    ),
                    SizedBox(height: 20),
                    Text('Questions', style: TextStyle(fontSize: 18)),
                    // List of Questions
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _quiz.questions.length,
                      itemBuilder: (context, index) {
                        return QuestionEditor(
                          question: _quiz.questions[index],
                          onRemove: () => _removeQuestion(index),
                        );
                      },
                    ),
                    TextButton(
                      onPressed: _addQuestion,
                      child: Text('Add Question'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateQuiz,
                      child: Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

final List<String> types = ['Single Choice', 'Multiple Choice', 'Open Answer'];

class QuestionEditor extends StatefulWidget {
  final Question question;
  final VoidCallback onRemove;

  const QuestionEditor({
    super.key,
    required this.question,
    required this.onRemove,
  });

  @override
  QuestionEditorState createState() => QuestionEditorState();
}

class QuestionEditorState extends State<QuestionEditor> {
  final List<String> types = [
    'Single Choice',
    'Multiple Choice',
    'Open Answer'
  ];

  void _addOption() {
    setState(() {
      widget.question.options ??= [];
      widget.question.options!.add(Option());
    });
  }

  void _removeOption(int index) {
    setState(() {
      widget.question.options!.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Text
            TextFormField(
              initialValue: widget.question.text,
              decoration: InputDecoration(labelText: 'Question Text'),
              onSaved: (value) {
                widget.question.text = value ?? '';
              },
            ),
            SizedBox(height: 8),
            // Question Type Dropdown
            DropdownButtonFormField<String>(
              value: widget.question.type,
              decoration: InputDecoration(labelText: 'Question Type'),
              items: types.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  widget.question.type = newValue ?? 'Open Answer';
                  // Clear options if the question type is 'Open Answer'
                  if (widget.question.type == 'Open Answer') {
                    widget.question.options = [];
                  }
                });
              },
              onSaved: (value) {
                widget.question.type = value ?? 'Open Answer';
              },
            ),
            SizedBox(height: 8),
            // Options (Only for choice questions)
            if (widget.question.type != 'Open Answer') ...[
              Text('Options', style: TextStyle(fontSize: 16)),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.question.options?.length ?? 0,
                itemBuilder: (context, index) {
                  final option = widget.question.options![index];
                  return OptionEditor(
                    option: option,
                    question: widget.question,
                    onRemove: () => _removeOption(index),
                    questionType: widget.question.type,
                    onOptionChanged: () => setState(() {}),
                  );
                },
              ),
              TextButton(
                onPressed: _addOption,
                child: Text('Add Option'),
              ),
            ],
            // Remove Question Button
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.delete),
                onPressed: widget.onRemove,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OptionEditor extends StatefulWidget {
  final Option option;
  final VoidCallback onRemove;
  final Question question;
  final String questionType;
  final VoidCallback onOptionChanged;

  const OptionEditor({
    super.key,
    required this.option,
    required this.question,
    required this.onRemove,
    required this.questionType,
    required this.onOptionChanged,
  });

  @override
  OptionEditorState createState() => OptionEditorState();
}

class OptionEditorState extends State<OptionEditor> {
  @override
  Widget build(BuildContext context) {
    // Determine the index of the selected option
    int selectedOptionIndex =
        widget.question.options!.indexWhere((opt) => opt.correct);

    // Set groupValue to null if no option is selected
    int? groupValue = selectedOptionIndex >= 0 ? selectedOptionIndex : null;
    return Row(
      children: [
        // Option Value
        Expanded(
          child: TextFormField(
            initialValue: widget.option.value,
            decoration: InputDecoration(labelText: 'Option Value'),
            onSaved: (value) {
              widget.option.value = value ?? '';
            },
          ),
        ),
        // Correct Indicator
        if (widget.questionType == 'Multiple Choice') ...[
          Checkbox(
            value: widget.option.correct,
            onChanged: (value) {
              setState(() {
                widget.option.correct = value ?? false;
              });
            },
          ),
        ] else if (widget.questionType == 'Single Choice') ...[
          Radio<int>(
            value: widget.question.options!.indexOf(widget.option),
            groupValue: groupValue,
            onChanged: (value) {
              setState(() {
                if (value == null) return;
                // Deselect all options
                for (var opt in widget.question.options!) {
                  opt.correct = false;
                }
                // Select the chosen option
                widget.question.options![value].correct = true;
              });
              widget.onOptionChanged();
            },
          ),
        ],
        // Remove Option Button
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: widget.onRemove,
        ),
      ],
    );
  }
}
