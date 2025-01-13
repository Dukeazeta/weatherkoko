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
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final List<String> weekDays = ['Mon', 'Wed', 'Fri'];
  Map<String, bool> activityData = {};
  int currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
    await _recordDailyVisit();
    _loadActivityData();
  }

  Future<void> _recordDailyVisit() async {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    
    // Record today's visit
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
    
    // Load last 365 days of activity
    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
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
                    const SizedBox(height: 28), // Spacing for month row
                    ...weekDays.map((day) => Container(
                      height: 30,
                      padding: const EdgeInsets.only(right: 8),
                      alignment: Alignment.centerRight,
                      child: Text(
                        day,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
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
                        final now = DateTime.now();
                        final yearStart = DateTime(now.year, 1);
                        final monthDate = now.subtract(Duration(days: monthIndex * 30));
                        final monthName = months[monthDate.month - 1];
                        
                        return Container(
                          width: 52,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            monthName,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).reversed.toList(), // Reverse to show current month on the right
                    ),
                    const SizedBox(height: 8),
                    // Activity squares
                    Row(
                      children: List.generate(52, (weekIndex) {
                        return Column(
                          children: List.generate(7, (dayIndex) {
                            final date = DateTime.now().subtract(
                              Duration(days: weekIndex * 7 + dayIndex),
                            );
                            final dateStr = DateFormat('yyyy-MM-dd').format(date);
                            return Padding(
                              padding: const EdgeInsets.all(2),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _getActivityColor(activityData[dateStr]),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }),
                        );
                      }).reversed.toList(), // Reverse to show recent activity on the right
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
                  fontSize: 12,
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
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}