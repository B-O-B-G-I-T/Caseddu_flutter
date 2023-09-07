import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/fonctions.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:provider/provider.dart';

import '../../global/global.dart';
import '../../modeles/messages_model.dart';
import '../../p2p/adhoc_housekeeping.dart';
import '../../widget/P2P_widget/connection_button.dart';
import 'ecritoire.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.converser});

  final String converser;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Msg> messageList = [];
  late Device device = Device(widget.converser, widget.converser, 0);
  TextEditingController myController = TextEditingController();

  bool longDistance = false;
  late Stream<List<Msg>> messageStream;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    /// If we have previously conversed with the device, it is going to store
    /// the conversations in the messageList
    if (Provider.of<Global>(context).conversations[widget.converser] != null) {
      messageList = [];
      Provider.of<Global>(context)
          .conversations[widget.converser]!
          .forEach((key, value) {
        messageList.add(value);
      });

      try {
        device = Provider.of<Global>(context)
            .devices
            .firstWhere((element) => element.deviceName == widget.converser);
        longDistance = false;
      } catch (e) {
        longDistance = true;
      }

      // Since there can be long list of message, the scroll controller
      // auto scrolls to bottom of the list.
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 50,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    }
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.converser),
        actions: [ConnectionButton(device: device, longDistance: longDistance)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messageList.isEmpty
                  ? const Center(
                      child: Text('Lancé la conversation'),
                    )
                  // : StreamBuilder<List<Msg>>(
                  //     stream: messageStream,
                  //     builder: (context, snapshot) {
                  //       if (!snapshot.hasData)
                  //         return CircularProgressIndicator();
                  //       final messages = snapshot.data!;
                  //       return ListView.builder(
                  //         // Builder to view messages chronologically
                  //         shrinkWrap: true,
                  //         controller: _scrollController,
                  //         padding: const EdgeInsets.all(8),
                  //         itemCount: messages.length,
                  //         itemBuilder: (BuildContext context, int index) {
                  //           return Bubble(
                  //             margin: const BubbleEdges.only(top: 10),
                  //             nip: messages[index].msgtype == 'sent'
                  //                 ? BubbleNip.rightTop
                  //                 : BubbleNip.leftTop,
                  //             color: messages[index].msgtype == 'sent'
                  //                 ? const Color(0xffd1c4e9)
                  //                 : const Color(0xff80DEEA),
                  //             child: ListTile(
                  //               dense: true,
                  //               title: Text(
                  //                 "${messages[index].msgtype}: ${messages[index].message}",
                  //                 textAlign: messages[index].msgtype == 'sent'
                  //                     ? TextAlign.right
                  //                     : TextAlign.left,
                  //               ),
                  //               subtitle: Text(
                  //                 dateFormatter(
                  //                   timeStamp: messages[index].timestamp,
                  //                 ),
                  //                 textAlign: messages[index].msgtype == 'sent'
                  //                     ? TextAlign.right
                  //                     : TextAlign.left,
                  //               ),
                  //             ),
                  //           );
                  //         },
                  //       );
                  //     },
                  : ListView.builder(
                      // Builder to view messages chronologically
                      shrinkWrap: true,
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: messageList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Bubble(
                          margin: const BubbleEdges.only(top: 10),
                          nip: messageList[index].msgtype == 'sent'
                              ? BubbleNip.rightTop
                              : BubbleNip.leftTop,
                          color: messageList[index].msgtype == 'sent'
                              ? const Color(0xffd1c4e9)
                              : const Color(0xff80DEEA),
                          child: ListTile(
                            dense: true,
                            title: Text(
                              "${messageList[index].msgtype}: ${messageList[index].message}",
                              textAlign: messageList[index].msgtype == 'sent'
                                  ? TextAlign.right
                                  : TextAlign.left,
                            ),
                            subtitle: Text(
                              Utils.dateFormatter(
                                timeStamp: messageList[index].timestamp,
                              ),
                              textAlign: messageList[index].msgtype == 'sent'
                                  ? TextAlign.right
                                  : TextAlign.left,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            MessagePanel(
                converser: widget.converser,
                device: device,
                longDistance: longDistance),
          ],
        ),
      ),
    );
  }
}
