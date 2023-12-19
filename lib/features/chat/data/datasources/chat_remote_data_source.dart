import 'dart:async';
import 'dart:convert';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import '../../../../../core/params/params.dart';

abstract class ChatRemoteDataSource {
  Future<void> sentToConversations({required ChatMessageParams chatMessageParams});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {

  static String myName = '';
  List<Device> devices = [Device('deviceId1', 'userTest1', 0), Device('deviceId2', 'userTest2', 2)];
  List<Device> connectedDevices = [Device('deviceId2', 'userTest2', 2)];
  static NearbyService? nearbyService;

  static StreamSubscription? deviceSubscription;
  static StreamSubscription? receivedDataSubscription;

  ChatRemoteDataSourceImpl();

  @override
  Future<void> sentToConversations({required ChatMessageParams chatMessageParams}) async {

    Map<String, String> data;
    if (chatMessageParams.type == 'Image') {
      // mise en forme des données
      data = {"sender": myName, "receiver": chatMessageParams.sender, "message": chatMessageParams.message, "id": chatMessageParams.id, "Timestamp": chatMessageParams.timestamp, "type": "Image"};
    } else {
      data = {"sender": myName, "receiver": chatMessageParams.sender, "message": chatMessageParams.message, "id": chatMessageParams.id, "Timestamp": chatMessageParams.timestamp, "type": "Payload"};
    }
    String toSend = jsonEncode(data);
    nearbyService!.sendMessage(chatMessageParams.sender, toSend); //make this async
  }
}
