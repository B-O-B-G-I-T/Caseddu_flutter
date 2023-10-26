import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:provider/provider.dart';
import '../../../../../core/utils/p2p/p2p_utils.dart';
import '../../../../../core/utils/p2p/fonctions.dart';
import '../../../data/models/chat_message_model.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/P2P_widget/search_widget.dart';

class EnvoieDePhotoPage extends StatefulWidget {
  const EnvoieDePhotoPage({super.key, required this.cheminVersImagePrise});
  final String cheminVersImagePrise;
  @override
  State<EnvoieDePhotoPage> createState() => _EnvoieDePhotoPageState();
}

class _EnvoieDePhotoPageState extends State<EnvoieDePhotoPage> {
  List<Device> deviceApproximite = [];
  List<Device> deviceApproximiteFilter = [];

  List<Device> conversers = [];
  List<Device> conversersFiltre = [];
  List<ChatMessageModel?> lastMessage = [];

   List<Device> deviceSelectionne = [];

  final TextEditingController _searchController = TextEditingController();
  late ChatProvider chatProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          deviceApproximite = chatProvider.devices;
          conversers = chatProvider.users.map((e) => Device(e.id, e.name, 0)).toList();

          if (_searchController.text.isEmpty) {
            deviceApproximiteFilter = deviceApproximite;
            conversersFiltre = conversers;
          }

          lastMessage = chatProvider.users.map((e) => e.dernierMessage).toList();
          return NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                const SliverAppBar(
                  leadingWidth: 0,
                  floating: true,
                  snap: true,
                  title: Text("Envoie de photo"),
                  //c'est cool si pas centrer
                  centerTitle: true,
                ),
              ];
            },
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SearchWidget(
                    onChanged: (value) {
                      setState(() {
                        deviceApproximiteFilter = Utils.runFilter(value, deviceApproximite, (device) => device.deviceName);
                        conversersFiltre = Utils.runFilter(value, conversers, (device) => device.deviceName);
                      });
                    },
                    searchController: _searchController,
                  ),

                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Text("Les paires connus"),
                  ),
                  SelectionDesUser(
                    listDevice: conversersFiltre,
                    deviceSelectionne: deviceSelectionne,
                    onDeviceSelected: (selected) {
                      setState(() {
                        onDeviceSelected(selected);
                      });
                    },
                  ),
                  // ListView.builder(
                  //     itemCount: conversers.length,
                  //     physics: const NeverScrollableScrollPhysics(),
                  //     shrinkWrap: true,
                  //     itemBuilder: (context, index) {
                  //       // widget qui sont les cases pour afficher un utilisateur
                  //       return ListTilePourUtilisateurConnu(
                  //           deviceName: conversersFiltre[index].deviceName,
                  //           message: lastMessage[index]!.message,
                  //           timestamp: lastMessage[index]!.timestamp.toString(),
                  //           onTap: () {
                  //             onDeviceSelected(conversersFiltre[index]);
                  //           });
                  //     }),
                  // liste des devices approximités
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Text("Les paires approximités"),
                  ),
                  SelectionDesUser(
                    listDevice: deviceApproximiteFilter,
                    deviceSelectionne: deviceSelectionne,
                    onDeviceSelected: (selected) {
                      setState(() {
                        onDeviceSelected(selected);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // faire l'envoie un for s'est le plus simple
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print(deviceSelectionne);
        },
        child: const Icon(Icons.done),
      ),
    );
  }

  void onDeviceSelected(Device selected) {
    setState(() {
      final existed = deviceSelectionne.where((element) => element.deviceId == selected.deviceId);
      if (existed.isEmpty) {
        deviceSelectionne.add(selected);
        //print(deviceSelectionne);
      } else {
        deviceSelectionne.removeWhere((element) => element.deviceId == selected.deviceId);
        //print(deviceSelectionne);
      }
    });
  }
}

class SelectionDesUser extends StatelessWidget {
  const SelectionDesUser({
    Key? key,
    required this.listDevice,
    required this.deviceSelectionne,
    required this.onDeviceSelected,
  }) : super(key: key);

  final List<Device> listDevice;
  final List<Device> deviceSelectionne;
  final Function(Device) onDeviceSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Builds a screen with list of devices in the proximity
      itemCount: listDevice.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        // Getting a device from the provider
        final device = listDevice[index];
        final isSelected = deviceSelectionne.where((element) => element.deviceId == device.deviceId).isNotEmpty;
        return DeviceListItem(
          device: device,
          isSelected: isSelected,
          onDeviceSelected: onDeviceSelected,
        );
      },
    );
  }
}

class DeviceListItem extends StatelessWidget {
  const DeviceListItem({
    Key? key,
    required this.device,
    required this.isSelected,
    required this.onDeviceSelected,
  }) : super(key: key);

  final Device device;
  final bool isSelected;
  final Function(Device) onDeviceSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(device.deviceName),
          subtitle: Text(
            getStateName(device.state),
            style: TextStyle(color: getStateColor(device.state)),
          ),
          onTap: () {
            onDeviceSelected(device);
          },
          trailing: RoundCheckbox(
            value: isSelected,
            onChanged: (value) {
              onDeviceSelected(device);
            },
          ),
        ),
        const Divider(
          height: 1,
          color: Colors.grey,
        ),
      ],
    );
  }
}

class RoundCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const RoundCheckbox({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged!(!value);
      },
      child: Container(
        width: 24.0,
        height: 24.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
        ),
        child: Center(
          child: Container(
            width: 16.0,
            height: 16.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? Colors.black : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}
