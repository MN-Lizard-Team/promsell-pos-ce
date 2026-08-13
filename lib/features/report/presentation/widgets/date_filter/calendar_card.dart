import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/month_name.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/date_filter/year_wheel_sheet.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:table_calendar/table_calendar.dart';

/// Calendar wrapped in a card with the app's theme.
/// Adds quick navigation for the current month, month picker, and year picker.
class CalendarCard extends StatefulWidget {
  const CalendarCard({
    super.key,
    required this.from,
    required this.to,
    required this.focused,
    required this.scheme,
    required this.onRangeSelected,
    required this.cardShadow,
  });

  final DateTime from;
  final DateTime to;
  final DateTime focused;
  final ColorScheme scheme;
  final void Function(DateTime? start, DateTime? end, DateTime focused)
  onRangeSelected;
  final List<BoxShadow> cardShadow;

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  late DateTime _focused = widget.focused;

  void _jumpToMonth(DateTime month) {
    setState(() => _focused = month);
  }

  void _useToday() {
    final today = DateTime.now();
    setState(() => _focused = today);
    widget.onRangeSelected(today, today, today);
  }

  Future<void> _pickYear() async {
    const minYear = 2000;
    final today = DateTime.now();
    final maxYear = today.year + 1;
    final currentYear = _focused.year.clamp(minYear, today.year);
    final maxSelectableIndex = today.year - minYear;

    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: widget.scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => YearWheelSheet(
        minYear: minYear,
        maxYear: maxYear,
        initialYear: currentYear,
        maxSelectableIndex: maxSelectableIndex,
      ),
    );

    if (selected == null || !mounted) return;
    final newMonth = DateTime(selected, _focused.month, 1);
    final last = DateTime.now();
    final safe = newMonth.isAfter(last)
        ? DateTime(selected, last.month, 1)
        : newMonth;
    _jumpToMonth(safe);
  }

  Future<void> _pickMonth() async {
    final today = DateTime.now();
    final currentMonth = _focused.month;
    final l10n = context.l10n;
    final monthNames = MonthName.allFull(locale: l10n.localeName);
    final initialIndex = currentMonth - 1;

    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: widget.scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        int selectedIndex = initialIndex;
        return StatefulBuilder(
          builder: (context, setState) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        l10n.dateFilterPickMonth,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(TablerIcons.x, size: 20),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: scheme.outline.withValues(alpha: 0.12),
                ),
                SizedBox(
                  height: 280,
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 44,
                    perspective: 0.003,
                    diameterRatio: 1.2,
                    controller: FixedExtentScrollController(
                      initialItem: initialIndex,
                    ),
                    onSelectedItemChanged: (i) {
                      HapticFeedback.selectionClick();
                      setState(() => selectedIndex = i);
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 12,
                      builder: (context, i) {
                        final m = i + 1;
                        final isSelected = i == selectedIndex;
                        final isFuture =
                            _focused.year == today.year && m > today.month;
                        final isDisabled = isFuture && !isSelected;
                        return Center(
                          child: Opacity(
                            opacity: isDisabled ? 0.35 : 1.0,
                            child: Text(
                              monthNames[i],
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isFuture
                                    ? scheme.onSurface.withValues(alpha: 0.3)
                                    : (isSelected
                                          ? scheme.primary
                                          : scheme.onSurface.withValues(
                                              alpha: 0.5,
                                            )),
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                      ),
                      onPressed:
                          (selectedIndex + 1 > today.month &&
                              _focused.year == today.year)
                          ? null
                          : () => Navigator.of(context).pop(selectedIndex + 1),
                      child: Text(l10n.dateFilterSelectMonth),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || !mounted) return;
    _jumpToMonth(DateTime(_focused.year, selected, 1));
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final safeFocused = _focused.isAfter(today) ? today : _focused;
    final isCurrentMonth =
        _focused.year == today.year && _focused.month == today.month;
    final isToday =
        widget.from.year == today.year &&
        widget.from.month == today.month &&
        widget.from.day == today.day &&
        widget.to.year == today.year &&
        widget.to.month == today.month &&
        widget.to.day == today.day;

    return Container(
      decoration: BoxDecoration(
        color: widget.scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.scheme.outline.withValues(alpha: 0.18),
        ),
        boxShadow: widget.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick nav row: ใช้วันนี้ | เดือนนี้ | month picker | year picker
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: isToday ? null : _useToday,
                  style: TextButton.styleFrom(
                    foregroundColor: widget.scheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 44),
                    tapTargetSize: MaterialTapTargetSize.padded,
                  ),
                  icon: const Icon(TablerIcons.calendarCheck, size: 18),
                  label: Text(
                    context.l10n.dateFilterUseToday,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: isCurrentMonth
                      ? null
                      : () =>
                            _jumpToMonth(DateTime(today.year, today.month, 1)),
                  style: TextButton.styleFrom(
                    foregroundColor: widget.scheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 44),
                    tapTargetSize: MaterialTapTargetSize.padded,
                  ),
                  icon: const Icon(TablerIcons.calendarStar, size: 18),
                  label: Text(
                    context.l10n.dateFilterThisMonth,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: _pickMonth,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _focused.monthShort(locale: context.l10n.localeName),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: widget.scheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          TablerIcons.chevronDown,
                          size: 16,
                          color: widget.scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: _pickYear,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_focused.year}',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: widget.scheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          TablerIcons.chevronDown,
                          size: 16,
                          color: widget.scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: widget.scheme.outline.withValues(alpha: 0.12),
          ),
          TableCalendar(
            locale: context.l10n.localeName,
            firstDay: DateTime(2020),
            lastDay: today,
            focusedDay: safeFocused,
            rangeStartDay: widget.from,
            rangeEndDay: widget.to.isAtSameMomentAs(widget.from)
                ? null
                : widget.to,
            rangeSelectionMode: RangeSelectionMode.toggledOn,
            onRangeSelected: widget.onRangeSelected,
            onCalendarCreated: (controller) {
              // Keep our _focused in sync when user swipes
            },
            onPageChanged: (focused) {
              setState(() => _focused = focused);
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: widget.scheme.onSurface,
              ),
              leftChevronIcon: Icon(
                TablerIcons.chevronLeft,
                size: 22,
                color: widget.scheme.onSurfaceVariant,
              ),
              rightChevronIcon: Icon(
                TablerIcons.chevronRight,
                size: 22,
                color: widget.scheme.onSurfaceVariant,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: widget.scheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              weekendStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: widget.scheme.error.withValues(alpha: 0.6),
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: TextStyle(
                fontSize: 14,
                color: widget.scheme.onSurface,
              ),
              weekendTextStyle: TextStyle(
                fontSize: 14,
                color: widget.scheme.onSurface.withValues(alpha: 0.85),
              ),
              todayTextStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: widget.scheme.primary,
              ),
              todayDecoration: BoxDecoration(
                color: widget.scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              rangeStartTextStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: widget.scheme.onPrimary,
              ),
              rangeStartDecoration: BoxDecoration(
                color: widget.scheme.primary,
                shape: BoxShape.circle,
              ),
              rangeEndTextStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: widget.scheme.onTertiary,
              ),
              rangeEndDecoration: BoxDecoration(
                color: widget.scheme.tertiary,
                shape: BoxShape.circle,
              ),
              rangeHighlightColor: widget.scheme.primaryContainer.withValues(
                alpha: 0.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
