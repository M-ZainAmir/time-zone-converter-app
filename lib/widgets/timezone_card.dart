import 'package:flutter/material.dart';
import '../models/timezone_entry.dart';
import '../theme/app_theme.dart';

class TimezoneCard extends StatelessWidget {
  final TimezoneEntry entry;
  final DateTime currentTime; // Time in the card's timezone
  final Duration? diffFromFirst; // Difference from the first card
  final bool isFirst;
  final VoidCallback onRemove;
  final VoidCallback onSetReference;

  const TimezoneCard({
    super.key,
    required this.entry,
    required this.currentTime,
    this.diffFromFirst,
    this.isFirst = false,
    required this.onRemove,
    required this.onSetReference,
  });

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final amPm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m:$s $amPm';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = days[dt.weekday - 1];
    final monthName = months[dt.month - 1];
    return '$dayName, $monthName ${dt.day}';
  }

  String _diffLabel() {
    if (diffFromFirst == null || diffFromFirst!.inMinutes == 0) return '';
    final totalMins = diffFromFirst!.inMinutes;
    final sign = totalMins > 0 ? '+' : '';
    final h = totalMins ~/ 60;
    final m = (totalMins % 60).abs();
    if (m == 0) return '${sign}${h}h';
    return '$sign${h}h ${m}m';
  }

  Color _timeOfDayColor(int hour) {
    if (hour >= 6 && hour < 12) return const Color(0xFFFFC857); // morning
    if (hour >= 12 && hour < 17) return const Color(0xFF48CAE4); // afternoon
    if (hour >= 17 && hour < 21) return const Color(0xFFFF9F6B); // evening
    return const Color(0xFF6C63FF); // night
  }

  String _timeOfDayIcon(int hour) {
    if (hour >= 5 && hour < 7) return '🌅'; // dawn
    if (hour >= 7 && hour < 12) return '☀️'; // morning
    if (hour >= 12 && hour < 17) return '🌤️'; // afternoon
    if (hour >= 17 && hour < 20) return '🌇'; // evening
    if (hour >= 20 && hour < 22) return '🌆'; // dusk
    return '🌙'; // night
  }

  @override
  Widget build(BuildContext context) {
    final hour = currentTime.hour;
    final todColor = _timeOfDayColor(hour);
    final gradColors = AppColors.gradientForHour(hour);
    final diff = _diffLabel();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: gradColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isFirst
              ? AppColors.accentStart.withValues(alpha: 0.6)
              : AppColors.glassBorder,
          width: isFirst ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isFirst ? AppColors.accentStart : Colors.black)
                .withValues(alpha: 0.25),
            blurRadius: isFirst ? 24 : 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onSetReference,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Flag + city info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                entry.countryFlag,
                                style: const TextStyle(fontSize: 22),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.cityName,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontFamily: 'Outfit',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      entry.countryName,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontFamily: 'Outfit',
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Top-right actions
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            if (isFirst)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Reference',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Outfit',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: onRemove,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.07),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textSecondary,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Time display
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatTime(currentTime),
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontFamily: 'Outfit',
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(currentTime),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontFamily: 'Outfit',
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _timeOfDayIcon(hour),
                          style: const TextStyle(fontSize: 26),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: todColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            entry.offsetLabel,
                            style: TextStyle(
                              color: todColor,
                              fontFamily: 'Outfit',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                if (diff.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.swap_horiz_rounded,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '$diff from reference',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontFamily: 'Outfit',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 14),
                // 24-hour progress bar
                _TimeProgressBar(hour: hour, minute: currentTime.minute),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeProgressBar extends StatelessWidget {
  final int hour;
  final int minute;

  const _TimeProgressBar({required this.hour, required this.minute});

  @override
  Widget build(BuildContext context) {
    final progress = (hour + minute / 60) / 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            // Background bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Progress bar
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('12 AM',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontFamily: 'Outfit',
                    fontSize: 10)),
            Text('12 PM',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontFamily: 'Outfit',
                    fontSize: 10)),
            Text('12 AM',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontFamily: 'Outfit',
                    fontSize: 10)),
          ],
        ),
      ],
    );
  }
}
