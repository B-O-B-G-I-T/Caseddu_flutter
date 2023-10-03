import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

import '../../global/utils/p2p/adhoc_housekeeping.dart';

class ConnectionButton extends StatelessWidget {
  const ConnectionButton(
      {super.key, required this.device, required this.longDistance});
  final Device device;
  final bool longDistance;

  @override
  Widget build(BuildContext context) {
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
            // GestureDetector act as onPressed() and enables
            // to connect/disconnect with any device
            onTap: () {
              connectToDevice(device);
            },
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
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
