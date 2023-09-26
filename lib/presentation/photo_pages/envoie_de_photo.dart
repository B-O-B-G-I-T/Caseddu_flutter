import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../global/global.dart';
import '../../modeles/messages_model.dart';
import '../../global/utils/p2p/adhoc_housekeeping.dart';
import '../../global/utils/fonctions.dart';
import '../../widget/P2P_widget/search_widget.dart';

// TODO faire de faux device et de fausse conversation pour continué
class EnvoieDePhotoPage extends StatefulWidget {
  const EnvoieDePhotoPage({super.key, required String cheminVersImagePrise});

  @override
  State<EnvoieDePhotoPage> createState() => _EnvoieDePhotoPageState();
}

class _EnvoieDePhotoPageState extends State<EnvoieDePhotoPage> {
  List<String> conversers = [];

  //List<Device> devices = [];
  List<Msg> lastMessage = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Provider.of<Global>(context).conversations.forEach((key, value) {
      conversers.add(key);

      lastMessage
          .add(Provider.of<Global>(context).conversations[key]!.values.last);
    });
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // TODO mettre le widget de recherche
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      context.pop();
                    },
                  ),
                  SearchWidget(
                    onChanged: (String value) {},
                    searchController: _searchController,
                  )
                ],
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
                            style:
                                TextStyle(color: getStateColor(device.state)),
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
      ),
    );
  }
}
