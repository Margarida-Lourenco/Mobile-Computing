import 'package:flutter/material.dart';
import '../models/opportunity.dart';
import '../theme/app_theme.dart';

class EventCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final List<Opportunity> events;
  final ValueChanged<DateTime> onSelected;
  const EventCalendar(
      {super.key,
      required this.selectedDate,
      required this.events,
      required this.onSelected});
  @override
  State<EventCalendar> createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar> {
  late DateTime month;
  @override
  void initState() {
    super.initState();
    month = DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final offset = first.weekday - 1;
    final cells = ((days + offset + 6) ~/ 7) * 7;
    return Container(
        margin: const EdgeInsets.only(top: AppSpacing.s14),
        padding: const EdgeInsets.all(AppSpacing.s8),
        decoration: appCardDecoration(),
        child: Column(children: [
          Row(children: [
            IconButton(
                tooltip: 'Previous month',
                onPressed: () => setState(
                    () => month = DateTime(month.year, month.month - 1)),
                icon: const Icon(Icons.chevron_left)),
            Expanded(
                child: Text(
                    MaterialLocalizations.of(context).formatMonthYear(month),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyBold)),
            IconButton(
                tooltip: 'Next month',
                onPressed: () => setState(
                    () => month = DateTime(month.year, month.month + 1)),
                icon: const Icon(Icons.chevron_right))
          ]),
          Row(
              children: List.generate(
                  7,
                  (i) => Expanded(
                      child: Text(
                          MaterialLocalizations.of(context)
                              .narrowWeekdays[(i + 1) % 7],
                          textAlign: TextAlign.center,
                          style: AppTextStyles.captionMuted)))),
          for (int week = 0; week < cells ~/ 7; week++)
            Row(
                children: List.generate(7, (column) {
              final day = week * 7 + column - offset + 1;
              if (day < 1 || day > days) {
                return const Expanded(child: SizedBox(height: 48));
              }
              final date = DateTime(month.year, month.month, day);
              final count = widget.events
                  .where((e) =>
                      e.startsAt != null &&
                      !e.cancelled &&
                      DateUtils.isSameDay(e.startsAt, date))
                  .length;
              final selected = DateUtils.isSameDay(widget.selectedDate, date);
              return Expanded(
                  child: Semantics(
                      label:
                          '${MaterialLocalizations.of(context).formatFullDate(date)}, $count signed-up events',
                      selected: selected,
                      button: true,
                      child: InkWell(
                          key: ValueKey(
                              'calendar-${date.year}-${date.month}-$day'),
                          onTap: () => widget.onSelected(date),
                          child: Container(
                              height: 48,
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.navy
                                      : count > 0
                                          ? AppColors.paleGreen
                                          : AppColors.white,
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.r10)),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('$day',
                                        style: selected
                                            ? AppTextStyles.calendarSelected
                                            : AppTextStyles.captionNavy),
                                    if (count > 0)
                                      Icon(Icons.circle,
                                          key: ValueKey(
                                              'event-dot-${date.year}-${date.month}-$day'),
                                          size: 6,
                                          color: selected
                                              ? AppColors.white
                                              : AppColors.darkBlue)
                                  ])))));
            })),
          const Padding(
              padding: EdgeInsets.all(AppSpacing.s8),
              child: Text('● Marked dates have events you joined',
                  style: AppTextStyles.captionMuted)),
        ]));
  }
}
