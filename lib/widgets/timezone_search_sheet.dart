import 'package:flutter/material.dart';
import '../models/timezone_entry.dart';
import '../data/timezone_data.dart';
import '../theme/app_theme.dart';
import 'dart:ui';

class TimezoneSearchSheet extends StatefulWidget {
  final List<String> alreadyAddedIds;
  final void Function(TimezoneEntry entry) onSelected;

  const TimezoneSearchSheet({
    super.key,
    required this.alreadyAddedIds,
    required this.onSelected,
  });

  @override
  State<TimezoneSearchSheet> createState() => _TimezoneSearchSheetState();
}

class _TimezoneSearchSheetState extends State<TimezoneSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<TimezoneEntry> _filtered = allTimezones;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = allTimezones;
      } else {
        _filtered = allTimezones.where((tz) {
          return tz.cityName.toLowerCase().contains(query) ||
              tz.countryName.toLowerCase().contains(query) ||
              tz.timezoneName.toLowerCase().contains(query) ||
              tz.offsetLabel.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xEE111827),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: AppColors.glassBorder),
              left: BorderSide(color: AppColors.glassBorder),
              right: BorderSide(color: AppColors.glassBorder),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Add a City',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Outfit',
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search city or country...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                color: AppColors.textMuted, size: 48),
                            const SizedBox(height: 12),
                            const Text(
                              'No cities found',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontFamily: 'Outfit',
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final tz = _filtered[index];
                          final alreadyAdded =
                              widget.alreadyAddedIds.contains(tz.id);
                          return _SearchResultTile(
                            entry: tz,
                            alreadyAdded: alreadyAdded,
                            onTap: alreadyAdded
                                ? null
                                : () {
                                    widget.onSelected(tz);
                                    Navigator.of(context).pop();
                                  },
                          );
                        },
                      ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final TimezoneEntry entry;
  final bool alreadyAdded;
  final VoidCallback? onTap;

  const _SearchResultTile({
    required this.entry,
    required this.alreadyAdded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: alreadyAdded ? 0.45 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.glassOverlay,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              Text(
                entry.countryFlag,
                style: const TextStyle(fontSize: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.cityName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'Outfit',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Text(
                  entry.offsetLabel,
                  style: const TextStyle(
                    color: AppColors.accentEnd,
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (alreadyAdded) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.accentEnd, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
