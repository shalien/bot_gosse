import 'package:bot_gosse/src/scheduler.dart';

void main(List<String> arguments) async {
  final Scheduler scheduler = Scheduler();

  await scheduler.start();
}
