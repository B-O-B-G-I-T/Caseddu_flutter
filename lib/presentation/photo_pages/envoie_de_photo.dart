import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/databasehelper.dart';
import 'package:flutter_application_1/global/payload.dart';
import 'package:go_router/go_router.dart';
import 'package:nanoid/nanoid.dart';
import 'package:provider/provider.dart';
import '../../global/global.dart';
import '../../modeles/messages_model.dart';
import '../../global/utils/p2p/adhoc_housekeeping.dart';
import '../../global/utils/fonctions.dart';
import '../../widget/P2P_widget/search_widget.dart';

// TODO faire de faux device et de fausse conversation pour continué
class EnvoieDePhotoPage extends StatefulWidget {
  const EnvoieDePhotoPage({super.key, required this.cheminVersImagePrise});
  final String cheminVersImagePrise;
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
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              leadingWidth: 20,
              floating: true,
              snap: true,
              title: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: SearchWidget(
                  onChanged: (String value) {},
                  searchController: _searchController,
                ),
              ),
              //c'est cool si pas centrer
              centerTitle: true,
            ),
          ];
        },
        body: SafeArea(
          child: SingleChildScrollView(
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

                  physics: const NeverScrollableScrollPhysics(),
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
                              ////
                              Utils.envoieDePhoto(
                                  destinataire: device.deviceName,
                                  chemin: widget.cheminVersImagePrise,
                                  context: context);
                              context.push('/');
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
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(conversers[index]),
                        subtitle: Text(Utils.depuisQuandCeMessageEstRecu(
                            timeStamp: lastMessage[index].timestamp)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded),
                        onTap: () {
                          ////
                          ///
                          Utils.envoieDeMessage(
                              destinataire: conversers[index],
                              message: widget.cheminVersImagePrise,
                              context: context);
                          context.push('/');
                        },
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
