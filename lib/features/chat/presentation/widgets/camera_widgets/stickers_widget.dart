import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class StickersWidget extends StatelessWidget {
  StickersWidget({
    super.key,
    required this.setLayer,
    required this.scrollController,
    this.categoryColor = const Color(0xFF424242),
  });
  final Function(Widget) setLayer;
  final ScrollController scrollController;
  final Color categoryColor;

  final List<String> demoTitles = [
    'Recent',
    'Favorites',
    'Shapes',
    'Funny',
    'Boring',
    'Frog',
    'Snow',
    'More'
  ];
  @override
  Widget build(BuildContext context) {
    List<Widget> slivers = [];
    int offset = 0;
    for (var element in demoTitles) {
      slivers.addAll([
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 4),
          sliver: SliverToBoxAdapter(
            child: Text(
              element,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        _buildDemoStickers(offset, setLayer),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ]);
      offset += 20;
    }

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
            child: CustomScrollView(
              controller: scrollController,
              slivers: slivers,
            ),
          ),
        ),
        Container(
          height: 50,
          color: categoryColor,
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.watch_later_outlined),
                color: Colors.white,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.mood),
                color: Colors.white,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.pets),
                color: Colors.white,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.coronavirus),
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }

  SliverGrid _buildDemoStickers(int offset, Function(Widget) setLayer) {
    return SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 80,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: max(3, 3 + offset % 6),
        itemBuilder: (context, index) {
          String url =
              'https://picsum.photos/id/${offset + (index + 3) * 3}/2000';
          var widget = ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.network(
              url,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                return AnimatedSwitcher(
                  layoutBuilder: (currentChild, previousChildren) {
                    return SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.center,
                        children: <Widget>[
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      ),
                    );
                  },
                  duration: const Duration(milliseconds: 200),
                  child: loadingProgress == null
                      ? child
                      : Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                );
              },
            ),
          );
          return GestureDetector(
            onTap: () async {
              // Important make sure the image is completely loaded
              // cuz the editor will directly take a screenshot
              // inside of a background isolated thread.
              LoadingDialog.instance.show(
                context,
                configs: const ProImageEditorConfigs(),
                theme: ThemeData.dark(),
              );

              await precacheImage(NetworkImage(url), context);
              LoadingDialog.instance.hide();
              setLayer(widget);
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: widget,
            ),
          );
        });
  }
}