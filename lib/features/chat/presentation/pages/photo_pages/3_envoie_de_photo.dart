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
                SliverAppBar(
                  floating: true,
                  snap: true,
                  title: const Text("Envoie de photo"),
                  //c'est cool si pas centrer
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
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Text("Les paires connus"),
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
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Text("Les paires approximités"),
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

              var msgId = nanoid(21);
              var timestamp = DateTime.now();
              var listImages = [widget.cheminVersImagePrise].join(',');

              ChatMessageParams chatMessageParams = ChatMessageParams(
                msgId,
                'bob',
                device.deviceId,
                '',
                listImages,
                'Pitcure_taken',
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
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final Device deviceCo = chatProvider.devices.firstWhere((element) => element.deviceName == device.deviceName);

    return Column(
      children: [
        ListTile(
          title: Text(deviceCo.deviceName),
          subtitle: Text(
            getStateName(deviceCo.state),
            style: TextStyle(color: getStateColor(deviceCo.state)),
          ),
          onTap: () async {
            if (deviceCo.state == SessionState.notConnected) {
              await chatProvider.connectToDevice(deviceCo);
            }
            onDeviceSelected(deviceCo);
          },
          trailing: SizedBox(
            width: 100,
            child: Row(
              children: [
                ConnectionButton(
                  device: deviceCo,
                  longDistance: false,
                ),
                RoundCheckbox(
                  value: isSelected,
                  onChanged: (value) {
                    onDeviceSelected(deviceCo);
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
