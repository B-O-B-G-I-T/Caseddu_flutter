import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/p2p/fonctions.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../providers/chat_provider.dart';
import '../widgets/P2P_widgets/connection_button.dart';
import '../widgets/chat_widgets/preview_picture/all_preview_picture_widget.dart';
import '../widgets/chat_widgets/page_chat/message_panel.dart';
import '../widgets/chat_widgets/page_chat/lost_connexion_widget.dart';
import '../widgets/chat_widgets/page_chat/utils_widgets.dart';

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
  bool longDistance = false;
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

// TODO création de groupe de conversation
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(builder: (context, chatProvider, child) {
      device = chatProvider.devices.firstWhere(
        (element) => element.deviceName == widget.converser,
        orElse: () => Device(widget.converser, widget.converser, SessionState.tooFar),
      );

      messageList = chatProvider.chat;
      return Scaffold(
        // resizeToAvoidBottomInset: false,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(widget.converser),
          actions: [
            ConnectionButton(
              device: device!,
              longDistance: longDistance,
            ),
          ],
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
                                      // Builder to view messages chronologically
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.all(0),
                                      itemCount: messageList.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        // début de la structure des messages
                                        final bool isMe = messageList[index].sender != myName;

                                        return IntrinsicHeight(
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // barre coloré
                                                laBarre(isMe),
                                                // titre et text
                                                Expanded(
                                                  flex: 6,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // titre et date de reception
                                                      // titre
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          receptionOuEnvoi(widget.converser, isMe),
                                                          // date de reception
                                                          dateDuMessage(messageList[index].timestamp.toString()),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      // texte ou image
                                                      if (messageList[index].images != '')
                                                        AllPreviewPictureChatWidget(messageList: messageList[index])
                                                      else
                                                        Text(
                                                          messageList[index].message,
                                                          textAlign: TextAlign.left,
                                                          style: const TextStyle(color: Colors.black, fontSize: 14),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    SafeArea(
                      child: MessagePanel(
                        converser: widget.converser,
                        device: device!,
                        longDistance: longDistance,
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
