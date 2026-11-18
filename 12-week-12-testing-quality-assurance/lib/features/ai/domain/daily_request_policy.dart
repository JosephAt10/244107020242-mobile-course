class DailyRequestPolicy {
  const DailyRequestPolicy({this.limit = 20});

  final int limit;

  bool allows({required int requestsToday}) => requestsToday < limit;
}
