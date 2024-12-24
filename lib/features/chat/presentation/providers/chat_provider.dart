// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:caseddu/core/utils/p2p/fonctions.dart';
import 'package:caseddu/features/chat/data/models/chat_user_model.dart';
import 'package:caseddu/features/chat/domain/entities/chat_user_entity.dart';
import 'package:caseddu/features/parameter/presentation/providers/parameter_provider.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/connection/network_info.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../../../core/utils/images/utils_image.dart';
import '../../data/models/chat_message_model.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/usecases/get_chat.dart';
import '../../data/datasources/chat_local_data_source.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/repositories/chat_repository_impl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatProvider extends ChangeNotifier {
  String myName = '';
  String sender = '';
  List<ChatMessageEntity> chat = [];
  NearbyService? controlerDevice;
  Failure? failure;
  List<Device> devices = [];
  List<Device> connectedDevices = [];
  List<UserEntity> users = [];

  // gestion des images du data picker
  List<AssetEntity> images = [];
  List<AssetEntity> selectedImages = [];

  bool _isLoadingOldMessages = false;
  bool hasMoreMessages = true;
  bool get isLoadingOldMessages => _isLoadingOldMessages;

  ParameterProvider? parameterProvider;

  // Stream pour les nouveaux messages reçus
  final StreamController<void> _newMessageController = StreamController<void>.broadcast();

  Stream<void> get newMessageStream => _newMessageController.stream;

  // Stream pour les initialisations des invitations
  final StreamController<void> _invitationController = StreamController<void>.broadcast();

  Stream<void> get invitationController => _invitationController.stream;

  ChatProvider({
    required ParameterProvider parameterProvider,
    this.failure,
  }) {
    eitherFailureOrInit(parameterProvider);
    eitherFailureOrAllConversations();
  }

  Future<void> eitherFailureOrInit(ParameterProvider parameterProvider) async {
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
    // await parameterProvider.init();
    final failureOrChat = await GetChat(chatRepository: repository).init(parameterProvider);
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

        checkDevices(controlerDevice!);
        checkReceiveData(controlerDevice!);

        this.parameterProvider = parameterProvider;
        failure = null;
        // Diffuse le nouveau message via le Stream
        _invitationController.sink.add(null);
        notifyListeners();
      },
    );
  }

  void disabledNearbyService() {
    controlerDevice = null;
  }

  Future<void> loadImageChat(BuildContext context) async {
    images = await loadImages(context);
    notifyListeners();
  }

  void setupInvitationHandler(BuildContext context) {
    controlerDevice?.registerInvitationHandler((peerName) async {
      try {
        debugPrint("Invitation received from $peerName");
        // if (connectedDevices.any((element) => element.deviceName == peerName)) {
        //   notifyListeners();
        //   return false;
        // }

        final result = await showDialog<bool>(
          context: context,
          builder: (context) {
            bool isProcessing = false;
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text(AppLocalizations.of(context)!.invitation_received),
                  content: Text(AppLocalizations.of(context)!.wants_to_connect_with_you(peerName)),
                  actionsAlignment: MainAxisAlignment.spaceEvenly,
                  actions: [
                    OutlinedButton(
                      onPressed: isProcessing
                          ? null
                          : () async {
                              setState(() => isProcessing = true);
                              notifyListeners();
                              Navigator.of(context).pop(false);
                            },
                      child: Text(AppLocalizations.of(context)!.decline),
                    ),
                    ElevatedButton(
                      onPressed: isProcessing
                          ? null
                          : () async {
                              setState(() => isProcessing = true);
                              notifyListeners();
                              Navigator.of(context).pop(true);
                            },
                      child: isProcessing ? const CircularProgressIndicator(color: Colors.white) : Text(AppLocalizations.of(context)!.accept),
                    ),
                  ],
                );
              },
            );
          },
        );
        notifyListeners();
        return result ?? false; // Retourne false si aucune action n'est prise
      } catch (e) {
        notifyListeners();
        debugPrint("Error during invitation handling: $e");
        return false;
      }
    });
  }

//--------------- Reception des connections
  StreamSubscription checkDevices(NearbyService nearbyService) {
    return nearbyService.stateChangedSubscription(callback: (devicesList) async {
      for (var element in devicesList) {
        if (Platform.isAndroid) {
          if (element.state == SessionState.connected) {
            nearbyService.stopBrowsingForPeers();
          } else {
            nearbyService.startBrowsingForPeers();
          }
        }

        if (element.state == SessionState.connecting) {
          log("Connecting");
          // TODO: on force le passage à connected il faudrait trouver une meilleure solution
          devicesList = devicesList.map((d) {
            if (d.deviceId == element.deviceId) {
              d.state = SessionState.connected;
            }
            return d;
          }).toList();
        }
        // envoie de l'image de profile lors de la connection si elle existe
        if (element.state == SessionState.connected) {
          // Ce code gère l'assignation ou la mise à jour des informations d'un utilisateur dans une liste d'utilisateurs existants.
          // Si une photo est associée à l'utilisateur, elle est encodée et comparée à l'image précédente pour décider d'envoyer ou non une mise à jour.
          // Si l'utilisateur n'existe pas dans la liste, il est ajouté avec ses paramètres.
          //final stopwatch = Stopwatch()..start(); // Démarrer le chronomètre
          final existingUser = users.firstWhere(
            // Recherche de l'utilisateur correspondant dans la liste existante par nom.
            (user) => user.name == element.deviceName,
            // Si aucun utilisateur correspondant n'est trouvé, on retourne un utilisateur par défaut.
            orElse: () => UserModel(id: '', name: ''),
          );
          final String? path = parameterProvider?.parameter.pathImageProfile; // Récupération du chemin de l'image associée, si disponible.

          String? myLastStartEncodeImage; // Variable pour stocker l'image encodée (si elle existe).

          if (path != null) {
            // Compression de l'image avant encodage
            final XFile? compressedImage = await Utils.compressImage(File(path));
            if (compressedImage != null) {
              // Si un chemin pour l'image est fourni, on l'encode.
              final String imagesEncode = await Utils.convertFilePathToString(compressedImage.path); // Conversion du fichier d'image en chaîne.
              myLastStartEncodeImage = Utils.imagesEncode(imagesEncode); // Encodage final de l'image.

              if (existingUser.myLastStartEncodeImage != myLastStartEncodeImage) {
                // Si l'image encodée ne correspond pas à celle enregistrée pour cet utilisateur.
                nearbyService.sendMessage(element.deviceId, "PROFILE IMAGE $imagesEncode"); // Envoi de l'image encodée via le service.

                final userParams = UserParams(
                    // Création des paramètres de l'utilisateur (ID, nom et image encodée si disponible).
                    id: element.deviceId,
                    name: element.deviceName,
                    myLastStartEncodeImage: myLastStartEncodeImage,
                    pathImageProfile: existingUser.pathImageProfile);

                // Si l'utilisateur n'existe pas dans la liste (ID vide), on l'ajoute.
                await eitherFailureOrSetUser(userParams: userParams); // Appel pour sauvegarder ou mettre à jour l'utilisateur.
                // stopwatch.stop(); // Arrêter le chronomètre

                // log("L'envoir a pris : ${stopwatch.elapsedMilliseconds} ms");
                return;
              }
            } else {
              print("Failed to compress image.");
            }
          } else {
            // Si aucun chemin d'image n'est fourni, aucune image encodée n'est associée.
            myLastStartEncodeImage = existingUser.myLastStartEncodeImage;
          }

          if (existingUser.id.isEmpty) {
            final userParams = UserParams(
              // Création des paramètres de l'utilisateur (ID, nom et image encodée si disponible).
              id: element.deviceId,
              name: element.deviceName,
              myLastStartEncodeImage: myLastStartEncodeImage,
            );

            // Si l'utilisateur n'existe pas dans la liste (ID vide), on l'ajoute.
            await eitherFailureOrSetUser(userParams: userParams); // Appel pour sauvegarder ou mettre à jour l'utilisateur.
          }
          // stopwatch.stop(); // Arrêter le chronomètre

          // log('La fonction a pris : ${stopwatch.elapsedMilliseconds} ms');
        }
      }

      updateDevices(devicesList);
      updateConnectedDevices(devicesList.where((d) => d.state == SessionState.connected).toList());
      notifyListeners();
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

  Future<void> eitherFailureOrSetUser({required UserParams userParams}) async {
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

    final failureOrChat = await GetChat(chatRepository: repository).setUser(
      userParams: userParams,
    );

    failureOrChat.fold(
      (Failure newFailure) {
        //chat = null;
        failure = newFailure;
        notifyListeners();
      },
      (UserEntity user) {
        failure = null;
        final index = users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          users[index] = user;
        } else {
          users.add(user);
        }
        notifyListeners();
      },
    );
  }

  Future<void> eitherFailureOrSaveSendedImageProfile({required UserParams userParams}) async {
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

    final failureOrChat = await GetChat(chatRepository: repository).saveSendedImageProfile(
      userParams: userParams,
    );

    failureOrChat.fold(
      (Failure newFailure) {
        //chat = null;
        failure = newFailure;
        notifyListeners();
      },
      (UserEntity user) {
        failure = null;
        final index = users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          users[index] = user;
        } else {
          users.add(user);
        }
        notifyListeners();
      },
    );
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

        if (data['message'].startsWith("PROFILE IMAGE ")) {
          if (data['message'].substring(14).isNotEmpty) {
            final dataMessage = data['message'].substring(14);

            final UserParams userParams = UserParams(
              id: data["senderDeviceId"],
              name: data["senderDeviceId"],
              pathImageProfile: dataMessage,
            );
            //debugPrint("statement $userParams");

            await eitherFailureOrSaveSendedImageProfile(userParams: userParams);
          }
          notifyListeners();
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
        // Diffuse le nouveau message via le Stream
        _newMessageController.sink.add(null);
        //notifyListeners();
      } catch (e) {
        log('Erreur lors de la conversion des données JSON : $e', name: 'ChatProvider');
      }
    });
  }

  Future<ChatMessageModel> receiveMessage({required ChatMessageModel chatMessageModel, required NearbyService nearbyService}) async {
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

  // Function to connect to a device
  Future<bool> connectToDevice(Device device, {String force = 'no-force'}) async {
    // TODO: Faire une alerte lorsque l'on n'arrive pas a ce connecté
    switch (device.state) {
      case SessionState.notConnected:

        await controlerDevice?.invitePeer(
          deviceID: device.deviceId,
          deviceName: device.deviceName,
          force: force,
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
        await controlerDevice?.disconnectPeer(deviceID: device.deviceId);
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

  Future<void> eitherFailureOrConversation(String senderName, String receiverName, {DateTime? beforeDate, int limit = 20}) async {
    ChatRepositoryImpl repository = ChatRepositoryImpl(
      remoteDataSource: ChatRemoteDataSourceImpl(),
      localDataSource: ChatLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );
    if (_isLoadingOldMessages || !hasMoreMessages) return;

    _isLoadingOldMessages = true;
    notifyListeners();
    //chat = [];
    final failureOrChat = await GetChat(chatRepository: repository).getConversation(senderName, receiverName, beforeDate: beforeDate, limit: limit);
    // await Future.delayed(Duration(seconds: 3));
    failureOrChat.fold(
      (Failure newFailure) {
        //chat = null;
        failure = newFailure;
        hasMoreMessages = false;
        _isLoadingOldMessages = false;
        notifyListeners();
      },
      (List<ChatMessageEntity> messages) {
        if (messages.isNotEmpty) {
          chat.addAll(messages);
        }
        // Si le nombre de messages reçus est inférieur à la limite, on considère qu'il n'y en a plus à charger
        _isLoadingOldMessages = false;
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

  Future<void> sendImageProfileForAllConnected() async {
    // Retrieve the image path from the provider, if available.
    final String? path = parameterProvider?.parameter.pathImageProfile;

    if (path != null) {
      // Compression de l'image avant encodage
      final XFile? compressedImage = await Utils.compressImage(File(path));
      if (compressedImage != null) {
        // Encode the image only once.
        final String imagesEncode = await Utils.convertFilePathToString(compressedImage.path); // Conversion du fichier d'image en chaîne.

        // Send the encoded image to all connected devices.
        for (final device in connectedDevices) {
          await controlerDevice?.sendMessage(device.deviceId, "PROFILE IMAGE $imagesEncode");
          final index = users.indexWhere((u) => u.name == device.deviceName);

          users[index].myLastStartEncodeImage = Utils.imagesEncode(imagesEncode);
        }
      }
    }
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
