import 'dart:math';
import 'dart:typed_data';

import 'package:bel_adn/bel_adn.dart';
import 'package:nyxx/nyxx.dart';

Future<Set<AttachmentBuilder>> getAttachmentsFromTopic(Topic topic) async {
  Set<AttachmentBuilder> attachments = {};

  Set<Provider> providers = await topic.providers;

  List<Provider> shuffledProviders = providers.toList()..shuffle();

  List<Provider> subProviders =
      shuffledProviders.sublist(1, Random.secure().nextInt(providers.length));

  for (Provider provider in subProviders) {
    Set<Source> sources = await provider.sources;

    List<Source> shuffledSources = sources.toList()..shuffle();

    List<Source> subSources = shuffledSources.take(10).toList();

    for (Source source in subSources) {
      Set<Media> medias = await source.medias;

      for (Media media in medias) {
        Destination? destination = await media.destination;

        if (destination != null) {
          Uint8List? data = await getMedia(media);

          if (data != null) {
            AttachmentBuilder attachmentBuilder =
                AttachmentBuilder(data: data, fileName: destination.filename);

            attachments.add(attachmentBuilder);
          }
        }
      }
    }
  }
  return attachments;
}

Future<Uint8List?> getMedia(Media media) async {
  Uri uri = media.link;

  switch (uri.host) {
    case 'redgifs.com':
    case 'imgur.com':
    case 'i.imgur.com':
      return null;
  }

  Response response;

  try {
    response = await get(uri);
  } catch (e) {
    return null;
  }

  if (response.statusCode == 200 &&
      response.bodyBytes.isNotEmpty &&
      response.bodyBytes.length < 8000000) {
    return response.bodyBytes;
  }
  return null;
}
