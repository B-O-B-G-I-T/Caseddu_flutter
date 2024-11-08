// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/p2p/fonctions.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../providers/chat_provider.dart';
import '../widgets/P2P_widgets/connection_button.dart';
import '../widgets/chat_widgets/page_chat/chat_Bubble_widget.dart';
import '../widgets/chat_widgets/page_chat/message_panel.dart';
import '../widgets/chat_widgets/page_chat/lost_connexion_widget.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.converser});

  final String converser;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  List<ChatMessageEntity> messageList = [];
  late Device? device;
  TextEditingController myController = TextEditingController();
  late String myName = '';
  late ChatProvider chatProvider;

  @override
  void initState() {
    super.initState();
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.sender = widget.converser;
    myName = chatProvider.myName;
    device = chatProvider.devices.firstWhere((element) => element.deviceName == widget.converser, orElse: () => Device("", "", SessionState.tooFar));
    chatProvider.eitherFailureOrConversation(myName, widget.converser);

    // Ajout de la logique de défilement automatique
    // chatProvider.addListener(_scrollToBottomOnNewMessage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    myController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Cette méthode est déclenchée lorsque de nouveaux messages sont reçus
  void _scrollToBottomOnNewMessage() {
    if (mounted) {
      setState(() {
        messageList = chatProvider.chat;
      });
    }
  }

// TODO création de groupe de conversation
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(builder: (context, chatProvider, child) {
      device = chatProvider.devices.firstWhere(
        (element) => element.deviceName == widget.converser,
        orElse: () => Device(widget.converser, widget.converser, SessionState.tooFar),
      );

      // Assurer que les messages sont triés avant le rendu
      messageList = chatProvider.chat..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      return Scaffold(
        // resizeToAvoidBottomInset: false,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(widget.converser),
          actions: [
            ConnectionButton(
              device: device!,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: Container(
              color: Colors.grey,
              height: 0.5,
            ),
          ),
        ),
        body: device!.deviceId != "" && device!.deviceName != ""
            ? SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: messageList.isEmpty
                          ? const Center(
                              child: Text('Lancé la conversation'),
                            )
                          : Align(
                              alignment: Alignment.topCenter,
                              child: SingleChildScrollView(
                                reverse: true,
                                controller: _scrollController,
                                child: Column(
                                  children: [
                                    Text(
                                      Utils.depuisQuandCeMessageEstRecu(timeStamp: messageList.first.timestamp.toString()),
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                    ListView.builder(
                                      key: const PageStorageKey<String>('chatList'),
                                      // Builder to view messages chronologically
                                      shrinkWrap: true,

                                      physics: const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.all(0),
                                      itemCount: messageList.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        // début de la structure des messages
                                        final message = messageList[index];
                                        final bool isMe = messageList[index].sender != myName;

                                        return ChatBubble(
                                          isMe: isMe,
                                          converser: widget.converser,
                                          message: message,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    // TODO: ferlmer le clavier lorsque l'on remonte la liste
                    SafeArea(
                      child: MessagePanel(
                        converser: widget.converser,
                        device: device!,
                      ),
                    ),
                  ],
                ),
              )
            : const LostConnectionWidget(),
      );
    });
  }
}
