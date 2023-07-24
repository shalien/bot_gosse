import 'dart:isolate';

import 'package:sha_env/sha_env.dart';

SendPort? sendPort;
ReceivePort receivePort = ReceivePort();

void main(data) async {
  await load();

  sendPort = data['sendPort'];
}
