import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/global/payload.dart';

import '../database/databasehelper.dart';
import '../modeles/messages_model.dart';

import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

class Global extends ChangeNotifier {
  static String myName = '';
  List<Device> devices = [];
  List<Device> connectedDevices = [];
  static NearbyService? nearbyService;
  static Map<String, dynamic> cache = {};
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();
  Map<String, Map<String, Msg>> conversations = {};

  static StreamSubscription? deviceSubscription;
  static StreamSubscription? receivedDataSubscription;

  void sentToConversations(Msg msg, String converser,
      {bool addToTable = true, bool isImage = false}) {
    if (conversations[converser] == null) {
      conversations[converser] = {};
    }

    conversations[converser]![msg.id] = msg;

    if (addToTable) {
      insertIntoConversationsTable(msg, converser);
    }
    var dernierEnCache = cache.entries.last;

    // TODO: defini un type pour data
    // ignore: prefer_typing_uninitialized_variables
    var data;
    if (dernierEnCache.value.runtimeType == Payload) {
      Payload payload = dernierEnCache.value;
      if (isImage) {
        data = {
          "sender": payload.sender,
          "receiver": payload.receiver,
          "message": payload.message,
          "id": msg.id,
          "Timestamp": payload.timestamp,
          "type": "Image"
        };
      } else {
        data = {
          "sender": payload.sender,
          "receiver": payload.receiver,
          "message": payload.message,
          "id": msg.id,
          "Timestamp": payload.timestamp,
          "type": "Payload"
        };
      }
      var toSend = jsonEncode(data);
      Global.nearbyService!.sendMessage(converser, toSend); //make this async
    } else if (dernierEnCache.runtimeType == Ack) {
      var data = {"id": msg.id, "type": "Ack"};
      Global.nearbyService!.sendMessage(converser, jsonEncode(data));
    }
    // String toSend = jsonEncode(msg);
    // Global.nearbyService!.sendMessage(converser, toSend);
    notifyListeners();
    // First push the new message for one time when new message is sent

    //broadcast(scaffoldKey.currentContext!);
  }

  void updateDevices(List<Device> devices) {
    this.devices = devices;
    notifyListeners();
  }

  void updateConnectedDevices(List<Device> devices) {
    connectedDevices = devices;
    notifyListeners();
  }

  void receivedToConversations(dynamic decodedMessage, BuildContext context) {
    if (conversations[decodedMessage['sender']] == null) {
      conversations[decodedMessage['sender']] = <String, Msg>{};
    }
    if (conversations[decodedMessage['sender']] != null &&
        !(conversations[decodedMessage['sender']]!
            .containsKey(decodedMessage['id']))) {
      conversations[decodedMessage['sender']]![decodedMessage["id"]] = Msg(
        decodedMessage['message'],
        "received",
        decodedMessage['Timestamp'],
        decodedMessage["id"],
      );
      insertIntoConversationsTable(
          Msg(decodedMessage['message'], "received",
              decodedMessage['Timestamp'], decodedMessage["id"]),
          decodedMessage['sender']);
    }

    notifyListeners();
  }

  void supprimerConversationDe(String laPersonne) {
    conversations.remove(laPersonne);
  }
}
