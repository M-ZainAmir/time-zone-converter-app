import 'package:flutter/material.dart';
import '../models/timezone_entry.dart';
import '../theme/app_theme.dart';

/// A horizontal scrollable clock-face or list showing all zones at a glance.
class WorldClockRing extends StatelessWidget {
  final List<TimezoneEntry> entries;
  final List<DateTime> times;

  const WorldClockRing({
    super.key,
    required this.entries,
    required this.times,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: entries.length,
        itemBuilder: (context, i) {
          final tz = entries[i];
          final dt = times[i];
          return _MiniClock(entry: tz, time: dt, isFirst: i == 0);
        },
      ),
    );
  }
}

class _MiniClock extends StatelessWidget {
  final TimezoneEntry entry;
  final DateTime time;
  final bool isFirst;

  const _MiniClock({
    required this.entry,
    required this.time,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final h = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final m = time.minute.toString().padLeft(2, '0');
    final amPm = time.hour < 12 ? 'AM' : 'PM';

    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFirst
              ? [
                  AppColors.accentStart.withValues(alpha: 0.3),
                  AppColors.accentEnd.withValues(alpha: 0.2)
                ]
              : [
                  AppColors.surfaceElevated,
                  AppColors.surfaceElevated.withValues(alpha: 0.8)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFirst
              ? AppColors.accentStart.withValues(alpha: 0.5)
              : AppColors.glassBorder,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(entry.countryFlag, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            '$h:$m',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'Outfit',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            amPm,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'Outfit',
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
