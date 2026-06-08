import 'package:equatable/equatable.dart';

class DailyCloseConfig extends Equatable {
  const DailyCloseConfig({this.dailyCloseLock = false, this.lastClosedDate});

  final bool dailyCloseLock;
  final String? lastClosedDate;

  DailyCloseConfig copyWith({bool? dailyCloseLock, String? lastClosedDate}) {
    return DailyCloseConfig(
      dailyCloseLock: dailyCloseLock ?? this.dailyCloseLock,
      lastClosedDate: lastClosedDate ?? this.lastClosedDate,
    );
  }

  @override
  List<Object?> get props => [dailyCloseLock, lastClosedDate];
}
