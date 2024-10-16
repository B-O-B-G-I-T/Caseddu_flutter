import 'package:caseddu/features/chat/data/models/chat_message_model.dart';
import 'package:caseddu/features/chat/domain/entities/chat_user_entity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/p2p/fonctions.dart';
import '../providers/chat_provider.dart';
import '../widgets/P2P_widgets/list_tile_pour_utilisateur_connu.dart';
import '../widgets/P2P_widgets/search_widget.dart';
import 'chat_page.dart';

class ListeDesChatsPage extends StatefulWidget {
  const ListeDesChatsPage({super.key});

  @override
  State<ListeDesChatsPage> createState() => _ListeDesChatsPage();
}

class _ListeDesChatsPage extends State<ListeDesChatsPage> {
  bool isLoading = false;
  List<UserEntity> conversers = [];
  List<UserEntity> conversersFiltre = [];
  List<ChatMessageModel?> lastMessage = [];
  final TextEditingController _searchController = TextEditingController();
  late ChatProvider chatProvider;
  // In the init state, we need to update the cache everytime.
  @override
  void initState() {
    super.initState();
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.eitherFailureOrAllConversations();
    // readAllUpdateCache();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Whenever the the UI is built, each converser is added to the list
    // from the conversations map that stores the key as name of the device.
    // The names are inserted into the list conversers here and then displayed
    // with the help of ListView.builder.

    // on parse tout ce qu'on a en local pour avoir toutes les conversations de l'utilisateur
    // Provider.of<Global>(context).conversations.forEach((key, value) {
    //   conversers.add(key);
    // // sert à avoir une preview du dernier message
    //   lastMessage
    //       .add(Provider.of<Global>(context).conversations[key]!.values.last);
    // });

    // // chatProvider = Provider.of<ChatProvider>(context, listen: false);
    // chatProvider.eitherFailureOrAllConversations();
    // conversers = chatProvider.users.map((e) => Device(e.id, e.name, 0)).toList();
    // conversersFiltre = conversers;
    // lastMessage = chatProvider.users.map((e) => e.dernierMessage).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(builder: (context, chatProvider, child) {
      // chatProvider = Provider.of<ChatProvider>(context, listen: false);
      // chatProvider.eitherFailureOrAllConversations();
      conversers = chatProvider.users;
      if (_searchController.text.isEmpty) {
        conversersFiltre = conversers;
      }
      lastMessage = chatProvider.users.map((e) => e.dernierMessage).toList();

      return Column(
        children: [
          SearchWidget(
            onChanged: (value) {
              setState(() {
                conversersFiltre = Utils.runFilter(value, conversers, (user) => user.name);
              });
            },
            searchController: _searchController,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: conversersFiltre.isEmpty
                ? const Center(
                    child: Text("Pas de conversation"),
                  )
                : ListView.builder(
                    itemCount: conversersFiltre.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key("{$index.toString()} - ${DateTime.now().millisecondsSinceEpoch}"),
                        direction: DismissDirection.endToStart,
                        // gere la suppréssion des conversations
                        onDismissed: (direction) {
                          
                          chatProvider.deleteConversation(conversersFiltre[index]);
                          Fluttertoast.showToast(
                              msg: 'conversation supprimé',
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.SNACKBAR,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black,
                              fontSize: 16.0);
                        },
                        background: Container(
                          alignment: AlignmentDirectional.centerEnd,
                          color: Colors.red,
                          child: const Text(
                            "Supprimé",
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                        // widget qui sont les cases pour afficher un utilisateur
                        child: ListTilePourUtilisateurConnu(
                          deviceName: conversersFiltre[index].name,
                          message: lastMessage[index]!.message,
                          timestamp: lastMessage[index]!.timestamp.toString(),
                          typeMessage: lastMessage[index]!.type,
                          onTap: () {
                            // TODO : faire avec goRouter
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  converser: conversersFiltre[index].name,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
          )
        ],
      );
    });
  }
}
