import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:go_router/go_router.dart';
import 'package:nanoid/nanoid.dart';
import 'package:provider/provider.dart';
import '../../../../../core/params/params.dart';
import '../../../../../core/utils/p2p/p2p_utils.dart';
import '../../../../../core/utils/p2p/fonctions.dart';
import '../../../data/models/chat_message_model.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/P2P_widgets/connection_button.dart';
import '../../widgets/P2P_widgets/search_widget.dart';

class EnvoieDePhotoPage extends StatefulWidget {
  const EnvoieDePhotoPage({super.key, required this.pictureTaken});
  final String pictureTaken;
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
  void initState() {
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    super.initState();
  }

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
          conversers = chatProvider.users
              .map((e) {
                var device = deviceApproximite.firstWhere(
                  (d) => d.deviceName == e.name,
                  orElse: () => Device(e.name, e.name, SessionState.tooFar),
                );
                return device;
              })
              // ignore: unnecessary_null_comparison
              .where((device) => device != null)
              .toList();

          if (_searchController.text.isEmpty) {
            deviceApproximiteFilter = deviceApproximite;
            conversersFiltre = conversers;
          }

          lastMessage = chatProvider.users.map((e) => e.dernierMessage).toList();
          return NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  floating: true,
                  snap: true,
                  title: const Text("Envoie de photo"),
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
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
                  // les paires connus
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "Les paires connus",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  SelectionDesUser(
                    listDevice: conversersFiltre,
                    deviceSelectionne: deviceSelectionne,
                    onDeviceSelected: (selected) {
                      setState(() {});
                      if (selected.state != SessionState.connecting) {
                        onDeviceSelected(selected);
                      }
                    },
                  ),
                  // liste des devices approximités
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "Les paires approximités",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  SelectionDesUser(
                    listDevice: deviceApproximiteFilter,
                    deviceSelectionne: deviceSelectionne,
                    onDeviceSelected: (selected) {
                      setState(() {});
                      if (selected.state != SessionState.connecting) {
                        onDeviceSelected(selected);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // faire l'envoie un for s'est le plus simple
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() async {
            await connectAll();
            for (var device in deviceSelectionne) {
              // if (device.state == SessionState.notConnected) {
              //   Fluttertoast.showToast(
              //       msg: 'hors de portée',
              //       toastLength: Toast.LENGTH_LONG,
              //       gravity: ToastGravity.TOP,
              //       timeInSecForIosWeb: 10,
              //       backgroundColor: Colors.grey,
              //       fontSize: 16.0);
              // } else {

              final String msgId = nanoid(21);
              final DateTime timestamp = DateTime.now();
              final String listImages = [widget.pictureTaken].join(',');

              ChatMessageParams chatMessageParams = ChatMessageParams(
                msgId,
                'bob',
                device.deviceId,
                '',
                listImages,
                'pictureTaken',
                'send',
                timestamp,
              );
              await chatProvider.eitherFailureOrEnvoieDeMessage(chatMessageParams: chatMessageParams);
            }

            context.go('/firstPage/1');
          });
        },
        backgroundColor: deviceSelectionne.isNotEmpty ? Colors.red : Colors.transparent,
        elevation: 0,
        child: deviceSelectionne.isNotEmpty ? const Icon(Icons.done) : null,
      ),
    );
  }

  Future<void> connectAll() async {
    for (var device in deviceSelectionne) {
      if (device.state == SessionState.notConnected) {
        await chatProvider.connectToDevice(device);
      }
    }
    return;
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
    super.key,
    required this.listDevice,
    required this.deviceSelectionne,
    required this.onDeviceSelected,
  });

  final List<Device> listDevice;
  final List<Device> deviceSelectionne;
  final Function(Device) onDeviceSelected;

  @override
  Widget build(BuildContext context) {
    if (listDevice.isEmpty) {
      // Retourner un Container vide ou un message si la liste est vide
      return const NoDevice();
    }
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      // Builds a screen with list of devices in the proximity
      itemCount: listDevice.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        // Getting a device from the provider
        final device = listDevice[index];
        final isSelected = deviceSelectionne.where((element) => element.deviceName == device.deviceName).isNotEmpty;
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
    super.key,
    required this.device,
    required this.isSelected,
    required this.onDeviceSelected,
  });

  final Device device;
  final bool isSelected;
  final Function(Device) onDeviceSelected;

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    return Column(
      children: [
        ListTile(
          title: Text(device.deviceName),
          subtitle: Text(
            getStateName(device.state),
            style: TextStyle(color: getStateColor(device.state)),
          ),
          onTap: () async {
            if (device.state == SessionState.notConnected) {
              await chatProvider.connectToDevice(device);
            }
            onDeviceSelected(device);
          },
          trailing: SizedBox(
            width: 100,
            child: Row(
              children: [
                ConnectionButton(
                  device: device,
                  longDistance: false,
                ),
                RoundCheckbox(
                  value: isSelected,
                  onChanged: (value) {
                    onDeviceSelected(device);
                  },
                ),
              ],
            ),
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

class NoDevice extends StatelessWidget {
  const NoDevice({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        'Aucun appareil disponible',
      ),
    );
  }
}
