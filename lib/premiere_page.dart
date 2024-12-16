// ignore_for_file: use_build_context_synchronously

import 'package:caseddu/features/parameter/presentation/providers/parameter_provider.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'features/chat/presentation/pages/chat_home_page.dart';
import 'features/chat/presentation/pages/photo_pages/1_camera_page.dart';
import 'features/chat/presentation/providers/chat_provider.dart';
import 'features/parameter/presentation/widgets/custom_circle_avatar.dart';
import 'main.dart';

class PremierePage extends StatefulWidget {
  final int selectedIndex;

  const PremierePage({super.key, required this.selectedIndex});

  @override
  State<PremierePage> createState() => _PremierePageState();
}

class _PremierePageState extends State<PremierePage> {
  int _selectedIndex = 0;

  late ChatProvider chatProvider;
  late ParameterProvider parameterProvider;
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;

    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    // Écoute des nouveaux messages pour faire défiler vers le bas
    chatProvider.setupInvitationHandler(context);
    chatProvider.invitationController.listen((newMessage) {
      chatProvider.setupInvitationHandler(context);
    });

    parameterProvider = Provider.of<ParameterProvider>(context, listen: false);
  }

// dictionnaire des pages /////////////////////////////
  static final List<Widget> _pages = <Widget>[
    CameraPage(
      cameras: cameras,
    ),
    const ChatHomeScreen(),
  ];

// fonction qui met à jour l'index de la page
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // return _selectedIndex == 0 ? myAppBar() : justBottomBar();
    return Scaffold(
      // AppBar personnalisé transparent
      body: Stack(
        children: [
          // IndexedStack est la première couche (en dessous de l'AppBar)
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          // AppBar transparent en haut
          myAppBar(),
        ],
      ),
      bottomNavigationBar: buildBottomBar(context), // Barre de navigation en bas
    );
  }

// bottom bar custom
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
  Widget myAppBar() {
    return Consumer<ParameterProvider>(builder: (context, provider, child) {
      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: PreferredSize(
          preferredSize: const Size.fromHeight(20.0), // hauteur personnalisée de l'AppBar
          child: AppBar(
            backgroundColor: Colors.transparent,
            leadingWidth: 100,
            leading: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
              child: Row(
                children: [
                  // Image de profil ou texte
                  CustomCircleAvatar(
                    radius: 20,
                    image: parameterProvider.parameter.pathImageProfile,
                    ontap: () async {
                      // Obtenir une référence à l'instance de GoRouter
                      final router = GoRouter.of(context);
                      // Naviguer vers la page des paramètres
                      router.push('/parameter');
                    },
                  ),

                  Expanded(
                    child: Text(
                      parameterProvider.parameter.displayName,
                      style: const TextStyle(color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),

            actions: [
              Selector<ChatProvider, int>(
              selector: (context, provider) => provider.devices.length,
              builder: (BuildContext context, int deviceCount, Widget? child) {
                return Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black,
                  child: Text(
                  deviceCount.toString(),
                  style: ThemeData().textTheme.bodyLarge!.copyWith(color: Colors.white),
                  ),
                ),
                );
              },
              ),
            ],
            //c'est cool si pas centrer
            centerTitle: true,
          ),
        ),
      );
    });
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
              icon: Icon(Icons.camera),
              label: 'Camera',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chats',
            ),
          ],
          currentIndex: _selectedIndex, //New
          onTap: _onItemTapped,
        ),
      ]),
    );
  }
}
