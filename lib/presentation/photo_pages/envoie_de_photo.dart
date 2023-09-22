import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../global/global.dart';
import '../../modeles/messages_model.dart';
import '../../global/utils/p2p/adhoc_housekeeping.dart';
import '../../global/utils/fonctions.dart';

// TODO faire de faux device et de fausse conversatuon pour continué
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
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // TODO mettre le widget de recherche

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
      ),
    );
  }
}
