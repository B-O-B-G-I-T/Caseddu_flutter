import 'dart:io';
import 'package:caseddu/features/chat/presentation/pages/photo_pages/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nanoid/nanoid.dart';
import 'package:provider/provider.dart';
import '../../../../core/params/params.dart';
import '../providers/chat_provider.dart';

class MessagePanel extends StatefulWidget {
  MessagePanel({super.key, required this.converser, required this.device, required this.longDistance});

  final Device device;
  final String converser;
  final bool longDistance;
  final List<File> pictures = [];

  @override
  State<MessagePanel> createState() => _MessagePanelState();
}

class _MessagePanelState extends State<MessagePanel> {
  TextEditingController myController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showGallery = false;
  late ChatProvider chatProvider;

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
                  decoration: const InputDecoration(
                    hintText: 'Ecrivez votre message',
                  ),
                  focusNode: _focusNode,
                  maxLines: null,
                  onChanged: (value) async {
                    _showGallery = false;
                    if (widget.device.state == SessionState.notConnected && !widget.longDistance) {
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


// TODO faire une fonction qui fait un seul envoie de message plus facile a gerer et qui envoie image et texte
  Widget sendImageWidget() {
    return IconButton(
        // l'action ouvre une itent pour selectionner et envoyer a la paire
        onPressed: () async {
          // String path = await getImage();

          setState(() {
            //FocusScope.of(context).unfocus();
            _showGallery = !_showGallery;
            FocusScope.of(context).unfocus();
          });
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
    if (widget.longDistance && widget.device.state == SessionState.notConnected) {
      Fluttertoast.showToast(
          msg: 'hors de portée',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 10,
          backgroundColor: Colors.grey,
          fontSize: 16.0);
    } else {
      if (myController.text != "") {
        var msgId = nanoid(21);
        var message = myController.text.trim();
        var timestamp = DateTime.now();

        ChatMessageParams chatMessageParams = ChatMessageParams(
          msgId,
          'bob',
          widget.converser,
          message,
          '',
          'Payload',
          'Send',
          timestamp,
        );
        if (widget.device.state == SessionState.notConnected && !widget.longDistance) {
          await chatProvider.connectToDevice(widget.device);
        }
        chatProvider.eitherFailureOrEnvoieDeMessage(chatMessageParams: chatMessageParams);
      }
    }
    myController.clear();
  }
}
