// Get the state name of the connection
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String getStateName(SessionState state, BuildContext context) {
  switch (state) {
    case SessionState.connected:
      return AppLocalizations.of(context)!.connected;
    case SessionState.connecting:
      return AppLocalizations.of(context)!.waiting;
    case SessionState.tooFar:
      return AppLocalizations.of(context)!.too_far;
    default:
      return AppLocalizations.of(context)!.disconnected;
  }
}

// Get the button state name of the connection
String getButtonStateName(Device device, BuildContext context) {
  switch (device.state) {
    case SessionState.connected:
      return AppLocalizations.of(context)!.disconnected;
    case SessionState.connecting:
      return AppLocalizations.of(context)!.connecting;
    case SessionState.tooFar:
      return AppLocalizations.of(context)!.too_far;
    default:
      return AppLocalizations.of(context)!.connect;
  }
}

// Get the button state name of the connection
Widget getButtonStateIcon(SessionState state) {
  switch (state) {
    case SessionState.connected:
      return const Icon(
        Icons.wifi_off_outlined,
        color: Colors.black,
      );
    case SessionState.connecting:
      return const Icon(
        Icons.hourglass_top_rounded,
        color: Colors.black,
      );
    case SessionState.tooFar:
      return const Icon(
        Icons.phonelink_erase_rounded,
        color: Colors.black,
      );
    default:
      return const Icon(
        Icons.connect_without_contact,
        color: Colors.black,
      );
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
      return Colors.red;
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
