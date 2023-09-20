import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/global/payload.dart';
import '../database/databasehelper.dart';
import '../modeles/messages_model.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

// TODO peut etre cool d'utilisé le path_prvider pour le cache
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
      {bool addToTable = true, String isImage = ''}) {
    if (conversations[converser] == null) {
      conversations[converser] = {};
    }
    var dernierEnCache = cache.entries.last;

    // ignore: prefer_typing_uninitialized_variables
    Map<String, String> data;
    if (dernierEnCache.value.runtimeType == Payload) {
      if (isImage.isNotEmpty) {
// mise en forme des données
        data = {
          "sender": myName,
          "receiver": converser,
          "message": msg.message,
          "id": msg.id,
          "Timestamp": msg.timestamp,
          "type": "Image"
        };

// ajout en cache dans le global
        Msg msglocal = Msg(
            isImage, msg.sendOrReceived, msg.timestamp, msg.typeMsg, msg.id);

        conversations[converser]![msg.id] = msglocal;
        if (addToTable) {
          insertIntoConversationsTable(msglocal, converser);
        }
      } else {
        data = {
          "sender": myName,
          "receiver": converser,
          "message": msg.message,
          "id": msg.id,
          "Timestamp": msg.timestamp,
          "type": "Payload"
        };
        conversations[converser]![msg.id] = msg;
        if (addToTable) {
          insertIntoConversationsTable(msg, converser);
        }
      }
      String toSend = jsonEncode(data);
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

  void receivedToConversations(Payload decodedMessage, BuildContext context) {
    if (conversations[decodedMessage.sender] == null) {
      conversations[decodedMessage.sender] = <String, Msg>{};
    }
    if (conversations[decodedMessage.sender] != null &&
        !(conversations[decodedMessage.sender]!
            .containsKey(decodedMessage.id))) {
      conversations[decodedMessage.sender]![decodedMessage.id] = Msg(
        decodedMessage.message,
        "received",
        decodedMessage.timestamp,
        decodedMessage.type,
        decodedMessage.id,
      );
      insertIntoConversationsTable(
          Msg(
            decodedMessage.message,
            "received",
            decodedMessage.timestamp,
            decodedMessage.type,
            decodedMessage.id,
          ),
          decodedMessage.sender);
    }

    notifyListeners();
  }

  void supprimerConversationDe(String laPersonne) {
    conversations.remove(laPersonne);
  }
}
