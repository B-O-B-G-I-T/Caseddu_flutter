import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'chat_list_device_page.dart';
import 'liste_des_chats.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> with SingleTickerProviderStateMixin {
  static const List<Tab> myTabs = <Tab>[
    Tab(
      text: "Devices",
    ),
    Tab(
      text: "All Chats",
    ),
  ];

  bool isLoading = false;
  late TabController _tabController;

  /// After reading all the cache, the home screen becomes visible.
  Future refreshMessages() async {
    setState(() => isLoading = true);

    setState(() => isLoading = false);
  }

  late ChatProvider chatProvider;
  @override
  void initState() {
    super.initState();

    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    //chatProvider.eitherFailureOrInit();
    _tabController = TabController(vsync: this, length: myTabs.length);
    // init(context);
    // refreshMessages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // readAllUpdateConversation(context);
    // init(context);
  }

  /// When the messaging is done, the services
  /// or the subscrption needs to be closed
  /// Hence the deviceSubscription stream is cancelled.
  /// Also the nearby services are stopped.
  @override
  void dispose() {
    //Global.deviceSubscription!.cancel();
    //Global.receivedDataSubscription!.cancel();
    //Global.nearbyService!.stopBrowsingForPeers();
    //Global.nearbyService!.stopAdvertisingPeer();

    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // key: Global.scaffoldKey,
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: TabBar(
            tabs: myTabs,
            controller: _tabController,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            DevicesListPage(
              deviceType: DeviceType.browser,
            ),
            ListeDesChatsPage(),
          ],
        ),
      ),
    );
  }
}
