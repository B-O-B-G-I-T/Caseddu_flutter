import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../global/global.dart';
import '../../p2p/adhoc_housekeeping.dart';
import 'chat_page.dart';

enum DeviceType { advertiser, browser }

class DevicesListPage extends StatefulWidget {
  const DevicesListPage({super.key, required this.deviceType});

  final DeviceType deviceType;

  @override
  State<DevicesListPage> createState() => _DevicesListPage();
}

class _DevicesListPage extends State<DevicesListPage> {
  bool isInit = false;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.all(8),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.shade100)),
                ),
              ),
            ),

            // liste des devices
            ListView.builder(
              // Builds a screen with list of devices in the proximity
              itemCount: Provider.of<Global>(context).devices.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                // Getting a device from the provider
                final device = Provider.of<Global>(context).devices[index];
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(device.deviceName),
                        subtitle: Text(
                          getStateName(device.state),
                          style: TextStyle(color: getStateColor(device.state)),
                        ),

                        // gere la connection et la deconnexion
                        trailing: GestureDetector(
                          // GestureDetector act as onPressed() and enables
                          // to connect/disconnect with any device
                          onTap: () => connectToDevice(device),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            padding: const EdgeInsets.all(8.0),
                            height: 35,
                            width: 100,
                            color: getButtonColor(device.state),
                            child: Center(
                              child: Text(
                                getButtonStateName(device.state),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          // a modifé avec une route 
                          // On clicking any device tile, we navigate to the
                          // ChatPage.
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return ChatPage(
                                  converser: device.deviceName,

                                );
                              },
                            ),
                          );
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
          ],
        ),
      
    );
  }
}
