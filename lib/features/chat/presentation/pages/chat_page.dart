// ignore_for_file: unused_element
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:intl/intl.dart';
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
    chatProvider.eitherFailureOrConversation(myName, widget.converser, limit: 20);

    // Écoute des nouveaux messages pour faire défiler vers le bas
    chatProvider.newMessageStream.listen((newMessage) {
      _scrollToBottomOnNewMessage();
    });

    // Ajout un listener pour charger les messages plus anciens quand on atteint le haut de la liste
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    myController.dispose();
    _scrollController.dispose();
    chatProvider.chat = [];
    chatProvider.hasMoreMessages = true;
    chatProvider.removeListener(_scrollToBottomOnNewMessage);

    super.dispose();
  }

  // Cette méthode est déclenchée lorsque de nouveaux messages sont reçus
  void _scrollToBottomOnNewMessage() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _onScroll() {
    if (mounted) {
      if (_scrollController.position.atEdge && _scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // Récupère la date du plus ancien message déjà chargé
        final oldestMessageDate = chatProvider.chat.isNotEmpty ? chatProvider.chat.last.timestamp : DateTime.now();
        // Charger les messages plus anciens
        if (!chatProvider.isLoadingOldMessages) {
          chatProvider.eitherFailureOrConversation(myName, widget.converser, beforeDate: oldestMessageDate);
        }
      }
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
      messageList = chatProvider.chat..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return Scaffold(
        // resizeToAvoidBottomInset: false,
        resizeToAvoidBottomInset: true,

        appBar: CustomAppBar(device: device!, title: widget.converser),
        body: device!.deviceId != "" && device!.deviceName != ""
            ? Column(
                children: [
                  // Affichage du texte de chargement si des messages sont en cours de chargement
                  Expanded(
                    child: messageList.isEmpty
                        ? chatProvider.isLoadingOldMessages
                            ? const LoadingScreen()
                            : Center(
                                child: Text(AppLocalizations.of(context)!.start_conversation),
                              )
                        : Align(
                            alignment: Alignment.topCenter,
                            child: ListView.builder(
                              controller: _scrollController,
                              key: const PageStorageKey<String>('chatList'),
                              // Builder to view messages chronologically
                              shrinkWrap: true,
                              reverse: true,
                              padding: const EdgeInsets.all(0),
                              itemCount: messageList.length,
                              itemBuilder: (BuildContext context, int index) {
                                // Liste des messages
                                // début de la structure des messages
                                final message = messageList[index];
                                final bool isMe = messageList[index].sender != myName;

                                // Vérifiez si c'est un nouveau jour
                                bool isNewDay = false;
                                if (index == messageList.length - 1 || !_isSameDay(messageList[index + 1].timestamp, message.timestamp)) {
                                  isNewDay = true;
                                }

                                // gère la colapse des messages
                                bool collapseMessages = false;
                                if (index < messageList.length - 1 && isMe == (messageList[index + 1].sender != myName)) {
                                  final prevMessage = messageList[index + 1];
                                  // Vérifie si les timestamps sont suffisamment différents
                                  if (message.timestamp.difference(prevMessage.timestamp).inMinutes < 1) {
                                    collapseMessages = true; // Cache le timestamp si proche du précédent
                                  }
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Texte de chargement superposé au-dessus de tout
                                    if (chatProvider.isLoadingOldMessages && index == messageList.length - 1) const LoadingIndicator(),
                                    // Message indiquant qu'il n'y a plus de messages à charger
                                    if (!chatProvider.hasMoreMessages && index == messageList.length - 1) const NoMoreMessagesIndicator(),
                                    // Affiche la date si c'est un nouveau jour
                                    if (isNewDay) ...[
                                      DateSeparator(date: message.timestamp), // Affiche la date si c'est un nouveau jour
                                      // Affiche le temps écoulé depuis le premier message
                                      TimeAgoIndicator(timeStamp: message.timestamp.toString()),
                                    ],
                                    // Affiche le message
                                    ChatBubble(
                                      isMe: isMe,
                                      converser: widget.converser,
                                      message: message,
                                      collapseMessages: collapseMessages,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                  ),
                  SafeArea(
                    child: MessagePanel(
                      converser: widget.converser,
                      device: device!,
                      
                    ),
                  ),
                ],
              )
            : const LostConnectionWidget(),
      );
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8.0),
      child: Text(
        AppLocalizations.of(context)!.loading,
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }
}

class NoMoreMessagesIndicator extends StatelessWidget {
  const NoMoreMessagesIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8.0),
      child: Text(
        AppLocalizations.of(context)!.no_more_messages,
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }
}

class TimeAgoIndicator extends StatelessWidget {
  final String timeStamp;

  const TimeAgoIndicator({super.key, required this.timeStamp});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        Utils.depuisQuandCeMessageEstRecu(timeStamp: timeStamp, context: context),
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}

class DateSeparator extends StatelessWidget {
  final DateTime date;

  const DateSeparator({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Formatez la date avec `Intl` pour un affichage plus agréable
    final formattedDate = DateFormat('MMMM dd, yyyy').format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            formattedDate,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicateur de chargement avec animation
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                strokeWidth: 4,
              ),
              const SizedBox(height: 20),
              // Texte de chargement stylisé
              Text(
                AppLocalizations.of(context)!.loading,
                style: ThemeData.light().textTheme.titleLarge!,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Device device;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.device,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        ConnectionButton(
          device: device,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(
          color: Colors.grey,
          height: 0.5,
        ),
      ),
    );
  }
}
