import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BLuetoothController extends GetxController {
  FlutterBlue _flutterBlue = FlutterBlue.instance;

  Future scanAutour() async {
    await [
  Permission.bluetoothConnect,
  Permission.bluetoothScan,
  Permission.bluetoothAdvertise,
  ].request();
    // Start scanning
    _flutterBlue.startScan(timeout: Duration(seconds: 4));

// Listen to scan results
    var subscription = _flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
      }
    });

// Stop scanning
    _flutterBlue.stopScan();
  }

  Stream<List<ScanResult>> get scanResult => _flutterBlue.scanResults;
}
