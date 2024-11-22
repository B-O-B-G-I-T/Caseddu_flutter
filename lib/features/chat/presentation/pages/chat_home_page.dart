import 'package:flutter/material.dart';
import 'chat_device_around_list_page.dart';
import 'chat_known_list_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> with SingleTickerProviderStateMixin {
  bool isLoading = false;
  late TabController _tabController;
  late List<Tab> myTabs;

  /// After reading all the cache, the home screen becomes visible.
  Future refreshMessages() async {
    setState(() => isLoading = true);

    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    myTabs = <Tab>[
      Tab(
        text: AppLocalizations.of(context)!.devices_tab,
      ),
      Tab(
        text: AppLocalizations.of(context)!.all_chats_tab,
      ),
    ];
    _tabController = TabController(vsync: this, length: myTabs.length);
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
