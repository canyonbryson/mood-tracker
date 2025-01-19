import 'package:flutter/material.dart';
import 'package:mood_tracker/services/services.dart';

class OptionMoodStats {
  // Map<optionValue, Map<mood, count>>
  Map<String, Map<String, int>> optionMoodCount = {};

  void addOccurrence(String optionValue, String mood) {
    optionMoodCount.putIfAbsent(optionValue, () => {});
    optionMoodCount[optionValue]!.putIfAbsent(mood, () => 0);
    optionMoodCount[optionValue]![mood] = optionMoodCount[optionValue]![mood]! + 1;
  }

  /// Algorithm 1: Frequency-based (original)
  List<PatternResult> frequencyBasedPatterns({int limit = 10}) {
    List<PatternResult> results = [];

    optionMoodCount.forEach((optionValue, moodMap) {
      moodMap.forEach((mood, count) {
        results.add(PatternResult(
          optionValue: optionValue,
          mood: mood,
          count: count,
          question: '',
        ));
      });
    });

    // Sort by count descending
    results.sort((a, b) => b.count.compareTo(a.count));
    return results.take(limit).toList();
  }

  /// Algorithm 2: Mood Normalized Frequency
  /// This calculates how often an option is chosen for a mood relative
  /// to how often that mood appears overall.
  List<PatternResult> moodNormalizedPatterns({int limit = 10}) {
    // First, compute how often each mood occurs in total
    Map<String, int> moodTotals = {};
    optionMoodCount.forEach((optionValue, moodMap) {
      moodMap.forEach((mood, count) {
        moodTotals[mood] = (moodTotals[mood] ?? 0) + count;
      });
    });

    List<PatternResult> results = [];
    optionMoodCount.forEach((optionValue, moodMap) {
      moodMap.forEach((mood, count) {
        final total = moodTotals[mood] ?? 1;
        double ratio = (total == 0) ? 0 : (count / total);
        // We'll store ratio * 1000 as an integer "score" for simplicity
        int score = (ratio * 1000).round();
        results.add(PatternResult(
          optionValue: optionValue,
          mood: mood,
          count: score,
          question: '',
        ));
      });
    });

    results.sort((a, b) => b.count.compareTo(a.count));
    return results.take(limit).toList();
  }

  /// Algorithm 3: Option-Mood Correlation (Basic)
  /// Compute a correlation-like measure:
  /// (count/totalForOption) / (moodTotal / overallTotal).
  List<PatternResult> correlationPatterns({int limit = 10}) {
    // Compute total occurrences of each mood and total occurrences of each option
    Map<String, int> moodTotals = {};
    Map<String, int> optionTotals = {};

    optionMoodCount.forEach((optionValue, moodMap) {
      moodMap.forEach((mood, count) {
        moodTotals[mood] = (moodTotals[mood] ?? 0) + count;
        optionTotals[optionValue] = (optionTotals[optionValue] ?? 0) + count;
      });
    });

    // overallTotal
    int overallTotal = moodTotals.values.fold(0, (sum, v) => sum + v);

    List<PatternResult> results = [];
    optionMoodCount.forEach((optionValue, moodMap) {
      moodMap.forEach((mood, count) {
        int totalForMood = moodTotals[mood] ?? 1;
        int totalForOption = optionTotals[optionValue] ?? 1;

        double moodFrequency = (overallTotal == 0) ? 0 : (totalForMood / overallTotal);
        double optionFrequencyInMood = count / totalForOption;

        double correlation =
            (moodFrequency == 0) ? 0 : (optionFrequencyInMood / moodFrequency);

        int score = (correlation * 1000).round();
        results.add(PatternResult(
          optionValue: optionValue,
          mood: mood,
          count: score,
          question: '',
        ));
      });
    });

    // Sort by score descending
    results.sort((a, b) => b.count.compareTo(a.count));
    return results.take(limit).toList();
  }
}

class PatternResult {
  final String question;
  final String optionValue;
  final String mood;
  final int count; // This "count" can represent different metrics depending on the algorithm

  PatternResult({
    required this.question,
    required this.optionValue,
    required this.mood,
    required this.count,
  });
}

class PatternsPage extends StatefulWidget {
  const PatternsPage({Key? key}) : super(key: key);

  @override
  State<PatternsPage> createState() => _PatternsPageState();
}

class _PatternsPageState extends State<PatternsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _loading = false;
  List<PatternResult> _patterns = [];
  String? _timeSpan; // '7days', '30days', 'all'
  String? _selectedAlgorithm; // 'frequency', 'normalized', 'correlation'
  String? _errorMessage;
  String _viewMode = 'mood'; // or 'question'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patterns'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Why u moooooody?',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Analyze your mood over different time spans to discover trends and patterns.',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.white70,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Step 1: Choose time span
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _timePeriodOption(context, 'Last 7 days', '7days'),
                _timePeriodOption(context, 'Last 30 days', '30days'),
                _timePeriodOption(context, 'All time', 'all'),
              ],
            ),
            const SizedBox(height: 20),
            // Step 2: Choose Algorithm (only show if time span is selected)
            if (_timeSpan != null) ...[
              Text(
                'Step 2: Choose Algorithm',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select an algorithm to analyze your patterns.',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.white70,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildAlgorithmDropdown(),
              const SizedBox(height: 20),
              if (_selectedAlgorithm != null)
                ElevatedButton(
                  onPressed: _fetchPatterns,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                  child: const Text(
                    'Find Patterns',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
            const SizedBox(height: 40),
            // Results
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_errorMessage != null)
              Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            if (!_loading &&
                _errorMessage == null &&
                _patterns.isNotEmpty)
              _buildPatternsResult(context),
            if (!_loading &&
                _errorMessage == null &&
                _patterns.isEmpty &&
                _timeSpan != null &&
                _selectedAlgorithm != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    'No patterns found for this selection.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.white70),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _timePeriodOption(
    BuildContext context,
    String label,
    String timeSpanValue,
  ) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _timeSpan = timeSpanValue;
          _selectedAlgorithm = null;
          _patterns = [];
          _errorMessage = null;
        });
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: _timeSpan == timeSpanValue
            ? Colors.deepPurple
            : Colors.deepPurpleAccent,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildAlgorithmDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedAlgorithm,
          hint: const Text(
            'Select Algorithm',
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
          dropdownColor: Colors.white,
          icon: const Icon(
            Icons.arrow_drop_down_circle,
            color: Colors.deepPurpleAccent,
          ),
          iconSize: 24,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          items: const [
            DropdownMenuItem(
              value: 'frequency',
              child: Text('Frequency-based'),
            ),
            DropdownMenuItem(
              value: 'normalized',
              child: Text('Mood Normalized Frequency'),
            ),
            DropdownMenuItem(
              value: 'correlation',
              child: Text('Option-Mood Correlation'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedAlgorithm = value;
            });
          },
        ),
      ),
    );
  }

  /// Fetch pattern results by the chosen algorithm and time span
  void _fetchPatterns() async {
    if (_timeSpan == null || _selectedAlgorithm == null) {
      return;
    }

    setState(() {
      _loading = true;
      _patterns = [];
      _errorMessage = null;
    });

    try {
      List<Report> reports;
      if (_timeSpan == '7days') {
        reports = await _firestoreService.getReportsForLast7Days();
      } else if (_timeSpan == '30days') {
        reports = await _firestoreService.getReportsForLast30Days();
      } else {
        reports = await _firestoreService.getAllReports();
      }

      // Analyze patterns
      List<PatternResult> foundPatterns =
          _analyzePatterns(reports, algorithm: _selectedAlgorithm!);

      setState(() {
        _patterns = foundPatterns;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error finding patterns: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  /// Main method that runs the chosen algorithm and then **aggregates** by
  /// (question, optionValue, mood) so you don't get duplicates.
  List<PatternResult> _analyzePatterns(
    List<Report> reports, {
    required String algorithm,
  }) {
    final stats = OptionMoodStats();
    // We'll keep track of all occurrences (question, option, mood)
    final List<Map<String, String>> occurrences = [];

    for (var report in reports) {
      final mood = report.mood.toLowerCase();
      for (var question in report.questions) {
        // Consider only single or multiple choice
        if (question.type.toLowerCase() == 'single choice' ||
            question.type.toLowerCase() == 'multiple choice') {
          if (question.selected != null) {
            for (var selectedOption in question.selected!) {
              stats.addOccurrence(selectedOption.value, mood);
              occurrences.add({
                'question': question.text,
                'option': selectedOption.value,
                'mood': mood,
              });
            }
          }
        }
      }
    }

    // Step 1: Run the selected algorithm for (optionValue,mood)
    List<PatternResult> baseResults;
    switch (algorithm) {
      case 'frequency':
        baseResults = stats.frequencyBasedPatterns(limit: 200);
        break;
      case 'normalized':
        baseResults = stats.moodNormalizedPatterns(limit: 200);
        break;
      case 'correlation':
        baseResults = stats.correlationPatterns(limit: 200);
        break;
      default:
        baseResults = stats.frequencyBasedPatterns(limit: 200);
        break;
    }

    // Step 2: Aggregate results so each (question,option,mood) is only shown once.
    // First, we'll match the base algorithm results with the corresponding questions.
    // We'll store them in an aggregator: aggregator[question][option][mood] = aggregatedScore
    final Map<String, Map<String, Map<String, int>>> aggregator = {};

    for (var baseRes in baseResults) {
      // All occurrences that match this (optionValue, mood)
      final matched = occurrences.where((o) =>
          o['option'] == baseRes.optionValue && o['mood'] == baseRes.mood);

      // For each matched occurrence, aggregate in a map
      for (var m in matched) {
        final q = m['question']!;
        final opt = baseRes.optionValue;
        final md = baseRes.mood;
        aggregator.putIfAbsent(q, () => {});
        aggregator[q]!.putIfAbsent(opt, () => {});
        aggregator[q]![opt]!.putIfAbsent(md, () => 0);
        // Sum up the scores (or just keep the highest, but summation is typical)
        aggregator[q]![opt]![md] = aggregator[q]![opt]![md]! + baseRes.count;
      }
    }

    // Convert aggregator map to a final list
    final List<PatternResult> finalResults = [];
    aggregator.forEach((questionText, optionMap) {
      optionMap.forEach((optVal, moodMap) {
        moodMap.forEach((md, score) {
          finalResults.add(
            PatternResult(
              question: questionText,
              optionValue: optVal,
              mood: md,
              count: score,
            ),
          );
        });
      });
    });

    // Sort final results descending by 'count'
    finalResults.sort((a, b) => b.count.compareTo(a.count));
    // Return them. You can cap them with .take(n).toList() if desired.
    return finalResults;
  }

  Widget _buildPatternsResult(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patterns Found',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'These options correlate strongly with certain moods. Switch the view mode below:',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 16),
        _buildViewModeToggle(),
        const SizedBox(height: 16),
        if (_viewMode == 'mood') _buildResultsByMood(context),
        if (_viewMode == 'question') _buildResultsByQuestion(context),
      ],
    );
  }

  Widget _buildViewModeToggle() {
    return Center(
      child: Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: const Text('View by Mood'),
            selected: _viewMode == 'mood',
            selectedColor: Colors.deepPurpleAccent,
            onSelected: (selected) {
              setState(() {
                _viewMode = 'mood';
              });
            },
          ),
          ChoiceChip(
            label: const Text('View by Question'),
            selected: _viewMode == 'question',
            selectedColor: Colors.deepPurpleAccent,
            onSelected: (selected) {
              setState(() {
                _viewMode = 'question';
              });
            },
          ),
        ],
      ),
    );
  }

  ///
  ///  VIEW BY MOOD
  ///
  Widget _buildResultsByMood(BuildContext context) {
    // Group patterns by mood: mood -> List<PatternResult>
    final Map<String, List<PatternResult>> moodGroups = {};
    for (final p in _patterns) {
      moodGroups.putIfAbsent(p.mood, () => []);
      moodGroups[p.mood]!.add(p);
    }

    return Column(
      children: moodGroups.keys.map((mood) {
        // Sort the group to show highest "score" first
        final group = moodGroups[mood]!
          ..sort((a, b) => b.count.compareTo(a.count));

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          color: Colors.grey[100],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
          child: ExpansionTile(
            initiallyExpanded: false,
            title: Text(
              '${mood[0].toUpperCase()}${mood.substring(1)} Mood',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  children: group.map((pattern) {
                    return ListTile(
                      title: Text(
                        pattern.question,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        'Option: ${pattern.optionValue}\nScore: ${pattern.count}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  ///
  ///  VIEW BY QUESTION
  ///
  Widget _buildResultsByQuestion(BuildContext context) {
    // Group patterns by question: question -> List<PatternResult>
    final Map<String, List<PatternResult>> questionGroups = {};
    for (final p in _patterns) {
      questionGroups.putIfAbsent(p.question, () => []);
      questionGroups[p.question]!.add(p);
    }

    return Column(
      children: questionGroups.keys.map((questionText) {
        final group = questionGroups[questionText]!
          ..sort((a, b) => b.count.compareTo(a.count));

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          color: Colors.grey[100],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
          child: ExpansionTile(
            initiallyExpanded: false,
            title: Text(
              questionText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  children: group.map((pattern) {
                    return ListTile(
                      title: Text(
                        'Option: ${pattern.optionValue}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        'Mood: ${pattern.mood[0].toUpperCase()}${pattern.mood.substring(1)} | Score: ${pattern.count}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
