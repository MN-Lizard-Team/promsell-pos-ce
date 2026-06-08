sealed class HistoryFailure {
  const HistoryFailure(this.message);
  final String message;
}

class HistoryLoadFailure extends HistoryFailure {
  const HistoryLoadFailure(super.message);
}
