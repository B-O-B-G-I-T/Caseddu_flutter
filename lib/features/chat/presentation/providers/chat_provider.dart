import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:caseddu/core/utils/p2p/fonctions.dart';
import 'package:caseddu/features/chat/domain/entities/chat_user_entity.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/connection/network_info.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../data/models/chat_message_model.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/usecases/get_chat.dart';
import '../../data/datasources/chat_local_data_source.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/repositories/chat_repository_impl.dart';

class ChatProvider extends ChangeNotifier {
  String myName = '';
  String sender = '';
  List<ChatMessageEntity> chat = [];
  NearbyService? controlerDevice;
  Failure? failure;
  List<Device> devices = [];
  List<Device> connectedDevices = [];
  List<UserEntity> users = [];

  ChatProvider({
    this.failure,
  }) {
    eitherFailureOrInit();
    eitherFailureOrAllConversations();
  }

  Future<void> eitherFailureOrInit() async {
    ChatRepositoryImpl repository = ChatRepositoryImpl(
      remoteDataSource: ChatRemoteDataSourceImpl(),
      localDataSource: ChatLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );
    chat = [];
    final failureOrChat = await GetChat(chatRepository: repository).init();
    if (myName == '') {
      myName = FirebaseAuth.instance.currentUser!.displayName.toString();
    }
    failureOrChat.fold(
      (Failure newFailure) {
        failure = newFailure;
        notifyListeners();
      },
      (NearbyService nearbyService) {
        controlerDevice = nearbyService;
        checkDevices(nearbyService);
        checkReceiveData(nearbyService);
        failure = null;
        notifyListeners();
      },
    );
  }

  //--------------- Reception des connections
  StreamSubscription checkDevices(NearbyService nearbyService) {
    return nearbyService.stateChangedSubscription(callback: (devicesList) {
      for (var element in devicesList) {
        if (Platform.isAndroid) {
          if (element.state == SessionState.connected) {
            nearbyService.stopBrowsingForPeers();
          } else {
            nearbyService.startBrowsingForPeers();
          }
        }
      }

      updateDevices(devicesList);
      updateConnectedDevices(devicesList.where((d) => d.state == SessionState.connected).toList());

      // print(devicesList.map((device) => {'deviceId': device.deviceId, 'deviceName': device.deviceName, 'state': device.state}).toList());
      notifyListeners();
    });
  }

//--------------- Reception des messages
  StreamSubscription checkReceiveData(NearbyService nearbyService) {
    return nearbyService.dataReceivedSubscription(callback: (data) async {
      // Vérifiez si data est une chaîne JSON valide
      try {
        var jsonData = jsonDecode(data['message']);
        ChatMessageModel chatMessageModel = ChatMessageModel.fromJson(json: jsonData);
        String imagesEncode = chatMessageModel.images;
        if (imagesEncode != "") {
          List<String> imageListPaths = await Utils.base64StringToListImage(imagesEncode);
          imagesEncode = imageListPaths.join(',');
        }

        Fluttertoast.showToast(
          msg: '''Sender: ${chatMessageModel.sender} Receiver: ${chatMessageModel.receiver}  Type: ${chatMessageModel.type}
              Timestamp: ${chatMessageModel.timestamp} 
              Message: ${chatMessageModel.message}''',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          //timeInSecForIosWeb: 1,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        await eitherFailureOrEnregistreMessage(
          chatMessageParams: ChatMessageParams(
            id: chatMessageModel.id,
            sender: chatMessageModel.sender,
            receiver: chatMessageModel.receiver,
            message: chatMessageModel.message,
            images: imagesEncode,
            type: chatMessageModel.type,
            sendOrReceived: 'Received',
            timestamp: chatMessageModel.timestamp,
          ),
        );
        // sert à mettre à jour les conversations
        await eitherFailureOrAllConversations();
        notifyListeners();
      } catch (e) {
        print('Erreur lors de la conversion des données JSON : $e');
      }
    });
  }

  void updateDevices(List<Device> devices) {
    this.devices = devices;
    notifyListeners();
  }

  void updateConnectedDevices(List<Device> devices) {
    connectedDevices = devices;
    notifyListeners();
  }

  // Function to connect to a device
  Future<bool> connectToDevice(Device device) async {
    // TODO: Faire une alerte lorsque l'on n'arrive pas a ce connecté
    // TODO: peut etre faire une validation pour l'invite
    switch (device.state) {
      case SessionState.notConnected:
        await controlerDevice?.invitePeer(
          deviceID: device.deviceId,
          deviceName: device.deviceName,
        );
        //log("Want to connect");
        break;
      case SessionState.connected:
        await controlerDevice?.disconnectPeer(deviceID: device.deviceId);
        break;
      case SessionState.connecting:
        break;
      case SessionState.tooFar:
        break;
    }

    notifyListeners();
    return true;
  }

  Future<void> eitherFailureOrEnvoieDeMessage({required ChatMessageParams chatMessageParams}) async {
    chatMessageParams.sender = myName;

    chatMessageParams.nearbyService = controlerDevice;
    //Global.cache[chatMessageParams.id] = chatMessageParams;
    // insertIntoMessageTable(chatMessageParams);

    ChatRepositoryImpl repository = ChatRepositoryImpl(
      remoteDataSource: ChatRemoteDataSourceImpl(),
      localDataSource: ChatLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );
//print(chatMessageParams.images);

    final failureOrChat = await GetChat(chatRepository: repository).envoieMessage(
      chatMessageParams: chatMessageParams,
    );

    failureOrChat.fold(
      (Failure newFailure) {
        //chat = null;
        failure = newFailure;
        notifyListeners();
      },
      (ChatMessageEntity chatMessageModel) {
        chat.add(chatMessageModel);
        failure = null;
        notifyListeners();
      },
    );
  }

  Future<void> eitherFailureOrEnregistreMessage({required ChatMessageParams chatMessageParams}) async {
    ChatRepositoryImpl repository = ChatRepositoryImpl(
      remoteDataSource: ChatRemoteDataSourceImpl(),
      localDataSource: ChatLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );
    chatMessageParams.images = chatMessageParams.images;

    final failureOrChat = await GetChat(chatRepository: repository).enregistreMessage(
      chatMessageParams: chatMessageParams,
    );

    failureOrChat.fold(
      (Failure newFailure) {
        //chat = null;
        failure = newFailure;
        notifyListeners();
      },
      (ChatMessageEntity chatMessageModel) {
        if (chatMessageModel.sender == sender) {
          chat.add(chatMessageModel);
        }
        failure = null;
        notifyListeners();
      },
    );
  }

  Future<void> eitherFailureOrConversation(String senderName, String receiverName) async {
    //chatMessageParams.sender = Global.myName;
    //Global.cache[chatMessageParams.id] = chatMessageParams;
    // insertIntoMessageTable(chatMessageParams);

    ChatRepositoryImpl repository = ChatRepositoryImpl(
      remoteDataSource: ChatRemoteDataSourceImpl(),
      localDataSource: ChatLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );
    chat = [];
    final failureOrChat = await GetChat(chatRepository: repository).getConversation(senderName, receiverName);

    failureOrChat.fold(
      (Failure newFailure) {
        //chat = null;
        failure = newFailure;
        notifyListeners();
      },
      (List<ChatMessageEntity> messages) {
        chat = messages;
        failure = null;
        notifyListeners();
      },
    );
  }

  Future<void> eitherFailureOrAllConversations() async {
    //chatMessageParams.sender = Global.myName;
    //Global.cache[chatMessageParams.id] = chatMessageParams;
    // insertIntoMessageTable(chatMessageParams);

    ChatRepositoryImpl repository = ChatRepositoryImpl(
      remoteDataSource: ChatRemoteDataSourceImpl(),
      localDataSource: ChatLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );
    // chat = [];
    final failureOrChat = await GetChat(chatRepository: repository).getAllConversations();

    failureOrChat.fold(
      (Failure newFailure) {
        //chat = null;
        failure = newFailure;
        notifyListeners();
      },
      (List<UserEntity> utilisateur) {
        users = utilisateur;
        failure = null;
        notifyListeners();
      },
    );
  }

  Future<void> deleteConversation(UserEntity userEntity) async {
    //chatMessageParams.sender = Global.myName;
    //Global.cache[chatMessageParams.id] = chatMessageParams;
    // insertIntoMessageTable(chatMessageParams);

    ChatRepositoryImpl repository = ChatRepositoryImpl(
      remoteDataSource: ChatRemoteDataSourceImpl(),
      localDataSource: ChatLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    final failureOrChat = await GetChat(chatRepository: repository).deleteConversation(userEntity);

    failureOrChat.fold(
      (Failure newFailure) {
        //chat = null;
        failure = newFailure;
        notifyListeners();
      },
      (void messages) {
        users.remove(userEntity);
        failure = null;
        notifyListeners();
      },
    );
  }
}
