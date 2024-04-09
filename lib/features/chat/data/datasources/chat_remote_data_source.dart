import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import '../../../../../core/params/params.dart';
import '../models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  Future<NearbyService> init();
  Future<ChatMessageModel> sentToConversations({required ChatMessageParams chatMessageParams});
  
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  static String myName = 'bob';
  // NearbyService? nearbyService;

  // StreamSubscription? deviceSubscription;
  // StreamSubscription? receivedDataSubscription;

  ChatRemoteDataSourceImpl() {
    // myName = FirebaseAuth.instance.currentUser!.displayName.toString();
    // initiateNearbyService();
    // checkDevices();
  }

  @override
  Future<NearbyService> init() async {
    myName = FirebaseAuth.instance.currentUser!.displayName.toString();

    final NearbyService nearbyService = await initiateNearbyService(myName);

    return nearbyService;
  }

// Initiating NearbyService to start the connection
  Future<NearbyService> initiateNearbyService(String myName) async {
    NearbyService nearbyService = NearbyService();
    await nearbyService.init(
      serviceType: 'mpconn',
      deviceName: myName,
      strategy: Strategy.P2P_CLUSTER,
      callback: (isRunning) async {
        // if (isRunning) {
        //   await startAdvertising(nearbyService);
        //   await startBrowsing(nearbyService);
        // }
      },
    );
    await startAdvertising(nearbyService);
    await startBrowsing(nearbyService);

    return nearbyService;
  }

// Start discovering devices
  Future<void> startBrowsing(NearbyService nearbyService) async {
    await nearbyService.stopBrowsingForPeers();
    await nearbyService.startBrowsingForPeers();
  }

  Future<void> startAdvertising(NearbyService nearbyService) async {
    await nearbyService.stopAdvertisingPeer();
    await nearbyService.startAdvertisingPeer();
  }

//--------------- Envoie des messages
  @override
  Future<ChatMessageModel> sentToConversations({required ChatMessageParams chatMessageParams}) async {
    ChatMessageModel chatMessageModel = chatMessageParams.toModel();
    
    final data = jsonEncode(chatMessageModel.toJson());
    chatMessageParams.nearbyService!.sendMessage(chatMessageParams.receiver, data);

    return chatMessageModel;
  }
}
