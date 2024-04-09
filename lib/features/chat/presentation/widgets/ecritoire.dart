/// This component is used in the ChatPage.
/// It is the message bar where the message is typed on and sent to
/// connected devices.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nanoid/nanoid.dart';
import 'package:provider/provider.dart';
import '../../../../core/params/params.dart';
import '../providers/chat_provider.dart';
import 'scroll_h_for_pictures_widget.dart';

class MessagePanel extends StatefulWidget {
  MessagePanel({Key? key, required this.converser, required this.device, required this.longDistance}) : super(key: key);
  final Device device;
  final String converser;
  final bool longDistance;

  final List<File> pictures = [];

  @override
  State<MessagePanel> createState() => _MessagePanelState();
}

class _MessagePanelState extends State<MessagePanel> {
  TextEditingController myController = TextEditingController();
  bool _showGallery = false;
  List<String> imagePath = [];
  late ChatProvider chatProvider;

  @override
  void initState() {
    super.initState();
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (imagePath.isNotEmpty)
          // Vérifie si imagePath a une valeur
          scrollHForPictures(
            pictures: imagePath,
          ),
        Row(
          children: [
            const Icon(Icons.person),
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                onTap: () async {
                  _showGallery = false;
                  if (widget.device.state == SessionState.notConnected && !widget.longDistance) {
                    await chatProvider.connectToDevice(widget.device);
                  }
                },
                controller: myController,
              ),
            ),
            Row(
              children: [
                sendImageWidget(),
                sendMessageWidget(),
              ],
            ),
          ],
        ),
        // TODO créé un widget pour faire la selection des images multiple et intgrer pas une itent comme suit
        // _showGallery ? ImageGallery() : const Center()
      ],
    );
  }

  Future<String> getImage() async {
    ImagePicker picker = ImagePicker();
    var pickedImage = await picker.pickImage(source: ImageSource.gallery);
    String path = pickedImage!.path;
    return path;
  }

// TODO faire une fonction qui fait un seul envoie de message plus facile a gerer et qui envoie image et texte
  Widget sendImageWidget() {
    return IconButton(
        // l'action ouvre une itent pour selectionner et envoyer a la paire
        onPressed: () async {
          String path = await getImage();

          imagePath.add(path);
          setState(() {
            //FocusScope.of(context).unfocus();
            _showGallery = !_showGallery;
          });
        },
        icon: const Icon(Icons.image_outlined));
  }

  Widget sendMessageWidget() {
    return IconButton(
      onPressed: () async {
        if (widget.longDistance && widget.device.state == SessionState.notConnected) {
          Fluttertoast.showToast(
              msg: 'hors de portée',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 10,
              backgroundColor: Colors.grey,
              fontSize: 16.0);
        } else {
          if (myController.text != "" || imagePath.isNotEmpty) {
            //print(imagePath);
            var msgId = nanoid(21);
            var message = myController.text.trim();
            var timestamp = DateTime.now();
            var listImages = imagePath.join(',');

            ChatMessageParams chatMessageParams = ChatMessageParams(
              msgId,
              'bob',
              widget.converser,
              message,
              listImages,
              'Payload',
              'Send',
              timestamp,
            );
            if (imagePath.isNotEmpty) {
              chatMessageParams.type = 'Image';
            }

            if (widget.device.state == SessionState.notConnected && !widget.longDistance) {
              await chatProvider.connectToDevice(widget.device);
            }
            chatProvider.eitherFailureOrEnvoieDeMessage(chatMessageParams: chatMessageParams);
          }
        }
        // refreshMessages();
        imagePath.clear();
        myController.clear();
      },
      icon: const Icon(
        Icons.send,
      ),
    );
  }
}

