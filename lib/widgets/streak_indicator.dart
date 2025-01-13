import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class StreakIndicator extends StatefulWidget {
  const StreakIndicator({super.key});

  @override
  State<StreakIndicator> createState() => _StreakIndicatorState();
}

class _StreakIndicatorState extends State<StreakIndicator> {
  late SharedPreferences prefs;
  final List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  final List<String> weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];
  Map<String, bool> activityData = {};
  int currentStreak = 0;
  late DateTime firstDay;
  late int totalWeeks;

  @override
  void initState() {
    super.initState();
    _calculateDateRange();
    _initializePrefs();
  }

  void _calculateDateRange() {
    final now = DateTime.now();
    // Start from the first day of the year
    firstDay = DateTime(now.year, 1, 1);
    // Calculate weeks needed to show the full year
    int daysInYear = DateTime(now.year + 1, 1, 1).difference(firstDay).inDays;
    totalWeeks = (daysInYear / 7).ceil();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
    await _recordDailyVisit();
    _loadActivityData();
  }

  Future<void> _recordDailyVisit() async {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    await prefs.setBool('visit_$today', true);

    // Calculate current streak
    int streak = 0;
    DateTime checkDate = now;

    while (true) {
      final dateStr = DateFormat('yyyy-MM-dd').format(checkDate);
      if (prefs.getBool('visit_$dateStr') == true) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    setState(() {
      currentStreak = streak;
    });
  }

  void _loadActivityData() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);

    // Load activity data for the entire year
    for (DateTime date = startOfYear;
        date.isBefore(now.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final wasActive = prefs.getBool('visit_$dateStr') ?? false;
      activityData[dateStr] = wasActive;
    }
    setState(() {});
  }

  Color _getActivityColor(bool? active) {
    if (active == null || !active) return Colors.grey.shade800;
    return Colors.green.shade500;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$currentStreak',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'day${currentStreak == 1 ? '' : 's'} streak',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Week days column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(
                        height: 20), // Reduced spacing for better alignment
                    ...weekDays.map((day) => Container(
                          height: 14,
                          padding: const EdgeInsets.only(right: 8),
                          alignment: Alignment.centerRight,
                          child: Text(
                            day.substring(0, 1), // Show only first letter
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 10,
                            ),
                          ),
                        )),
                  ],
                ),
                // Activity grid
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Months row
                    Row(
                      children: List.generate(12, (monthIndex) {
                        final monthStart =
                            DateTime(firstDay.year, monthIndex + 1, 1);
                        final weekOffset =
                            monthStart.difference(firstDay).inDays ~/ 7;
                        final width = monthIndex < 11
                            ? DateTime(firstDay.year, monthIndex + 2, 1)
                                    .difference(monthStart)
                                    .inDays ~/
                                7 *
                                14
                            : (totalWeeks - weekOffset) * 14;

                        return Container(
                          width: width.toDouble(),
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            months[monthIndex],
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    // Activity squares
                    Row(
                      children: List.generate(totalWeeks, (weekIndex) {
                        return Column(
                          children: List.generate(7, (dayIndex) {
                            final date = firstDay.add(
                              Duration(days: weekIndex * 7 + dayIndex),
                            );
                            // Don't show future dates
                            if (date.isAfter(DateTime.now())) {
                              return Container(
                                margin: const EdgeInsets.all(2),
                                child: SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1E1E1E),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(2)),
                                    ),
                                  ),
                                ),
                              );
                            }

                            final dateStr =
                                DateFormat('yyyy-MM-dd').format(date);
                            return Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: _getActivityColor(activityData[dateStr]),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Less',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.green.shade500,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'More',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
