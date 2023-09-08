import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/pages/calendar_pages/calendar_viewing_page.dart';
import 'package:flutter_application_1/pages/camera_page.dart';
import 'package:flutter_application_1/pages/menu_page.dart';
import 'package:flutter_application_1/widget/appBar.dart';

import '../pages/chat/chat_home_page.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0; //New
  // TODO voir la camera si on la passe en provider 
  //late CameraController _controller;
  late Future<void> initialiseControllerFuture;

  @override
  void initState() {
    super.initState();
  }

  

  static final List<Widget> _pages = <Widget>[
    MenuPage(),
    CameraPage(
      cameras: cameras,
    ),
    const ChatHomeScreen(),
    const CalendarViewingPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: buildBottomBar(context),
    );
  }

  Widget buildBottomBar(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_border_sharp),
          label: 'Calls',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera),
          label: 'Camera',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Calendrier',
        ),
      ],
      currentIndex: _selectedIndex, //New
      onTap: _onItemTapped,
    );
  }
}
