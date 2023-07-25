import 'dart:async';
import 'dart:math';

import 'package:bel_adn/bel_adn.dart';
import 'package:nyxx/nyxx.dart';
import 'package:sha_env/sha_env.dart';

import 'discord_utils.dart';

final class DiscordBot {
  static DiscordBot? _instance;

  final String _token = fromEnvironmentString('DISCORD_BOT_TOKEN');

  Timer? _postTimer;
  Timer? _presenceTimer;

  late NyxxGateway _gateway;

  Guild? _magnifiqueCoupleGuild;

  DiscordBot._internal();

  factory DiscordBot() {
    return _instance ??= DiscordBot._internal();
  }

  Future<void> start() async {
    _gateway = await Nyxx.connectGateway(
        _token, GatewayIntents.allUnprivileged | GatewayIntents.messageContent,
        options: GatewayClientOptions(plugins: [
          IgnoreExceptions(),
          Logging(),
        ]));

    _magnifiqueCoupleGuild = await _gateway.guilds
        .get(Snowflake(fromEnvironment('DISCORD_GUILD_ID')));

    if (_magnifiqueCoupleGuild == null) {
      throw Exception('Guild not found');
    }

    _postTimer = Timer.periodic(const Duration(hours: 1), _onPostTimer);
    _presenceTimer =
        Timer.periodic(const Duration(hours: 3, minutes: 30), _onPresenceTimer);

    _gateway.onMessageCreate.listen((event) async {
      if (event.message.author.id == Snowflake(152792860960227328)) {
        List<String> args = event.message.content.toLowerCase().split(' ');

        if (args.first.toLowerCase().trim() == 'push') {
          if (args.length == 2) {
            Set<Topic> topics = await TopicDataAccessObject().index();

            Topic topic =
                topics.firstWhere((element) => element.name == args[1]);

            Set<AttachmentBuilder> attachments =
                await getAttachmentsFromTopic(topic);

            if (attachments.isNotEmpty) {
              GuildTextChannel? channel = await getChannel(topic.name);

              if (channel != null) {
                List<AttachmentBuilder> attachmentsList =
                    attachments.take(10).toList();

                await channel
                    .sendMessage(MessageBuilder(attachments: attachmentsList));
              }
            }
          }
        }
      }
    });
  }

  Future<void> stop() async {
    _postTimer?.cancel();
    _presenceTimer?.cancel();
    await _gateway.close();
  }

  Future<void> _onPostTimer(Timer timer) async {
    Set<Topic> topics = await TopicDataAccessObject().index();

    List<Topic> shuffledTopics = topics.toList()..shuffle();

    List<Topic> subTopics =
        shuffledTopics.sublist(1, Random.secure().nextInt(topics.length));

    for (Topic topic in subTopics) {
      Set<AttachmentBuilder> attachments = await getAttachmentsFromTopic(topic);

      Set<AttachmentBuilder> limitedAttachments = attachments.take(10).toSet();

      if (limitedAttachments.isNotEmpty) {
        GuildTextChannel? channel = await getChannel(topic.name);

        if (channel != null) {
          await channel.sendMessage(
              MessageBuilder(attachments: limitedAttachments.toList()));
        }
      }
    }
  }

  Future<void> _onPresenceTimer(Timer timer) async {}

  Future<GuildTextChannel?> getChannel(String name) async {
    List<Channel> channels = await _magnifiqueCoupleGuild!.fetchChannels();

    for (Channel channel in channels) {
      if (channel is GuildTextChannel) {
        if (channel.name.toLowerCase() == name.toLowerCase()) {
          return channel;
        }
      }
    }
    return null;
  }
}
