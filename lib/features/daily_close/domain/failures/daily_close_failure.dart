sealed class DailyCloseFailure {
  const DailyCloseFailure(this.message);
  final String message;
}

class DailyCloseLoadFailure extends DailyCloseFailure {
  const DailyCloseLoadFailure(super.message);
}

class DailyCloseSaveFailure extends DailyCloseFailure {
  const DailyCloseSaveFailure(super.message);
}

class DailyCloseReopenFailure extends DailyCloseFailure {
  const DailyCloseReopenFailure(super.message);
}
