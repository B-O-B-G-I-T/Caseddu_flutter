import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:caseddu/core/utils/p2p/fonctions.dart';
import 'package:caseddu/features/chat/domain/entities/chat_user_entity.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
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
      notifyListeners();
    });
  }

//--------------- Reception des messages
  StreamSubscription checkReceiveData(NearbyService nearbyService) {
    return nearbyService.dataReceivedSubscription(callback: (data) async {
      // Vérifiez si data est une chaîne JSON valide
      try {
        if (data['message'].startsWith("ACK ")) {
          // Enregistre le message dans la base de données
          final String messageId = data['message'].substring(4);
          final ChatMessageEntity messageACK = chat.firstWhere(
            (element) => element.id == messageId,
          );
          messageACK.ack = 1;

          await eitherFailureOrEnregistreMessage(
            chatMessageParams: messageACK.toParamsAKC(),
          );
          return;
        }
// passse les data en JSON
        ChatMessageModel chatMessageModel = await manageDataReceivedToJson(data);

        if (chatMessageModel.type == 'DELETE') {
          // Enregistre le message supprimé dans la base de données
          await eitherFailureOrDeleteMessage(chatMessageEntity: chatMessageModel);

          await eitherFailureOrEnregistreMessage(chatMessageParams: chatMessageModel.toChatMessageParams());
        } else {
// enregistre le message dans la base de données et envoie ack
          await receiveMessage(chatMessageModel: chatMessageModel, nearbyService: nearbyService);
        }
        notifyListeners();
      } catch (e) {
        log('Erreur lors de la conversion des données JSON : $e', name: 'ChatProvider');
      }
    });
  }

  Future<ChatMessageModel> receiveMessage({required ChatMessageModel chatMessageModel, required NearbyService nearbyService}) async {
    //chatMessageModel.ACK = true;
    Fluttertoast.showToast(
      msg: '''Sender: ${chatMessageModel.sender} Receiver: ${chatMessageModel.receiver}  Type: ${chatMessageModel.type}
            Timestamp: ${DateFormat('HH:mm:ss').format(chatMessageModel.timestamp)} 
          Message: ${chatMessageModel.message}''',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      //timeInSecForIosWeb: 1,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    nearbyService.sendMessage(chatMessageModel.sender, "ACK ${chatMessageModel.id}");
    await eitherFailureOrEnregistreMessage(
      chatMessageParams: chatMessageModel.toChatMessageParams(),
    );
    return chatMessageModel;
  }

  Future<ChatMessageModel> manageDataReceivedToJson(data) async {
    var jsonData = jsonDecode(data['message']);

    ChatMessageModel chatMessageModel = ChatMessageModel.fromJson(json: jsonData);
    String imagesEncode = chatMessageModel.images;
    if (imagesEncode != "") {
      List<String> imageListPaths = await Utils.base64StringToListImage(imagesEncode);
      imagesEncode = imageListPaths.join(',');
    }
    chatMessageModel.images = imagesEncode;
    return chatMessageModel;
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
        devices = devices.map((d) {
          if (d.deviceId == device.deviceId) {
            d.state = SessionState.connecting;
          }
          return d;
        }).toList();
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

  Future<void> eitherFailureOrDeleteMessage({required ChatMessageEntity chatMessageEntity}) async {
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

    final failureOrChat = await GetChat(chatRepository: repository).deleteMessage(chatMessageEntity);

    failureOrChat.fold(
      (Failure newFailure) {
        //chat = null;
        failure = newFailure;
        notifyListeners();
      },
      (void messages) {
        chat.removeWhere((element) => element.id == chatMessageEntity.id);
        failure = null;
        notifyListeners();
      },
    );
  }

  Future<void> eitherFailureOrDeleteConversation({required UserEntity userEntity}) async {
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
