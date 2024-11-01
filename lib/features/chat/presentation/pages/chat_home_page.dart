import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'chat_device_around_list_page.dart';
import 'chat_known_list_page.dart';

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
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
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
          
          toolbarHeight: 40,
          bottom: TabBar(
            tabs: myTabs,
            controller: _tabController,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            ChatDeviceAroundList(
              deviceType: DeviceType.browser,
            ),
            ChatKnownListPage(),
          ],
        ),
      ),
    );
  }
}
