// ignore_for_file: use_build_context_synchronously
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({Key? key}) : super(key: key);

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  Future<void> finishTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenTutorial', true);
    context.go('/firstPage/0');
  }

  @override
  Widget build(BuildContext context) {
    // Liste des pages du tutoriel
    final List<Map<String, dynamic>> pages = [
      {
        "title": AppLocalizations.of(context)!.welcome_title,
        "body": AppLocalizations.of(context)!.welcome_body,
        "image": "assets/image_for_tutorial/tutorial_1.png",
        "color": Colors.amber,
      },
      {
        "title": AppLocalizations.of(context)!.geo_title,
        "body": AppLocalizations.of(context)!.geo_body,
        "image": "assets/image_for_tutorial/tutorial_2.png",
        "color": Colors.indigo,
      },
      {
        "title": AppLocalizations.of(context)!.p2p_title,
        "body": AppLocalizations.of(context)!.p2p_body,
        "image": "assets/image_for_tutorial/tutorial_3.png",
        "color": Colors.green,
      },
      {
        "title": AppLocalizations.of(context)!.social_title,
        "body": AppLocalizations.of(context)!.social_body,
        "image": "assets/image_for_tutorial/tutorial_4.png",
        "color": Colors.purple,
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
          // PageView pour afficher les pages
          PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final page = pages[index];
              return Container(
                color: page['color'],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        page['image'],
                        height: 400,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      page['title'],
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: "AbrilFatface_regular",
                            fontStyle: FontStyle.italic,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        page['body'],
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.white,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Indicateurs de page cliquables
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => GestureDetector(
                  onTap: () {
                    // Aller directement à la page correspondante
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 12 : 8,
                    height: _currentIndex == index ? 12 : 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index ? Colors.white : Colors.white54,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Boutons de navigation (Passer et Terminer)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Afficher "Passer" uniquement si ce n'est pas la dernière page
                if (_currentIndex < pages.length - 1)
                  TextButton(
                    onPressed: () => finishTutorial(),
                    child: const Text(
                      "Passer",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                // Afficher le bouton "Terminer" à droite uniquement sur la dernière page
                if (_currentIndex == pages.length - 1)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => finishTutorial(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("Terminer"),
                      ),
                    ),
                  ),

                // Flèche pour aller à la page suivante (si ce n'est pas la dernière page)
                if (_currentIndex < pages.length - 1)
                  IconButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
