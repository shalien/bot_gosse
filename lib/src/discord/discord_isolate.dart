import 'dart:isolate';

import 'package:bot_gosse/src/discord/discord_bot.dart';
import 'package:sha_env/sha_env.dart';

SendPort? sendPort;
ReceivePort receivePort = ReceivePort();

DiscordBot discordBot = DiscordBot();

void discordIsolateMain(data) async {
  await load();

  sendPort = data;

  await discordBot.start();
}
