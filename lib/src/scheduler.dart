import 'dart:isolate';

import 'discord/discord_isolate.dart';

final class Scheduler {
  static Scheduler? _instance;

  Scheduler._internal();

  ReceivePort discordReceiverPort = ReceivePort();

  ReceivePort webReceiverPort = ReceivePort();

  late Isolate discordIsolate;

  late Isolate webIsolate;

  factory Scheduler() {
    return _instance ??= Scheduler._internal();
  }

  Future<void> start() async {
    discordIsolate =
        await Isolate.spawn(discordIsolateMain, discordReceiverPort.sendPort);
    // Isolate.spawn(_webIsolate, webReceiverPort.sendPort);
  }
}
