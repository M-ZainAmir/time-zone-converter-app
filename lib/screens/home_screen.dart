import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/timezone_entry.dart';
import '../data/timezone_data.dart';
import '../theme/app_theme.dart';
import '../widgets/timezone_card.dart';
import '../widgets/timezone_search_sheet.dart';
import '../widgets/world_clock_ring.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  // Currently displayed timezone entries (ordered list)
  final List<TimezoneEntry> _entries = [];

  // Live UTC "now" updated every second
  DateTime _utcNow = DateTime.now().toUtc();
  Timer? _ticker;

  // Animation controller for header
  late final AnimationController _headerAnimCtrl;
  late final Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _utcNow = DateTime.now().toUtc());
    });

    _headerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerFade = CurvedAnimation(
        parent: _headerAnimCtrl, curve: Curves.easeOut);
    _headerAnimCtrl.forward();

    // Default cities
    _addDefaultCities();
  }

  void _addDefaultCities() {
    final defaults = ['new_york', 'london', 'dubai', 'tokyo', 'sydney'];
    for (final id in defaults) {
      final entry = allTimezones.firstWhere((e) => e.id == id);
      _entries.add(entry);
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _headerAnimCtrl.dispose();
    super.dispose();
  }

  /// Convert _utcNow to local time for the given UTC offset (in minutes).
  DateTime _timeForEntry(TimezoneEntry entry) {
    return _utcNow
        .add(Duration(minutes: entry.utcOffsetMinutes));
  }

  void _removeEntry(int index) {
    HapticFeedback.lightImpact();
    setState(() => _entries.removeAt(index));
  }

  void _setReference(int index) {
    if (index == 0) return;
    HapticFeedback.selectionClick();
    setState(() {
      final entry = _entries.removeAt(index);
      _entries.insert(0, entry);
    });
  }

  void _addEntry(TimezoneEntry entry) {
    HapticFeedback.mediumImpact();
    setState(() => _entries.add(entry));
  }

  void _showSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => TimezoneSearchSheet(
          alreadyAddedIds: _entries.map((e) => e.id).toList(),
          onSelected: _addEntry,
        ),
      ),
    );
  }

  void _showTimeConverter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _TimeConverterSheet(
        entries: _entries,
        utcNow: _utcNow,
        onTimeForEntry: _timeForEntry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final times = _entries.map(_timeForEntry).toList();
    final refTime = times.isNotEmpty ? times[0] : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── App Bar ───────────────────────────────────
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 140,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.compare_arrows_rounded,
                    color: AppColors.textPrimary),
                tooltip: 'Time Converter',
                onPressed: _entries.length >= 2 ? _showTimeConverter : null,
              ),
              const SizedBox(width: 8),
            ],
          ),

          // ─── Mini Clock Strip ──────────────────────────
          if (_entries.isNotEmpty)
            SliverToBoxAdapter(
              child: WorldClockRing(entries: _entries, times: times),
            ),

          if (_entries.isNotEmpty)
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ─── Section Header ────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Your Locations',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_entries.length} cities',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontFamily: 'Outfit',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ─── Timezone Cards ────────────────────────────
          if (_entries.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = _entries[index];
                    final entryTime = times[index];
                    final diff = refTime != null && index > 0
                        ? entryTime.difference(refTime)
                        : null;
                    return TimezoneCard(
                      key: ValueKey(entry.id),
                      entry: entry,
                      currentTime: entryTime,
                      diffFromFirst: diff,
                      isFirst: index == 0,
                      onRemove: () => _removeEntry(index),
                      onSetReference: () => _setReference(index),
                    );
                  },
                  childCount: _entries.length,
                ),
              ),
            ),
        ],
      ),

      // ─── FAB ───────────────────────────────────────
      floatingActionButton: _AnimatedFab(onTap: _showSearchSheet),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerFade,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F1629), AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.primaryGradient.createShader(bounds),
                  child: const Text(
                    'WorldTime',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Outfit',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('🌍', style: TextStyle(fontSize: 24)),
              ],
            ),
            const Text(
              'Compare time zones across the globe',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Outfit',
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌐', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'No cities added yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'Outfit',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to add cities and compare\ntime zones across the world',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'Outfit',
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          _GradientButton(
            label: 'Add a City',
            icon: Icons.add_rounded,
            onTap: _showSearchSheet,
          ),
        ],
      ),
    );
  }
}

// ─── Animated FAB ────────────────────────────────────────

class _AnimatedFab extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedFab({required this.onTap});

  @override
  State<_AnimatedFab> createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<_AnimatedFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentStart.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

// ─── Gradient Button ─────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentStart.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Time Converter Sheet ─────────────────────────────────

class _TimeConverterSheet extends StatefulWidget {
  final List<TimezoneEntry> entries;
  final DateTime utcNow;
  final DateTime Function(TimezoneEntry) onTimeForEntry;

  const _TimeConverterSheet({
    required this.entries,
    required this.utcNow,
    required this.onTimeForEntry,
  });

  @override
  State<_TimeConverterSheet> createState() => _TimeConverterSheetState();
}

class _TimeConverterSheetState extends State<_TimeConverterSheet> {
  // Source time to convert (defaults to current time in first zone)
  late int _selectedHour;
  late int _selectedMinute;
  late TimezoneEntry _sourceZone;

  @override
  void initState() {
    super.initState();
    _sourceZone = widget.entries[0];
    final sourceTime = widget.onTimeForEntry(_sourceZone);
    _selectedHour = sourceTime.hour;
    _selectedMinute = sourceTime.minute;
  }

  DateTime _convertedTime(TimezoneEntry target) {
    // Build a DateTime with source offset applied
    final sourceUtc = DateTime.utc(
      widget.utcNow.year,
      widget.utcNow.month,
      widget.utcNow.day,
      _selectedHour,
      _selectedMinute,
    ).subtract(Duration(minutes: _sourceZone.utcOffsetMinutes));
    return sourceUtc
        .add(Duration(minutes: target.utcOffsetMinutes));
  }

  String _fmt(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xEE111827),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.glassBorder),
          left: BorderSide(color: AppColors.glassBorder),
          right: BorderSide(color: AppColors.glassBorder),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Time Converter',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Outfit',
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pick a source time and see it across all your cities.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Outfit',
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),

            // Source selector
            const Text(
              'SOURCE CITY',
              style: TextStyle(
                color: AppColors.textMuted,
                fontFamily: 'Outfit',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.entries.length,
                itemBuilder: (_, i) {
                  final e = widget.entries[i];
                  final selected = e.id == _sourceZone.id;
                  return GestureDetector(
                    onTap: () => setState(() => _sourceZone = e),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 0),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? AppColors.primaryGradient
                            : null,
                        color: selected ? null : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? Colors.transparent
                              : AppColors.glassBorder,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${e.countryFlag} ${e.cityName}',
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Time picker
            const Text(
              'SELECT TIME',
              style: TextStyle(
                color: AppColors.textMuted,
                fontFamily: 'Outfit',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            _TimePicker(
              hour: _selectedHour,
              minute: _selectedMinute,
              onChanged: (h, m) => setState(() {
                _selectedHour = h;
                _selectedMinute = m;
              }),
            ),

            const SizedBox(height: 24),
            const Text(
              'CONVERTED TIMES',
              style: TextStyle(
                color: AppColors.textMuted,
                fontFamily: 'Outfit',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),

            // Results
            ...widget.entries.map((e) {
              final converted = _convertedTime(e);
              final isSource = e.id == _sourceZone.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: isSource
                      ? LinearGradient(colors: [
                          AppColors.accentStart.withOpacity(0.2),
                          AppColors.accentEnd.withOpacity(0.1),
                        ])
                      : null,
                  color: isSource ? null : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSource
                        ? AppColors.accentStart.withOpacity(0.5)
                        : AppColors.glassBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Text(e.countryFlag,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.cityName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontFamily: 'Outfit',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            e.offsetLabel,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontFamily: 'Outfit',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ShaderMask(
                          shaderCallback: (b) =>
                              AppColors.primaryGradient.createShader(b),
                          child: Text(
                            _fmt(converted),
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Outfit',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (converted.day !=
                            DateTime.utc(
                                    widget.utcNow.year,
                                    widget.utcNow.month,
                                    widget.utcNow.day,
                                    _selectedHour,
                                    _selectedMinute)
                                .add(Duration(
                                    minutes: _sourceZone.utcOffsetMinutes))
                                .day)
                          Text(
                            converted.day < _selectedHour
                                ? '–1 day'
                                : '+1 day',
                            style: const TextStyle(
                              color: AppColors.accentPink,
                              fontFamily: 'Outfit',
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            SizedBox(
                height: MediaQuery.of(context).padding.bottom + 30),
          ],
        ),
      ),
    );
  }
}

// ─── Time Picker ─────────────────────────────────────────

class _TimePicker extends StatelessWidget {
  final int hour;
  final int minute;
  final void Function(int hour, int minute) onChanged;

  const _TimePicker({
    required this.hour,
    required this.minute,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          // Hour slider
          Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  'H',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.accentStart,
                    inactiveTrackColor: AppColors.divider,
                    thumbColor: Colors.white,
                    overlayColor: AppColors.accentStart.withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: hour.toDouble(),
                    min: 0,
                    max: 23,
                    divisions: 23,
                    onChanged: (v) => onChanged(v.toInt(), minute),
                  ),
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  hour.toString().padLeft(2, '0'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          // Minute slider
          Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  'M',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.accentEnd,
                    inactiveTrackColor: AppColors.divider,
                    thumbColor: Colors.white,
                    overlayColor: AppColors.accentEnd.withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: minute.toDouble(),
                    min: 0,
                    max: 59,
                    divisions: 59,
                    onChanged: (v) => onChanged(hour, v.toInt()),
                  ),
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  minute.toString().padLeft(2, '0'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Big time display
          Center(
            child: ShaderMask(
              shaderCallback: (b) =>
                  AppColors.primaryGradient.createShader(b),
              child: Text(
                () {
                  final h = hour % 12 == 0 ? 12 : hour % 12;
                  final m = minute.toString().padLeft(2, '0');
                  final amPm = hour < 12 ? 'AM' : 'PM';
                  return '$h:$m $amPm';
                }(),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Outfit',
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
