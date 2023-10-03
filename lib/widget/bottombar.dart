import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/presentation/calendar_pages/calendar_viewing_page.dart';
import 'package:flutter_application_1/presentation/photo_pages/camera_page.dart';
import 'package:flutter_application_1/presentation/menu_page.dart';
import 'package:go_router/go_router.dart';
import '../presentation/chat/chat_home_page.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  // TODO voir la camera si on la passe en provider
  //late CameraController _controller;
  late Future<void> initialiseControllerFuture;

  final User _utilisateur = FirebaseAuth.instance.currentUser!;
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

  Widget _pages2() {
    switch (_selectedIndex) {
      case 0:
        return MenuPage();
      case 1:
        return CameraPage(
          cameras: cameras,
        );
      case 2:
        return const ChatHomeScreen();
      default:
        return const CalendarViewingPage();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _selectedIndex == 0 ? myAppBar2() : justBottomBar();
  }

  Widget justBottomBar() {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: buildBottomBar(context),
    );
  }

// appbar custom
  Widget myAppBar2() {
    return Scaffold(
      body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                floating: true,
                snap: true,
                leadingWidth: 100,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black,
                        child: IconButton(
                            color: Colors.white,
                            icon: const Icon(Icons.account_circle_outlined),
                            onPressed: () {
                              // Obtenir une référence à l'instance de GoRouter
                              final router = GoRouter.of(context);
                              // Naviguer vers la page des paramètres
                              router.push('/parameter');
                            }),
                      ),
                      Text(
                        _utilisateur.displayName!,
                        style: const TextStyle(color: Colors.black),
                      )
                    ],
                  ),
                ),

                actions: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: IconButton(
                        icon: Icon(
                          Icons.zoom_in_map_rounded,
                        ),
                        onPressed: null,
                      ),
                    ),
                  ),
                ],
                //c'est cool si pas centrer
                centerTitle: true,
              ),
            ];
          },
          body: _pages2()),
      bottomNavigationBar: buildBottomBar(context),
    );
  }

  Widget buildBottomBar(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      height: 70,
      child: Wrap(children: [
        BottomNavigationBar(
          elevation: 0,
          showSelectedLabels: false,
          showUnselectedLabels: false,
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
        ),
      ]),
    );
  }
}
