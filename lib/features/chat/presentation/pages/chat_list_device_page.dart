import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/p2p/fonctions.dart';
import '../../../../core/utils/p2p/p2p_utils.dart';
import '../providers/chat_provider.dart';
import '../widgets/P2P_widget/search_widget.dart';
import 'chat_page.dart';

enum DeviceType { advertiser, browser }

class DevicesListPage extends StatefulWidget {
  const DevicesListPage({Key? key, required this.deviceType}) : super(key: key);
  final DeviceType deviceType;

  @override
  State<DevicesListPage> createState() => _DevicesListPage();
}

class _DevicesListPage extends State<DevicesListPage> {
  late ChatProvider chatProvider;
  final TextEditingController _searchController = TextEditingController();
  List<Device> deviceApproximite = [];
  List<Device> deviceApproximiteFilter = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        deviceApproximite = chatProvider.devices;
        if (_searchController.text.isEmpty) {
          deviceApproximiteFilter = deviceApproximite;
        }
        return Column(
          children: [
            SearchWidget(
              onChanged: (value) {
                setState(() {
                  deviceApproximiteFilter = Utils.runFilter(value, deviceApproximite, (device) => device.deviceName);
                });
              },
              searchController: _searchController,
            ),
            // user de test d'affichage
            MaterialButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ChatPage(converser: "testChatPage"),
                  ),
                );
              },
              child: const Text("test chatPage"),
            ),
            DevicesListWidget(
              devices: deviceApproximiteFilter,
              onDeviceTap: (device) {
                chatProvider.connectToDevice(device);
              },
            ),
          ],
        );
      },
    );
  }
}

class DevicesListWidget extends StatelessWidget {
  final List<Device> devices;
  final Function(Device) onDeviceTap;

  const DevicesListWidget({
    Key? key,
    required this.devices,
    required this.onDeviceTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: devices.isEmpty
          ? const Center(
              child: Text(
                "Personne à proximité avec l'app,\nfait diffuser l'app aux non initié.\n Agrandi ton cercle.",
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: devices.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final device = devices[index];
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
                        trailing: GestureDetector(
                          onTap: () => onDeviceTap(device),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            padding: const EdgeInsets.all(8.0),
                            height: 35,
                            width: 100,
                            color: getButtonColor(device.state),
                            child: Center(
                              child: Text(
                                getButtonStateName(device),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
    );
  }
}
