import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable()
class Option {
  String value;
  String detail;
  bool correct;

  Option({this.value = '', this.detail = '', this.correct = false});

  factory Option.fromJson(Map<String, dynamic> json) => _$OptionFromJson(json);
  Map<String, dynamic> toJson() => _$OptionToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Option &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

}

@JsonSerializable()
class Question {
  String text;
  String type;
  List<Option>? options;
  String? answer;
  List<Option>? selected;

  Question(
      {this.text = '',
      this.type = 'Open Answer',
      this.options = const [],
      this.answer = '',
      this.selected = const []});

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}

@JsonSerializable()
class Quiz {
  String id;
  String uid;
  String title;
  String description;
  String mood;
  List<Question> questions;

  Quiz(
      {this.title = '',
      this.description = '',
      this.id = '',
      this.mood = '',
      this.uid = '',
      this.questions = const []});
  factory Quiz.fromJson(Map<String, dynamic> json) => _$QuizFromJson(json);
  Map<String, dynamic> toJson() => _$QuizToJson(this);
}

@JsonSerializable()
class Report {
  String id;
  String uid;
  List<Question> questions;
  String mood;
  String date;

  Report(
      {this.uid = '',
      this.id = '',
      this.mood = "",
      this.questions = const [],
      this.date = ''});
  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
  Map<String, dynamic> toJson() => _$ReportToJson(this);
}
