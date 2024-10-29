import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:provider/provider.dart';
import '../../../../../core/utils/p2p/p2p_utils.dart';
import '../../providers/chat_provider.dart';

class ConnectionButton extends StatelessWidget {
  const ConnectionButton({super.key, required this.device, required this.longDistance, this.aditionalFunction});
  final Device device;
  final bool longDistance;
  final Function()? aditionalFunction;

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    return GestureDetector(
      // to connect/disconnect with any device
      onTap: () async {
        if (aditionalFunction != null) aditionalFunction!();
        await chatProvider.connectToDevice(device);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
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
