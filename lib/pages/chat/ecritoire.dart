/// This component is used in the ChatPage.
/// It is the message bar where the message is typed on and sent to
/// connected devices.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/photo_pages/gallery_widget.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nanoid/nanoid.dart';
import 'package:provider/provider.dart';

import '../../database/DatabaseHelper.dart';
import '../../global/global.dart';
import '../../global/payload.dart';
import '../../modeles/messages_model.dart';
import '../../p2p/adhoc_housekeeping.dart';

class MessagePanel extends StatefulWidget {
  const MessagePanel(
      {Key? key,
      required this.converser,
      required this.device,
      required this.longDistance})
      : super(key: key);
  final Device device;
  final String converser;
  final bool longDistance;
  @override
  State<MessagePanel> createState() => _MessagePanelState();
}

class _MessagePanelState extends State<MessagePanel> {
  TextEditingController myController = TextEditingController();
  bool _showGallery = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.person),
              Expanded(
                child: TextFormField(
                  autofocus: true,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  onTap: () async {
                    _showGallery = false;
                    if (widget.device.state == SessionState.notConnected &&
                        !widget.longDistance) {
                      await connectToDevice(widget.device);
                    }
                  },
                  controller: myController,
                ),
              ),
              Row(
                children: [
                  sendImage(),
                  sendMessage(),
                ],
              ),
            ],
          ),
          _showGallery ? GalerieWidget2() : const Center()
        ],
      ),
    );
  }

  Widget sendImage() {
    String ImageToBase64String(File imageFile) {
      final bytes = imageFile.readAsBytesSync();
      return base64Encode(bytes);
    }

    return IconButton(
        onPressed: () {
          setState(() {
            FocusScope.of(context).unfocus();
            _showGallery = !_showGallery;
          });
        },

        // gere l'envoie de photo ajout du d'un chemin dinamyque avec une selection dans une galerie
        // onPressed: () {
        //   var msgId = nanoid(21);
        //   // TODO modifier le chemin pour avoir les photo en dossier
        //   File file = File(
        //       '/Users/bobsmac/Desktop/Caseddu_flutter/assets/images/cerf.jpg');
        //   var imageToBase64String = ImageToBase64String(file);
        //   var payload = Payload(msgId, Global.myName, widget.converser,
        //       file.path, DateTime.now().toUtc().toString(), "Image");

        //   Global.cache[msgId] = payload;
        //   insertIntoMessageTable(payload);

        //   Provider.of<Global>(context, listen: false).sentToConversations(
        //       Msg(imageToBase64String, "sent", payload.timestamp, "Image",
        //           msgId),
        //       widget.converser,
        //       isImage: file.path);
        // },
        icon: const Icon(Icons.image_outlined));
  }

  Widget sendMessage() {
    return IconButton(
      onPressed: () {
        var msgId = nanoid(21);

        var payload = Payload(msgId, Global.myName, widget.converser,
            myController.text, DateTime.now().toUtc().toString(), "Payload");

        Global.cache[msgId] = payload;
        insertIntoMessageTable(payload);

        if (widget.longDistance && myController.text != "") {
          Fluttertoast.showToast(
              msg: 'hors de portée',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 10,
              backgroundColor: Colors.grey,
              fontSize: 16.0);
        } else {
          Provider.of<Global>(context, listen: false).sentToConversations(
            Msg(myController.text, "sent", payload.timestamp, "Payload", msgId),
            widget.converser,
          );
        }

        // refreshMessages();
        myController.clear();
      },
      icon: const Icon(
        Icons.send,
      ),
    );
  }
}
