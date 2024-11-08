// ignore_for_file: use_build_context_synchronously
import 'package:caseddu/features/chat/domain/entities/chat_message_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nanoid/nanoid.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/params/params.dart';
import '../../../providers/chat_provider.dart';
import 'chat_message_text_widget.dart';
import 'utils_widgets.dart'; // For Clipboard functionality

class ChatBubble extends StatefulWidget {
  final bool isMe;
  final String converser;
  final ChatMessageEntity message;

  const ChatBubble({
    super.key,
    required this.isMe,
    required this.converser,
    required this.message,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  final GlobalKey _chatBubbleKey = GlobalKey(); // GlobalKey to access widget position and size
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _offsetAnimation;

  late ChatProvider chatProvider;

  @override
  void initState() {
    super.initState();
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _offsetAnimation = Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0, 0.1)).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        // Trigger the context menu below the widget
        _showContextMenu(context);
        setState(() {
          _isPressed = true; // Set the widget as pressed to show raised effect
        });
        _animationController.forward(); // Start the animation
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.translate(
              offset: _offsetAnimation.value,
              child: Container(
                key: _chatBubbleKey,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isPressed
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4), spreadRadius: 1, blurRadius: 10,
                            offset: const Offset(0, 2), // changes position of shadow
                          ),
                        ]
                      : [],
                ),
                child: widget.message.type == "DELETE"
                    ? DeleteMessageWidget(isMe: widget.isMe, deviceName: widget.converser)
                    : Material(
                        elevation: _isPressed ? 3 : 0,
                        shadowColor: Colors.black.withOpacity(0.4),
                        color: Colors.white,
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Colored bar
                                laBarre(widget.isMe),
                                // Title and text
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Title and received date
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Title
                                          receptionOuEnvoi(widget.converser, widget.isMe),
                                          // Received date
                                          dateDuMessage(widget.message.timestamp.toString()),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      // Message text or image
                                      ChatMessageWidget(message: widget.message),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Method to show context menu below the widget
  void _showContextMenu(BuildContext context) async {
    // Find the position and size of the widget using the GlobalKey
    final renderBox = _chatBubbleKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final offset = renderBox.localToGlobal(Offset.zero); // Position of the widget
      final size = renderBox.size; // Size of the widget

      final menuPosition = RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 5, // Position menu below the widget
        offset.dx + size.width - 100,
        0,
      );

      final menuResult = await showMymenu(size, context, menuPosition);

      // Handle menu item selection
      if (menuResult == 'copy') {
        // Copy the message text to clipboard
        copyMessage(context);
      } else if (menuResult == 'delete') {
        // Handle delete functionality
        deleteMessageByMenu();
      } else if (menuResult == 'send_back') {
        await sendBackByMenu();
      }
    }

    // Handle other menu items
    setState(() {
      _isPressed = false;
    });

    _animationController.reverse();
  }

  Future<void> sendBackByMenu() async {
    var msgId = nanoid(21);
    var timestamp = DateTime.now();

    ChatMessageParams chatMessageParams = ChatMessageParams(
      id: msgId,
      sender: 'bob',
      receiver: widget.converser,
      message: widget.message.message,
      images: '',
      type: 'payload',
      sendOrReceived: 'Send',
      timestamp: timestamp,
      ack: 0,
    );

    chatProvider.eitherFailureOrDeleteMessage(chatMessageEntity: widget.message);
    final d = chatProvider.devices.firstWhere((element) => element.deviceName == widget.converser);
    if (d.state == SessionState.notConnected) {
      await chatProvider.connectToDevice(d);
    } else if (d.state == SessionState.tooFar) {
      Fluttertoast.showToast(
          msg: 'hors de portée',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 10,
          backgroundColor: Colors.grey,
          fontSize: 16.0);
    }
    chatProvider.eitherFailureOrEnvoieDeMessage(chatMessageParams: chatMessageParams);
  }

  void deleteMessageByMenu() {
    if (chatProvider.devices.firstWhere((element) => element.deviceName == widget.converser).state != SessionState.connected) {
      Fluttertoast.showToast(
          msg: 'hors de portée',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 10,
          backgroundColor: Colors.grey,
          fontSize: 16.0);
    } else {
      chatProvider.eitherFailureOrDeleteMessage(chatMessageEntity: widget.message);
      final ChatMessageParams params = widget.message.toParamsDelete();
      chatProvider.eitherFailureOrEnvoieDeMessage(chatMessageParams: params);
    }
  }

  Future<String?> showMymenu(Size size, BuildContext context, RelativeRect menuPosition) {
    return showMenu(
      constraints: BoxConstraints(
        minWidth: 100,
        maxWidth: size.width,
      ),
      context: context,
      position: menuPosition,
      items: [
        if (widget.message.ack == 0)
          const PopupMenuItem(
            value: 'send_back',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Renvoyer'),
                Icon(Icons.send),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'copy',
          child: SizedBox(
            width: 5000,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Copier'),
                Icon(Icons.copy),
              ],
            ),
          ),
        ),
        if (!widget.isMe)
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Supprimer'),
                Icon(Icons.delete),
              ],
            ),
          ),
      ],
      elevation: 8.0, // Shadow for the menu
      color: Colors.white, // White background for the menu
    );
  }

  void copyMessage(context) {
    // Copy the message text to clipboard
    Clipboard.setData(ClipboardData(text: widget.message.message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copied')),
    );
  }
}

class DeleteMessageWidget extends StatelessWidget {
  const DeleteMessageWidget({
    super.key,
    required this.isMe,
    required this.deviceName,
  });

  final bool isMe;
  final String deviceName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        !isMe ? "Message supprimé" : "Message supprimé par $deviceName",
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
    );
  }
}
