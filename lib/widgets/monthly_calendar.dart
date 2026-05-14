import 'package:flutter/material.dart';
import '../models/drink_record.dart';

class MonthlyCalendar extends StatefulWidget {
  final List<DrinkRecord> records;
  final int dailyGoalMl;

  static const primary = Color(0xFF1976D2);
  static const primaryLight = Color(0xFFE3F2FD);
  static const success = Color(0xFF4CAF50);
  static const successLight = Color(0xFFE8F5E9);
  static const successGradStart = Color(0xFFA5D6A7);
  static const successGradEnd = Color(0xFF66BB6A);
  static const emptyGray = Color(0xFFF5F5F5);
  static const textMain = Color(0xFF333333);
  static const textSub = Color(0xFF666666);
  static const textLight = Color(0xFF999999);
  static const cellSize = 44.0;
  static const cellGap = 4.0;

  const MonthlyCalendar({
    super.key,
    required this.records,
    required this.dailyGoalMl,
  });

  @override
  State<MonthlyCalendar> createState() => _MonthlyCalendarState();
}

class _MonthlyCalendarState extends State<MonthlyCalendar> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
  }

  Map<int, int> get _dailyTotals {
    final map = <int, int>{};
    for (final r in widget.records) {
      if (r.timestamp.year == _year && r.timestamp.month == _month) {
        final d = r.timestamp.day;
        map[d] = (map[d] ?? 0) + r.volume;
      }
    }
    return map;
  }

  int get _daysInMonth => DateTime(_year, _month + 1, 0).day;
  int get _firstWeekday {
    final w = DateTime(_year, _month, 1).weekday; // 1=Mon..7=Sun
    return w;
  }

  bool _isToday(int day) {
    final now = DateTime.now();
    return _year == now.year && _month == now.month && day == now.day;
  }

  bool _isPast(int day) {
    final now = DateTime.now();
    final d = DateTime(_year, _month, day);
    return d.isBefore(DateTime(now.year, now.month, now.day));
  }

  int _streakLength(int day, Map<int, bool> dayMet) {
    // Compute backwards streak from this day
    int count = 0;
    for (var d = day; d >= 1; d--) {
      if (dayMet[d] == true) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  void _prevMonth() {
    setState(() {
      if (_month == 1) {
        _year--;
        _month = 12;
      } else {
        _month--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_month == 12) {
        _year++;
        _month = 1;
      } else {
        _month++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final canGoNext = !(_year == now.year && _month >= now.month);

    // Compute which days met the goal
    final dayMet = <int, bool>{};
    int metCount = 0;
    int streakDays = 0;
    int currentStreak = 0;
    for (var d = 1; d <= _daysInMonth; d++) {
      final vol = _dailyTotals[d] ?? 0;
      final met = vol >= widget.dailyGoalMl;
      dayMet[d] = met;
      if (met) {
        metCount++;
        currentStreak++;
        if (currentStreak > streakDays) streakDays = currentStreak;
      } else {
        currentStreak = 0;
      }
    }

    // Total monthly volume
    final totalMl = _dailyTotals.values.fold(0, (a, b) => a + b);
    final totalLiters = (totalMl / 1000).toStringAsFixed(1);

    // Cells: leading blanks + days
    final cells = <Widget>[];
    for (var i = 1; i < _firstWeekday; i++) {
      cells.add(const SizedBox(width: MonthlyCalendar.cellSize, height: MonthlyCalendar.cellSize));
    }
    for (var d = 1; d <= _daysInMonth; d++) {
      cells.add(_DayCell(
        day: d,
        isToday: _isToday(d),
        isPast: _isPast(d),
        metGoal: dayMet[d] ?? false,
        volume: _dailyTotals[d] ?? 0,
        dailyGoalMl: widget.dailyGoalMl,
        streakLen: _streakLength(d, dayMet),
      ));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          // ---- Monthly Summary Bar ----
          _SummaryBar(
            metDays: metCount,
            totalDays: _daysInMonth,
            streakDays: streakDays,
            totalLiters: totalLiters,
          ),
          const SizedBox(height: 12),

          // ---- Calendar Header ----
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: IconButton(
                  onPressed: _prevMonth,
                  icon: const Icon(Icons.chevron_left, size: 20),
                  color: MonthlyCalendar.textSub,
                  padding: EdgeInsets.zero,
                ),
              ),
              Text(
                '${_year}年${_month}月',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: MonthlyCalendar.textMain,
                ),
              ),
              SizedBox(
                width: 44,
                height: 44,
                child: IconButton(
                  onPressed: canGoNext ? _nextMonth : null,
                  icon: const Icon(Icons.chevron_right, size: 20),
                  color: canGoNext ? MonthlyCalendar.textSub : MonthlyCalendar.textLight,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // ---- Weekday Header ----
          const _WeekdayHeader(),
          const SizedBox(height: 4),

          // ---- Date Grid ----
          Wrap(
            spacing: MonthlyCalendar.cellGap,
            runSpacing: MonthlyCalendar.cellGap,
            children: cells,
          ),
        ],
      ),
    );
  }
}

// ---- Summary Bar ----
class _SummaryBar extends StatelessWidget {
  final int metDays;
  final int totalDays;
  final int streakDays;
  final String totalLiters;

  const _SummaryBar({
    required this.metDays,
    required this.totalDays,
    required this.streakDays,
    required this.totalLiters,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(
          icon: Icons.check_circle_outline,
          iconColor: const Color(0xFF4CAF50),
          value: '$metDays/$totalDays',
          label: '天达标',
        ),
        _StatItem(
          icon: Icons.local_fire_department,
          iconColor: const Color(0xFFFF9800),
          value: '$streakDays',
          label: '连续天',
        ),
        _StatItem(
          icon: Icons.water_drop,
          iconColor: const Color(0xFF1976D2),
          value: '${totalLiters}L',
          label: '总饮水量',
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: MonthlyCalendar.textMain,
            height: 1.2,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: MonthlyCalendar.textSub,
          ),
        ),
      ],
    );
  }
}

// ---- Weekday Header ----
class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    const days = ['一', '二', '三', '四', '五', '六', '日'];
    return Row(
      children: days.map((d) {
        final isWeekend = d == '六' || d == '日';
        return SizedBox(
          width: MonthlyCalendar.cellSize,
          height: 32,
          child: Center(
            child: Text(
              d,
              style: TextStyle(
                fontSize: 12,
                color: isWeekend
                    ? MonthlyCalendar.textLight
                    : MonthlyCalendar.textSub,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---- Day Cell ----
class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isPast;
  final bool metGoal;
  final int volume;
  final int dailyGoalMl;
  final int streakLen;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isPast,
    required this.metGoal,
    required this.volume,
    required this.dailyGoalMl,
    required this.streakLen,
  });

  double get _progress => dailyGoalMl > 0 ? (volume / dailyGoalMl).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    Color ringColor;
    Widget? overlay;

    if (isToday) {
      if (metGoal) {
        bg = MonthlyCalendar.success;
        textColor = Colors.white;
        ringColor = MonthlyCalendar.success;
        overlay = const Icon(Icons.check, size: 16, color: Colors.white);
      } else {
        bg = MonthlyCalendar.primaryLight;
        textColor = MonthlyCalendar.primary;
        ringColor = MonthlyCalendar.primary;
      }
    } else if (isPast && metGoal) {
      ringColor = MonthlyCalendar.success;
      if (streakLen >= 3) {
        bg = MonthlyCalendar.successGradEnd;
        textColor = Colors.white;
      } else {
        bg = MonthlyCalendar.successLight;
        textColor = const Color(0xFF2E7D32);
      }
    } else if (isPast && !metGoal) {
      bg = MonthlyCalendar.emptyGray;
      textColor = MonthlyCalendar.textSub;
      ringColor = MonthlyCalendar.primary;
    } else {
      bg = Colors.transparent;
      textColor = MonthlyCalendar.textMain;
      ringColor = MonthlyCalendar.textLight;
    }

    return Container(
      width: MonthlyCalendar.cellSize,
      height: MonthlyCalendar.cellSize,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(color: MonthlyCalendar.primary, width: 2)
            : streakLen >= 7
                ? Border.all(color: const Color(0xFFFFD700), width: 1.5)
                : null,
        gradient: (isPast && metGoal && streakLen >= 3 && !isToday)
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [MonthlyCalendar.successGradStart, MonthlyCalendar.successGradEnd],
              )
            : null,
      ),
      child: Stack(
        children: [
          // Circular progress ring
          if (volume > 0 || isToday)
            Center(
              child: SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  value: isPast || (isToday && metGoal) ? _progress : null,
                  strokeWidth: 2.5,
                  backgroundColor: ringColor.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(ringColor),
                ),
              ),
            ),
          // Day number + volume
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w400,
                    color: textColor,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          if (overlay != null) overlay,
        ],
      ),
    );
  }
}
