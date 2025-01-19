import 'package:flutter/material.dart';
import 'package:mood_tracker/home/home.dart';
import 'package:mood_tracker/quiz/quiz.dart';
import 'package:mood_tracker/services/services.dart';
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
    // Initialize displayed month to the 1st of the current month
    _displayedMonth = DateTime(now.year, now.month, 1);

    // **Use getReportsForMonth** instead of getReports
    _reportsFuture = FirestoreService().getReportsForMonth(_displayedMonth);
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
          title: const Text('Calendar'),
          backgroundColor: Colors.deepPurple,
          elevation: 0,
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
            // Get the weekday of the first day of the month (Monday=1, Sunday=7)
            int firstWeekday = DateTime(year, month, 1).weekday;
            int emptyDaysAtStart = firstWeekday - 1;

            // Map reports by date for quick access
            Map<String, Report> dateReports = {};
            for (var report in reports) {
              DateTime reportDate = DateTime.parse(report.date);
              String dateKey = DateFormat('yyyy-MM-dd').format(reportDate);
              dateReports[dateKey] = report;
            }

            // Build the calendar
            List<TableRow> calendarRows = [];

            // Day of week headers
            List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            calendarRows.add(TableRow(
              children: weekdays.map((day) {
                return Center(
                  child: Text(
                    day,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                );
              }).toList(),
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
                  dayColor = Colors.grey.shade300; // Future dates - light grey
                } else if (report != null) {
                  dayColor = moodColors[report.mood.toLowerCase()] ?? Colors.white;
                } else {
                  dayColor = Colors.white; // No report
                }

                weekDays.add(
                  GestureDetector(
                    onTap: () {
                      _onDayTapped(date, report);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: dayColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 14,
                      ),
                      child: Center(
                        child: Text(
                          '$dayCounter',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: date.isAfter(DateTime.now())
                                    ? Colors.black45
                                    : Colors.black87,
                              ),
                        ),
                      ),
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
            Widget calendarTable = Table(
              border: const TableBorder.symmetric(
                inside: BorderSide(color: Colors.transparent),
              ),
              children: calendarRows,
            );

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  // Month navigation row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () {
                            setState(() {
                              // Go back one month
                              _displayedMonth = DateTime(
                                _displayedMonth.year,
                                _displayedMonth.month - 1,
                                1,
                              );
                              // **Update the reportsFuture**
                              _reportsFuture = FirestoreService()
                                  .getReportsForMonth(_displayedMonth);
                            });
                          },
                        ),
                        Text(
                          nameOfMonth,
                          style:
                              Theme.of(context).textTheme.headlineMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: () {
                            setState(() {
                              // Go forward one month
                              _displayedMonth = DateTime(
                                _displayedMonth.year,
                                _displayedMonth.month + 1,
                                1,
                              );
                              // **Update the reportsFuture**
                              _reportsFuture = FirestoreService()
                                  .getReportsForMonth(_displayedMonth);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Calendar container
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.0, // Make it more square-ish
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(child: calendarTable),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Refresh button (optional)
                  TextButton.icon(
                    onPressed: () async {
                      setState(() {
                        // Refresh the same displayed month
                        _reportsFuture = FirestoreService()
                            .getReportsForMonth(_displayedMonth);
                      });
                    },
                    icon:
                        const Icon(Icons.refresh, color: Colors.deepPurpleAccent),
                    label: Text(
                      'Refresh',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.deepPurpleAccent,
                          ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
        backgroundColor: Colors.grey[900],
      );
    } else {
      return const LoadingScreen();
    }
  }

  void _onDayTapped(DateTime date, Report? report) {
    if (date.isAfter(DateTime.now())) {
      // Do nothing or show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot select future dates')),
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
                  const SizedBox(height: 8),
                  const Text('Questions:'),
                  const SizedBox(height: 8),
                  ...report.questions.map((q) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q.text,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          if (q.answer != null && q.answer!.isNotEmpty)
                            Text('Answer: ${q.answer}'),
                          if (q.selected != null &&
                              q.selected!.isNotEmpty &&
                              q.type != 'Open Answer')
                            Text('Selected: ${q.selected!.map((o) => o.value).join(', ')}'),
                        ],
                      ),
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
