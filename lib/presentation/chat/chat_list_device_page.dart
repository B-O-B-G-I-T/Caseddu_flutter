import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../global/global.dart';
import '../../global/utils/p2p/adhoc_housekeeping.dart';
import '../../widget/P2P_widget/search_widget.dart';
import 'chat_page.dart';

enum DeviceType { advertiser, browser }

class DevicesListPage extends StatefulWidget {
  const DevicesListPage({super.key, required this.deviceType});

  final DeviceType deviceType;

  @override
  State<DevicesListPage> createState() => _DevicesListPage();
}

class _DevicesListPage extends State<DevicesListPage> {
  bool isInit = false;
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  List<Device> deviceApproximite = [];
  List<Device> deviceApproximiteFilter = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // charge les devices à coté
    deviceApproximite = Provider.of<Global>(context).devices;
    deviceApproximiteFilter = deviceApproximite;
  }

  void _runFilter(String enteredKeyword) {
    List<Device> results = [];
    if (enteredKeyword.isEmpty) {
      results = deviceApproximite;
    } else {
      results = deviceApproximite
          .where((user) => user.deviceName
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      deviceApproximiteFilter = results;
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

        // chat de test a supprimer
        MaterialButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const ChatPage(
                      converser: "testChatPage",
                    );
                  },
                ),
              );
            },
            child: const Text("test chatPage")),
        // liste des devices
        Expanded(
          child: deviceApproximiteFilter.isEmpty
              ? const Center(
                  child: Text(
                    "Personne à proximité avec l'app,\nfait diffuser l'app aux non initié.\n Agrandi ton cercle.",
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  // Builds a screen with list of devices in the proximity
                  itemCount: deviceApproximiteFilter.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    // Getting a device from the provider
                    final device = deviceApproximiteFilter[index];
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

                            // gere la connection et la deconnexion
                            trailing: GestureDetector(
                              // GestureDetector act as onPressed() and enables
                              // to connect/disconnect with any device
                              onTap: () => connectToDevice(device),
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                padding: const EdgeInsets.all(8.0),
                                height: 35,
                                width: 100,
                                color: getButtonColor(device.state),
                                child: Center(
                                  child: Text(
                                    getButtonStateName(device),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
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
        ),
      ],
    );
  }
}
