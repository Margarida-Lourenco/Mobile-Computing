import 'opportunity.dart';

/// Derived from persisted sign-ups, so progress survives app restarts.
/// A sign-up counts as participation once its non-cancelled shift has ended.
class RewardProgress {
  final int completed;
  final double hours;
  const RewardProgress({this.completed = 0, this.hours = 0});

  factory RewardProgress.fromShifts(
      Iterable<Opportunity> events, Set<String> joined, DateTime now) {
    final shifts = events.where(
        (e) => joined.contains(e.id) && !e.cancelled && e.hasEnded(now));
    var hours = 0.0;
    for (final shift in shifts) {
      if (shift.startsAt != null && shift.endsAt != null) {
        final minutes = shift.endsAt!.difference(shift.startsAt!).inMinutes;
        if (minutes > 0) hours += minutes / 60;
      }
    }
    return RewardProgress(completed: shifts.length, hours: hours);
  }

  int get level => completed == 0 ? 1 : completed < 3 ? 2 : completed < 5 ? 3 : 3 + completed ~/ 5;
  String get title => level == 1 ? 'New Neighbor' : level == 2 ? 'Kind Neighbor' : level == 3 ? 'Helping Neighbor' : 'Local Hero';
  int get nextTarget => completed == 0 ? 1 : completed < 3 ? 3 : completed < 5 ? 5 : (completed ~/ 5 + 1) * 5;
  int get remaining => nextTarget - completed;
  double get progress => completed / nextTarget;
  int get badgesEarned => [completed >= 1, hours >= 3, completed >= 3, completed >= 5].where((earned) => earned).length;
}
