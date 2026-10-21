import 'package:flutter/material.dart';

import 'opportunity.dart';

class OpportunityFilters {
  static const categories = [
    'Social',
    'Outdoors',
    'Animals',
    'Housework',
    'Education',
    'Culture',
    'Sports',
    'Other',
  ];
  static const labels = ['All', 'Today', ...categories];
  static Set<String> toggle(Set<String> selected, String value) {
    if (value == 'All') return {'All'};
    final next = {...selected}..remove('All');
    if (!next.add(value)) next.remove(value);
    return next.isEmpty ? {'All'} : next;
  }

  static bool matches(Opportunity event, Set<String> selected, DateTime now) {
    if (selected.isEmpty || selected.contains('All')) return true;
    // Older Community/Food listings belong to Social and remain discoverable.
    final category = ['Community', 'Food'].contains(event.category)
        ? 'Social'
        : event.category;
    return selected.contains(category) ||
        (selected.contains('Today') &&
            (event.startsAt == null
                ? event.date == 'Today'
                : DateUtils.isSameDay(event.startsAt, now)));
  }
}
