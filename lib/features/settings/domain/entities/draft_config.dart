import 'package:equatable/equatable.dart';

class DraftConfig extends Equatable {
  const DraftConfig({this.maxDrafts = 30});

  final int maxDrafts;

  DraftConfig copyWith({int? maxDrafts}) {
    return DraftConfig(maxDrafts: maxDrafts ?? this.maxDrafts);
  }

  @override
  List<Object?> get props => [maxDrafts];
}
