import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:provider/provider.dart';

import '../../../../../core/utils/p2p/p2p_utils.dart';
import '../../providers/chat_provider.dart';

class ConnectionButton extends StatelessWidget {
  ConnectionButton({super.key, required this.device, required this.longDistance});
  final Device device;
  final bool longDistance;

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    return longDistance
        ? Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey,
            ),
            width: 50,
            child: const Center(
              child: Icon(Icons.phonelink_erase_rounded),
            ),
          )
        : GestureDetector(
            // to connect/disconnect with any device
            onTap: () async {
              await chatProvider.connectToDevice(device);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: getButtonColor(device.state),
              ),
              width: 50,
              child: Center(
                child: getButtonStateIcon(device.state),
              ),
            ),
          );
  }
}
