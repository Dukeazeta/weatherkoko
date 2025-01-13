import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreakIndicator extends StatefulWidget {
  const StreakIndicator({super.key});

  @override
  State<StreakIndicator> createState() => _StreakIndicatorState();
}

class _StreakIndicatorState extends State<StreakIndicator> {
  late SharedPreferences prefs;
  int currentStreak = 0;
  List<bool> weekActivity = List.filled(7, false);

  @override
  void initState() {
    super.initState();
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
    _updateStreak();
  }

  void _updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();
    
    // Record today's visit
    prefs.setString('visit_$today', 'true');
    
    // Calculate current streak
    int streak = 0;
    DateTime checkDate = now;
    
    while (true) {
      final dateStr = DateTime(
        checkDate.year,
        checkDate.month,
        checkDate.day,
      ).toIso8601String();
      
      if (prefs.getString('visit_$dateStr') != null) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    setState(() {
      currentStreak = streak;
      weekActivity = _getLastSevenDaysActivity();
    });
  }

  List<bool> _getLastSevenDaysActivity() {
    List<bool> activity = List.filled(7, false);
    final now = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateTime(date.year, date.month, date.day).toIso8601String();
      activity[6 - i] = prefs.getString('visit_$dateStr') != null;
    }
    
    return activity;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🔥',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                '$currentStreak day streak',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: weekActivity.map((active) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: active ? Colors.green[400] : Colors.grey[800],
                borderRadius: BorderRadius.circular(4),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}