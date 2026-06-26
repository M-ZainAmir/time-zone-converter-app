class TimezoneEntry {
  final String id;
  final String cityName;
  final String countryName;
  final String countryFlag;
  final String timezoneName; // IANA timezone string
  final int utcOffsetMinutes; // offset in minutes from UTC

  const TimezoneEntry({
    required this.id,
    required this.cityName,
    required this.countryName,
    required this.countryFlag,
    required this.timezoneName,
    required this.utcOffsetMinutes,
  });

  String get offsetLabel {
    final hours = utcOffsetMinutes ~/ 60;
    final mins = (utcOffsetMinutes % 60).abs();
    final sign = hours >= 0 ? '+' : '';
    if (mins == 0) return 'UTC$sign${hours}h';
    return 'UTC$sign$hours:${mins.toString().padLeft(2, '0')}';
  }
}
