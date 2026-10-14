import 'opportunity.dart';

class CommunityImpact {
  final double hours;
  final int? accounts;
  final String month;
  const CommunityImpact(
      {required this.hours, required this.accounts, required this.month});

  /// Current European winter/summer time rules for the app's Gothenburg month.
  static int _offset(DateTime utc) {
    final year = utc.year;
    int lastSunday(int month) {
      final last = DateTime.utc(year, month + 1, 0);
      return last.day - last.weekday % 7;
    }

    final summerStart = DateTime.utc(year, 3, lastSunday(3), 1);
    final summerEnd = DateTime.utc(year, 10, lastSunday(10), 1);
    return !utc.isBefore(summerStart) && utc.isBefore(summerEnd) ? 2 : 1;
  }

  factory CommunityImpact.fromEvents(
      Iterable<Opportunity> events, int? accounts, DateTime now) {
    final utcNow = now.toUtc();
    final localNow = utcNow.add(Duration(hours: _offset(utcNow)));
    final first = DateTime.utc(localNow.year, localNow.month, 1);
    final monthStart = first.subtract(Duration(hours: _offset(first)));
    var hours = 0.0;
    for (final event in events) {
      final start = event.startsAt?.toUtc(), end = event.endsAt?.toUtc();
      if (event.cancelled ||
          start == null ||
          end == null ||
          !end.isAfter(start) ||
          end.isAfter(utcNow) ||
          end.isBefore(monthStart)) {
        continue;
      }
      final countedStart = start.isBefore(monthStart) ? monthStart : start;
      hours += end.difference(countedStart).inMilliseconds /
          3600000 *
          event.attendeeCount.clamp(0, event.spots);
    }
    return CommunityImpact(
        hours: hours,
        accounts: accounts,
        month: '${localNow.year}-${localNow.month.toString().padLeft(2, '0')}');
  }
}
