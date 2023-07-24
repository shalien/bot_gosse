import 'dart:async';
import 'dart:math';

import 'package:bel_adn/bel_adn.dart';
import 'package:nyxx/nyxx.dart';
import 'package:sha_env/sha_env.dart';

final class DiscordBot {
  static DiscordBot? _instance;

  final String _token = fromEnvironmentString('DISCORD_BOT_TOKEN');

  final Timer _postTimer;
  final Timer _presenceTimer;

  late NyxxGateway _gateway;

  Guild? _magnifiqueCoupleGuild;

  DiscordBot._internal()
      : _postTimer = Timer.periodic(const Duration(hours: 1), _onPostTimer),
        _presenceTimer = Timer.periodic(
            const Duration(hours: 3, minutes: 30), _onPresenceTimer);

  factory DiscordBot() {
    return _instance ??= DiscordBot._internal();
  }

  Future<void> start() async {
    _gateway = await Nyxx.connectGateway(_token, GatewayIntents.all,
        options: GatewayClientOptions(plugins: [
          IgnoreExceptions(),
        ]));

    _magnifiqueCoupleGuild = await _gateway.guilds
        .get(Snowflake(fromEnvironment('DISCORD_GUILD_ID')));
  }

  Future<void> stop() async {
    _postTimer.cancel();
    _presenceTimer.cancel();
    await _gateway.close();
  }

  static Future<void> _onPostTimer(Timer timer) async {
    List<Topic> topics = await Topic.dao.index();

    topics.shuffle();

    List<Topic> subTopics =
        topics.sublist(1, Random.secure().nextInt(topics.length));

    for (Topic topic in subTopics) {
      List<Provider> providers = await topic.providers;

      providers.shuffle();

      List<Provider> subProviders =
          providers.sublist(1, Random.secure().nextInt(providers.length));

      for (Provider provider in subProviders) {}
    }
  }

  static Future<void> _onPresenceTimer(Timer timer) async {}
}
