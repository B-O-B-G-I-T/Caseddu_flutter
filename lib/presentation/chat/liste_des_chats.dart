import 'package:flutter/material.dart';
import 'package:flutter_application_1/modeles/messages_model.dart';
import 'package:flutter_application_1/global/utils/fonctions.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../database/databasehelper.dart';
import '../../database/messages_database.dart';
import '../../global/global.dart';
import '../../widget/P2P_widget/search_widget.dart';
import 'chat_page.dart';

class ListeDesChatsPage extends StatefulWidget {
  const ListeDesChatsPage({super.key});

  @override
  State<ListeDesChatsPage> createState() => _ListeDesChatsPage();
}

class _ListeDesChatsPage extends State<ListeDesChatsPage> {
  bool isLoading = false;
  List<String> conversers = [];
  List<String> conversersFiltre = [];

  List<Msg> lastMessage = [];
  final TextEditingController _searchController = TextEditingController();

  // In the init state, we need to update the cache everytime.
  @override
  void initState() {
    super.initState();
    readAllUpdateCache();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Whenever the the UI is built, each converser is added to the list
    // from the conversations map that stores the key as name of the device.
    // The names are inserted into the list conversers here and then displayed
    // with the help of ListView.builder.
    Provider.of<Global>(context).conversations.forEach((key, value) {
      conversers.add(key);

      lastMessage
          .add(Provider.of<Global>(context).conversations[key]!.values.last);
    });

    conversersFiltre = conversers;
  }

  void _runFilter(String enteredKeyword) {
    List<String> results = [];
    if (enteredKeyword.isEmpty) {
      results = conversers;
    } else {
      results = conversers
          .where((user) =>
              user.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      conversersFiltre = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchWidget(
          onChanged: _runFilter,
          searchController: _searchController,
        ),
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
                      key: Key(
                          "{$index.toString()} - ${DateTime.now().millisecondsSinceEpoch}"),
                      direction: DismissDirection.endToStart,
                      // gere la suppréssion des conversations
                      onDismissed: (direction) {
                        MessageDB.instance
                            .deleteFromConversationsByConverserTable(
                                conversers[index]);
                        Provider.of<Global>(context, listen: false)
                            .conversations
                            .remove(conversersFiltre[index]);
                        //Global.cache.remove(decodedMessage["id"]);

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
                      child: ListTile(
                        title: Text(conversersFiltre[index]),
                        subtitle: Text(Utils.depuisQuandCeMessageEstRecu(
                            timeStamp: lastMessage[index].timestamp)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded),
                        onTap: () {
                          // Whenever tapped on the Device tile, it navigates to the
                          // chatpage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                converser: conversersFiltre[index],
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
  }
}
