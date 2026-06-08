sealed class ReportFailure {
  const ReportFailure(this.message);
  final String message;
}

class ReportLoadFailure extends ReportFailure {
  const ReportLoadFailure(super.message);
}
