/// This component is used in the ChatPage.
/// It is the message bar where the message is typed on and sent to
/// connected devices.
import 'package:flutter/material.dart';
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

  // Future<bool> forceConnexion() async {
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextFormField(
        onTap: () async {
          if (widget.device.state == SessionState.notConnected &&
              !widget.longDistance) {
            await connectToDevice(widget.device);
          }
        },
        controller: myController,
        decoration: InputDecoration(
          icon: const Icon(Icons.person),
          hintText: widget.device.state == SessionState.connected
              ? 'Envoie un message '
              : "Besoin d'être connecter ",
          suffixIcon: IconButton(
            onPressed: () {
              var msgId = nanoid(21);
              var data = {
                "sender": "$Global.myName",
                "receiver": "$widget.device.deviceName",
                "message": "$myController.text",
                "id": "$msgId",
                "Timestamp": DateTime.now().toUtc().toString(),
                "type": "Payload"
              };

              var payload = Payload(
                msgId,
                Global.myName,
                widget.converser,
                myController.text,
                DateTime.now().toUtc().toString(),
              );

              Global.cache[msgId] = payload;
              insertIntoMessageTable(payload);

              if (widget.longDistance) {
                Fluttertoast.showToast(
                    msg: 'hors de portée',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP,
                    timeInSecForIosWeb: 10,
                    backgroundColor: Colors.grey,
                    fontSize: 16.0);
              } else {
                Provider.of<Global>(context, listen: false).sentToConversations(
                  Msg(myController.text, "sent", data["Timestamp"]!, msgId),
                  widget.converser,
                );
              }

              // refreshMessages();
              myController.clear();
            },
            icon: const Icon(
              Icons.send,
            ),
          ),
        ),
      ),
    );
  }
}
