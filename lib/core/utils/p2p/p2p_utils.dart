// Get the state name of the connection
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

String getStateName(SessionState state) {
  switch (state) {
    case SessionState.notConnected:
      return "Disconnected";
    case SessionState.connecting:
      return "Waiting";
    default:
      return "Connected";
  }
}

// Get the button state name of the connection
String getButtonStateName(Device device) {
  switch (device.state) {
    case SessionState.notConnected:
      return "Connect";

    case SessionState.connecting:
      return "Connecting";
    default:
      return "Disconnect";
  }
}

// Get the button state name of the connection
Widget getButtonStateIcon(SessionState state) {
  switch (state) {
    case SessionState.notConnected:
      return const Icon(Icons.connect_without_contact);
    case SessionState.connecting:
      return const Icon(Icons.hourglass_top_rounded);
    default:
      return const Icon(Icons.wifi_off_outlined);
  }
}

// Get the state colour of the connection
Color getStateColor(SessionState state) {
  switch (state) {
    case SessionState.notConnected:
      return Colors.black;
    case SessionState.connecting:
      return Colors.grey;
    default:
      return Colors.green;
  }
}

// Get the button state colour of the connection
Color getButtonColor(SessionState state) {
  switch (state) {
    case SessionState.notConnected:
      return Colors.green;

    case SessionState.connecting:
      return Colors.yellow;
    default:
      return Colors.red;
  }
}


