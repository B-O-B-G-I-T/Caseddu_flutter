// ignore_for_file: use_build_context_synchronously
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';
import 'package:caseddu/core/utils/p2p/fonctions.dart';
import 'package:caseddu/features/chat/presentation/widgets/chat_widgets/page_chat/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nanoid/nanoid.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/params/params.dart';
import '../../../providers/chat_provider.dart';

class MessagePanel extends StatefulWidget {
  MessagePanel({super.key, required this.converser, required this.device});

  final Device device;
  final String converser;
  final List<File> pictures = [];

  @override
  State<MessagePanel> createState() => _MessagePanelState();
}

class _MessagePanelState extends State<MessagePanel> {
  TextEditingController myController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showGallery = false;
  late ChatProvider chatProvider;
  late PermissionState permissionStatus = PermissionState.notDetermined;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.delta.dy < -10) {
          // Si le mouvement vertical est vers le haut
          _focusNode.requestFocus();
        }
        if (details.delta.dy < 10) {
          // Si le mouvement vertical est vers le bas
          FocusScope.of(context).unfocus(); // <-- Hide virtual keyboard
        }
      },
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.person),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.send, // Changer le bouton retour en bouton d'envoi
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.write_your_message,
                  ),
                  focusNode: _focusNode,
                  maxLines: null,
                  onTap: () => setState(() {
                    if (_showGallery) _showGallery = !_showGallery;
                  }),
                  onChanged: (value) async {
                    _showGallery = false;
                    if (widget.device.state != SessionState.connected) {
                      await chatProvider.connectToDevice(widget.device);
                    }
                  },
                  controller: myController, // Action lors de l'appui sur le bouton d'envoi
                  onSubmitted: (value) {
                    sendMessage();
                  },
                ),
              ),
              sendImageWidget(),
            ],
          ),
          _showGallery
              ? MyImagePicker(
                  chatProvider: chatProvider,
                  device: widget.device,
                  converser: widget.converser,
                )
              : const Center()
        ],
      ),
    );
  }

  Widget sendImageWidget() {
    return IconButton(
        // l'action ouvre une itent pour selectionner et envoyer a la paire
        onPressed: () async {
          // String path = await getImage();

          FocusScope.of(context).unfocus();

          permissionStatus = await PhotoManager.requestPermissionExtend();
          if (permissionStatus == PermissionState.authorized && widget.device.state != SessionState.tooFar) {
            if (widget.device.state != SessionState.connected) {
              await chatProvider.connectToDevice(widget.device);
            }
            setState(() {
              _showGallery = !_showGallery;
            });
            // } else if (permissionStatus.hasAccess && !_showGallery) {
            //   Utils.showLimitedAccessDialog(context: context);
          } else {
            Utils.showPermissionDeniedDialog(context: context);
          }
        },
        icon: const Icon(Icons.image_outlined));
  }

  Widget sendMessageWidget() {
    return IconButton(
      onPressed: () async {
        sendMessage();
      },
      icon: const Icon(
        Icons.send,
      ),
    );
  }

  void sendMessage() async {
    if (widget.device.state == SessionState.tooFar) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.out_of_range,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.black,
          fontSize: 16.0);
    } else if (widget.device.state == SessionState.connecting) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.try_it_when_you_re_connected,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.yellow,
          textColor: Colors.black,
          fontSize: 16.0);
    } else {
      if (myController.text != "") {
        var msgId = nanoid(21);
        var message = myController.text.trim();
        var timestamp = DateTime.now();

        ChatMessageParams chatMessageParams = ChatMessageParams(
          id: msgId,
          sender: 'bob',
          receiver: widget.converser,
          message: message,
          images: '',
          type: 'payload',
          sendOrReceived: 'Send',
          timestamp: timestamp,
          ack: 0,
        );
        if (widget.device.state != SessionState.connected) {
          await chatProvider.connectToDevice(widget.device);
        }
        chatProvider.eitherFailureOrEnvoieDeMessage(chatMessageParams: chatMessageParams);
      }
    }
    _focusNode.requestFocus();
    myController.clear();
  }
}
