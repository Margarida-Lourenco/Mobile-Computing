import 'opportunity.dart';

class OpportunityOrder {
  /// Ongoing first, then soonest upcoming; past events are most recent first.
  /// Missing dates go last. A stable ID tie-break keeps live updates steady.
  static List<Opportunity> byDate(Iterable<Opportunity> items, DateTime now) {
    int group(Opportunity item) {
      if (item.startsAt == null) return 3;
      if (item.hasEnded(now)) return 2;
      return item.startsAt!.isAfter(now) ? 1 : 0;
    }

    return items.toList()
      ..sort((a, b) {
        final aGroup = group(a), bGroup = group(b);
        final byGroup = aGroup.compareTo(bGroup);
        if (byGroup != 0) return byGroup;
        final byTime = aGroup == 3
            ? 0
            : aGroup == 2
                ? b.completionTime!.compareTo(a.completionTime!)
                : a.startsAt!.compareTo(b.startsAt!);
        return byTime != 0 ? byTime : a.id.compareTo(b.id);
      });
  }
}
