import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../database/messages_database.dart';
import '../../global/global.dart';
import '../../modeles/messages_model.dart';
import '../../p2p/adhoc_housekeeping.dart';
import '../../utils/fonctions.dart';

class EnvoieDePhotoPage extends StatefulWidget {
  const EnvoieDePhotoPage({super.key, required String cheminVersImagePrise});

  @override
  State<EnvoieDePhotoPage> createState() => _EnvoieDePhotoPageState();
}

class _EnvoieDePhotoPageState extends State<EnvoieDePhotoPage> {
  List<String> conversers = [];
  @override
  Widget build(BuildContext context) {
    conversers = [];
    //List<Device> devices = [];
    List<Msg> lastMessage = [];

    Provider.of<Global>(context).conversations.forEach((key, value) {
      conversers.add(key);

      lastMessage
          .add(Provider.of<Global>(context).conversations[key]!.values.last);
    });
    return SingleChildScrollView(
      child: Column(
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

          // liste des devices approximités
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text("Les paires approximités"),
          ),
          ListView.builder(
            // Builds a screen with list of devices in the proximity
            itemCount: Provider.of<Global>(context).devices.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              // Getting a device from the provider
              final device = Provider.of<Global>(context).devices[index];
              return Container(
                margin: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(device.deviceName),
                      subtitle: Text(
                        getStateName(device.state),
                        style: TextStyle(color: getStateColor(device.state)),
                      ),
                      onTap: () {
                        context.push('/ChatPage/${device.deviceName}');
                      },
                    ),
                    
                    const Divider(
                      height: 1,
                      color: Colors.grey,
                    ),
                  ],
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text("Les paires connus"),
          ),
          ListView.builder(
              itemCount: conversers.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(conversers[index]),
                  subtitle: Text(Utils.depuisQuandCeMessageEstRecu(
                      timeStamp: lastMessage[index].timestamp)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {},
                );
              }),
        ],
      ),
    );
  }
}
