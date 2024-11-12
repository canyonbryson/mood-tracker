import 'package:flutter/material.dart';
import 'package:flutter_ai/home/home.dart';
import 'package:flutter_ai/services/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Assuming the Report class and moodColors map are defined as per your reference.

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    var reports = Provider.of<List<Report>>(context);
    var user = AuthService().user;

    if (user != null) {
      int year = _displayedMonth.year;
      int month = _displayedMonth.month;
      String nameOfMonth = DateFormat.yMMMM().format(_displayedMonth);

      // Get total days in the displayed month
      int daysInMonth = DateTime(year, month + 1, 0).day;
      // Get the weekday of the first day of the month
      int firstWeekday =
          DateTime(year, month, 1).weekday; // Monday = 1, Sunday = 7
      int emptyDaysAtStart = firstWeekday - 1;

      // Map reports by date for quick access
      Map<String, Report> dateReports = {};
      for (var report in reports) {
        DateTime reportDate = DateTime.parse(report.date);
        String dateKey = DateFormat('yyyy-MM-dd').format(reportDate);
        dateReports[dateKey] = report;
      }

      // Mood to Color mapping
      Map<String, Color> moodColors = {
        'Manic': Colors.yellow,
        'Happy': Colors.green,
        'Neutral': Colors.white,
        'Sad': Colors.blue,
        'Depressed': Colors.purple,
      };

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text('Calendar'),
        ),
        body: SingleChildScrollView(
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
            ],
          ),
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
      // Show the report details
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Report for ${DateFormat.yMd().format(date)}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mood: ${report.mood}'),
                SizedBox(height: 8),
                Text('Questions:'),
                ...report.questions.map((q) => Text('- ${q.text}')),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } else {
      // No report for this day
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No report for this day')),
      );
    }
  }
}
