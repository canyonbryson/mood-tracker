import 'package:flutter/material.dart';
import 'package:mood_tracker/home/home.dart';
import 'package:mood_tracker/quiz/quiz.dart';
import 'package:mood_tracker/services/services.dart';
import 'package:mood_tracker/shared/bottom_nav.dart';
import 'package:intl/intl.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late DateTime _displayedMonth;
  late Future<List<Report>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
    _reportsFuture = FirestoreService().getReports();
  }

  // Mood to Color mapping
  Map<String, Color> moodColors = {
    'manic': Colors.yellow,
    'happy': Colors.green,
    'neutral': const Color.fromARGB(255, 200, 200, 200),
    'sad': Colors.blue,
    'depressed': Colors.purple,
  };

  @override
  Widget build(BuildContext context) {
    var user = AuthService().user;

    if (user != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Calendar'),
          backgroundColor: Colors.deepPurple,
        ),
        body: FutureBuilder<List<Report>>(
          future: _reportsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // Handle error
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              // Show loading
              return const LoadingScreen();
            }

            var reports = snapshot.data!;

            int year = _displayedMonth.year;
            int month = _displayedMonth.month;
            String nameOfMonth = DateFormat.yMMMM().format(_displayedMonth);

            // Get total days in the displayed month
            int daysInMonth = DateTime(year, month + 1, 0).day;
            // Get the weekday of the first day of the month
            int firstWeekday = DateTime(year, month, 1).weekday; // Monday = 1, Sunday = 7
            int emptyDaysAtStart = firstWeekday - 1;

            // Map reports by date for quick access
            Map<String, Report> dateReports = {};
            for (var report in reports) {
              DateTime reportDate = DateTime.parse(report.date);
              String dateKey = DateFormat('yyyy-MM-dd').format(reportDate);
              dateReports[dateKey] = report;
            }

            List<TableRow> calendarRows = [];

            // Add header row for days of the week
            calendarRows.add(TableRow(
              children: [
                Center(child: Text('Mon')),
                Center(child: Text('Tue')),
                Center(child: Text('Wed')),
                Center(child: Text('Thu')),
                Center(child: Text('Fri')),
                Center(child: Text('Sat')),
                Center(child: Text('Sun')),
              ],
            ));

            List<Widget> weekDays = [];

            // Add empty containers for days before the first of the month
            for (int i = 0; i < emptyDaysAtStart; i++) {
              weekDays.add(Container());
            }

            int dayCounter = 1;
            while (dayCounter <= daysInMonth) {
              while (weekDays.length < 7 && dayCounter <= daysInMonth) {
                DateTime date = DateTime(year, month, dayCounter);
                String dateKey = DateFormat('yyyy-MM-dd').format(date);
                Report? report = dateReports[dateKey];

                Color dayColor;
                if (date.isAfter(DateTime.now())) {
                  dayColor = Colors.grey; // Future dates
                } else if (report != null) {
                  dayColor = moodColors[report.mood] ?? Colors.white;
                } else {
                  dayColor = Colors.white; // No report for this day
                }

                weekDays.add(
                  GestureDetector(
                    onTap: () {
                      _onDayTapped(date, report);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: dayColor,
                        border: Border.all(color: Colors.black12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: Center(child: Text('$dayCounter')),
                    ),
                  ),
                );

                dayCounter++;
              }

              // Fill the remaining slots in the week with empty containers
              while (weekDays.length < 7) {
                weekDays.add(Container());
              }

              // Add the week to the calendar rows
              calendarRows.add(TableRow(children: weekDays));

              // Prepare for the next week
              weekDays = [];
            }

            // Build the calendar table
            Table calendarTable = Table(
              border: TableBorder.all(color: Colors.black12),
              children: calendarRows,
            );

            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 16),
                  // Back and Next buttons with the month name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          setState(() {
                            _displayedMonth = DateTime(
                                _displayedMonth.year, _displayedMonth.month - 1, 1);
                          });
                        },
                      ),
                      Text(
                        nameOfMonth,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          setState(() {
                            _displayedMonth = DateTime(
                                _displayedMonth.year, _displayedMonth.month + 1, 1);
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  calendarTable,
                  SizedBox(height: 16),
                  // Refresh button
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _reportsFuture = FirestoreService().getReports();
                      });
                    },
                    child: const Text('Refresh'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: 1,
          onTap: (index) {
            if (index == 1) return;
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/topics');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/profile');
                break;
            }
          },
        ),
      );
    } else {
      return const LoadingScreen();
    }
  }

  void _onDayTapped(DateTime date, Report? report) {
    if (date.isAfter(DateTime.now())) {
      // Do nothing or show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot select future dates')),
      );
      return;
    }

    if (report != null) {
      // Show the report details with an option to edit
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Report for ${DateFormat.yMd().format(date)}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mood: ${report.mood}'),
                  SizedBox(height: 8),
                  Text('Questions:'),
                  const SizedBox(height: 8),
                  ...report.questions.map((q) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.text,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        if (q.answer != null && q.answer!.isNotEmpty)
                          Text('Answer: ${q.answer}'),
                        if (q.selected != null && q.selected!.isNotEmpty && q.type != 'Open Answer')
                          Text(
                              'Selected: ${q.selected!.map((o) => o.value).join(', ')}'),
                        const SizedBox(height: 12),
                      ],
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  // Navigate to the QuizScreen with existing report data
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => QuizScreen(
                        mood: report.mood,
                        date: date,
                        existingReport: report,
                      ),
                    ),
                  );
                },
                child: const Text('Edit'),
              ),
            ],
          );
        },
      );
    } else {
      // No report for this day - allow to select a mood and take quiz retrospectively

      // First, choose mood
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Select Mood'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var mood in moodColors.keys)
                    ListTile(
                      title: Text(mood),
                      onTap: () {
                        Navigator.of(context).pop(mood);
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ).then((selectedMood) {
        if (selectedMood != null) {
          // Then, take quiz
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  QuizScreen(mood: selectedMood, date: date),
            ),
          );
        }
      });
    }
  }
}
 