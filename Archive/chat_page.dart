import 'package:flutter/material.dart';
import 'controller/bluetooth_controller.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';

@Deprecated('Cette classe est obsolète, utilisez la flutter_nearby à la place')
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<BLuetoothController>(
          init: BLuetoothController(),
          builder: (controller) {
            return SingleChildScrollView(
              child: Column(children: [
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.scanAutour();
                    },
                    child: Text("scan"),
                  ),
                ),
                StreamBuilder<List<ScanResult>>(
                    stream: controller.scanResult,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            final data = snapshot.data![index];
                            return Card(
                              child: ListTile(
                                title: Text(data.device.name),
                                subtitle: Text(data.device.id.id),
                                trailing: Text(data.rssi.toString()),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text("Personne trouvé autour de vous"),
                        );
                      }
                    }),
              ]),
            );
          }),
    );
  }
}
