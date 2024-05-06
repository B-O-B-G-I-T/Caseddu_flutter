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
  final FocusNode _focusNode = FocusNode();
  bool _showGallery = false;
  List<String> imagePath = [];
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
                  decoration: const InputDecoration(
                    hintText: 'Ecrivez votre message',
                  ),
                  focusNode: _focusNode,
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
      ),
    );
  }

  Future<String> getImage() async {
    ImagePicker picker = ImagePicker();
    FocusScope.of(context).unfocus(); // masque le clavier
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

            ChatMessageParams chatMessageParams = ChatMessageParams(
              msgId,
              'bob',
              widget.converser,
              message,
              imagePath,
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
