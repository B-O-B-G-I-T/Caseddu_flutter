import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/p2p/fonctions.dart';
import '../providers/chat_provider.dart';
import '../widgets/P2P_widgets/connection_button.dart';
import '../widgets/P2P_widgets/search_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/chat_widgets/page_chat/chat_circle_avatar.dart';

enum DeviceType { advertiser, browser }

class ChatDeviceAroundList extends StatefulWidget {
  const ChatDeviceAroundList({super.key, required this.deviceType});
  final DeviceType deviceType;

  @override
  State<ChatDeviceAroundList> createState() => _ChatDeviceAroundList();
}

class _ChatDeviceAroundList extends State<ChatDeviceAroundList> {
  late ChatProvider chatProvider;
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
    super.key,
    required this.devices,
    required this.onDeviceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: devices.isEmpty
          ? Center(
              child: Text(
                AppLocalizations.of(context)!.no_nearby_users,
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
                        leading: Stack(
                          children: [
                            ChatCircleAvatar(
                              text: device.deviceName, // Utilisez le premier caractère du nom comme texte
                              context: context,
                            ),
                            // je pense innutilecar redondant pour l'utilisateur
                            // Positioned(
                            //   bottom: 0,
                            //   right: 0,
                            //   child: Container(
                            //     padding: const EdgeInsets.all(2),
                            //     decoration: BoxDecoration(
                            //       color: getStateColor(device.state),
                            //       shape: BoxShape.circle,
                            //     ),
                            //     child: Text(
                            //       getStateName(device.state, context)[0],
                            //       style: const TextStyle(
                            //         fontSize: 10,
                            //         color: Colors.white,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                        title: Text(device.deviceName),
                        subtitle: Text(
                          device.deviceDescription?.isEmpty ?? true ? "" : device.deviceDescription!,
                        ),
                        trailing: ConnectionButton(device: device),
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
