final class Scheduler {
  static Scheduler? _instance;

  Scheduler._internal();

  factory Scheduler() {
    return _instance ??= Scheduler._internal();
  }
}
