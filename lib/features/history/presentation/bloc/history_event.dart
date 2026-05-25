import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object?> get props => [];
}

class HistorySubscribed extends HistoryEvent {
  const HistorySubscribed();
}

class HistoryDateRangeChanged extends HistoryEvent {
  const HistoryDateRangeChanged({this.from, this.to});
  final DateTime? from;
  final DateTime? to;

  @override
  List<Object?> get props => [from, to];
}

