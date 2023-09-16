import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/fonctions.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:provider/provider.dart';

import '../../global/global.dart';
import '../../modeles/messages_model.dart';
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

// TODO partage de fichiers et image
// TODO création de groupe

  @override
  Widget build(BuildContext context) {
    // essai de trouver le device associe et de détermine si il est a coté ou loin
    try {
      device = Provider.of<Global>(context)
          .devices
          .firstWhere((element) => element.deviceName == widget.converser);
      longDistance = false;
    } catch (e) {
      longDistance = true;
    }

    /// If we have previously conversed with the device, it is going to store
    /// the conversations in the messageList
    if (Provider.of<Global>(context).conversations[widget.converser] != null) {
      messageList = [];
      Provider.of<Global>(context)
          .conversations[widget.converser]!
          .forEach((key, value) {
        messageList.add(value);
      });

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
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            Utils.depuisQuandCeMessageEstRecu(
                                timeStamp: messageList.first.timestamp),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          ListView.builder(
                            // Builder to view messages chronologically
                            shrinkWrap: true,
                            controller: _scrollController,
                            padding: const EdgeInsets.all(0),
                            itemCount: messageList.length,

                            itemBuilder: (BuildContext context, int index) {
                              return IntrinsicHeight(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // barre coloré
                                        laBarre(
                                            messageList[index].sendOrReceived),
                                        // titre et text
                                        Expanded(
                                          flex: 6,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // titre et date de reception
                                              // titre
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  receptionOuEnvoi(
                                                      messageList[index]
                                                          .sendOrReceived),
                                                  // date de reception
                                                  dateDuMessage(
                                                      messageList[index]
                                                          .timestamp),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              // texte ou image
                                              messageList[index].typeMsg ==
                                                      'Image'
                                                  ? Image.asset(
                                                      messageList[index]
                                                          .message)
                                                  : Text(
                                                      messageList[index]
                                                          .message,
                                                      textAlign: TextAlign.left,
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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

@override
Widget laBarre(String messageDeReceptionOuEnvoi) {
  return Row(
    children: [
      Container(
        width: 2,
        height: double.infinity,
        color: messageDeReceptionOuEnvoi == 'sent' ? Colors.red : Colors.blue,
      ),
      const SizedBox(
        width: 5,
      )
    ],
  );
}

@override
Widget receptionOuEnvoi(
  String messageDeReceptionOuEnvoi,
) {
  return Text(
    messageDeReceptionOuEnvoi,
    style: TextStyle(
      color: messageDeReceptionOuEnvoi == 'sent' ? Colors.red : Colors.blue,
    ),
  );
}

@override
Widget dateDuMessage(String dateDeLaReception) {
  return Text(
    Utils.dateFormatter(
      timeStamp: dateDeLaReception,
    ),
    style: const TextStyle(fontSize: 10),
  );
}
