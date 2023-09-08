import 'package:flutter/material.dart';
import 'package:flutter_application_1/modeles/messages_model.dart';
import 'package:flutter_application_1/utils/fonctions.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../database/databasehelper.dart';
import '../../database/messages_database.dart';
import '../../global/global.dart';
import 'chat_page.dart';

class ListeDesChatsPage extends StatefulWidget {
  const ListeDesChatsPage({super.key});

  @override
  State<ListeDesChatsPage> createState() => _ListeDesChatsPage();
}

class _ListeDesChatsPage extends State<ListeDesChatsPage> {
  bool isLoading = false;
  List<String> conversers = [];
  // In the init state, we need to update the cache everytime.
  @override
  void initState() {
    super.initState();
    readAllUpdateCache();
  }

  @override
  Widget build(BuildContext context) {
    // Whenever the the UI is built, each converser is added to the list
    // from the conversations map that stores the key as name of the device.
    // The names are inserted into the list conversers here and then displayed
    // with the help of ListView.builder.
    conversers = [];
    //List<Device> devices = [];
    List<Msg> lastMessage = [];

    Provider.of<Global>(context).conversations.forEach((key, value) {
      conversers.add(key);

//peut etre supprimé
      // // Provider.of<Global>(context).devices.where(
      // //   (element) {
      // //     if (element.deviceName == key) {
      // //       devices.add(element);
      // //       return true;
      // //     }
      // //     return false;
      // //   },
      // // );

      // Provider.of<Global>(context).devices.forEach((device) {
      //   if (device.deviceName == key) {
      //     devices.add(device);
      //   }
      // });

      lastMessage
          .add(Provider.of<Global>(context).conversations[key]!.values.last);
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search...",
              hintStyle: TextStyle(color: Colors.grey.shade600),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade600,
                size: 20,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.all(8),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade100)),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: conversers.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(
                      "{$index.toString()} - ${DateTime.now().millisecondsSinceEpoch}"),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    // TODO: pour supprimé les convs supprimé dans les conversations de global qui ce gere avec le cache

                    MessageDB.instance.deleteFromConversationsByConverserTable(
                        conversers[index]);
                    Provider.of<Global>(context, listen: false)
                        .conversations
                        .remove(conversers[index]);
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
                    title: Text(conversers[index]),
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
                            converser: conversers[index],
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
