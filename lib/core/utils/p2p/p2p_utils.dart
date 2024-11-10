// Get the state name of the connection
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

String getStateName(SessionState state) {
  switch (state) {
    case SessionState.connected:
      return "Connected";
    case SessionState.connecting:
      return "Waiting";
    case SessionState.tooFar:
      return "Too far";
    default:
      return "Disconnected";
  }
}

// Get the button state name of the connection
String getButtonStateName(Device device) {
  switch (device.state) {
    case SessionState.connected:
      return "Disconnect";
    case SessionState.connecting:
      return "Connecting";
    case SessionState.tooFar:
      return "Too far";
    default:
      return "Connect";
  }
}

// Get the button state name of the connection
Widget getButtonStateIcon(SessionState state) {
  switch (state) {
    case SessionState.connected:
      return const Icon(Icons.wifi_off_outlined);
    case SessionState.connecting:
      return const Icon(
        Icons.hourglass_top_rounded,
        color: Colors.black,
      );
    case SessionState.tooFar:
      return const Icon(Icons.phonelink_erase_rounded);
    default:
      return const Icon(Icons.connect_without_contact);
  }
}

// Get the state colour of the connection
Color getStateColor(SessionState state) {
  switch (state) {
    case SessionState.connected:
      return Colors.green;
    case SessionState.connecting:
      return Colors.yellow;
    case SessionState.tooFar:
      return Colors.grey;
    default:
      return Colors.black;
  }
}

// Get the button state colour of the connection
Color getButtonColor(SessionState state) {
  switch (state) {
    case SessionState.connected:
      return Colors.red;
    case SessionState.connecting:
      return Colors.yellow;
    case SessionState.tooFar:
      return Colors.grey;
    default:
      return Colors.green;
  }
}
