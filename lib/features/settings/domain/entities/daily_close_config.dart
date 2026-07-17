import 'package:equatable/equatable.dart';

const Object _unset = Object();

class DailyCloseConfig extends Equatable {
  const DailyCloseConfig({this.dailyCloseLock = false, this.lastClosedDate});

  final bool dailyCloseLock;
  final String? lastClosedDate;

  /// Pass [lastClosedDate] as `null` to clear; omit to keep current value.
  DailyCloseConfig copyWith({
    bool? dailyCloseLock,
    Object? lastClosedDate = _unset,
  }) {
    return DailyCloseConfig(
      dailyCloseLock: dailyCloseLock ?? this.dailyCloseLock,
      lastClosedDate: identical(lastClosedDate, _unset)
          ? this.lastClosedDate
          : lastClosedDate as String?,
    );
  }

  @override
  List<Object?> get props => [dailyCloseLock, lastClosedDate];
}
