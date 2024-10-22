// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/designs/frosted_glass/frosted_glass.dart';
import 'package:pro_image_editor/designs/frosted_glass/frosted_glass_effect.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../background_buttons_widget.dart';

/// A custom action bar widget with a frosted glass effect, designed for use
/// within an image editing application. This widget provides an interface for
/// users to interact with the image editor and access the sticker editor
/// feature.
class mainPictureScreen extends StatefulWidget {
  /// Creates a [mainPictureScreen].
  ///
  /// The [editor] and [openStickerEditor] parameters are required to configure
  /// the action bar's behavior. The [editor] parameter provides access to the
  /// image editor's state, allowing the action bar to interact with and modify
  /// the image being edited. The [openStickerEditor] parameter is a callback
  /// function that opens the sticker editor when invoked.
  ///
  /// Example:
  /// ```
  /// mainPictureScreen(
  ///   editor: myEditorState,
  ///   openStickerEditor: () => myStickerEditorFunction(),
  /// )
  /// ```
  const mainPictureScreen({
    super.key,
    required this.editor,
    required this.openStickerEditor,
  });

  /// The configuration for the image editor.
  final ProImageEditorState editor;

  /// A callback function to open the sticker editor.
  ///
  /// This function is invoked when the user wishes to add or edit stickers
  /// on the image. The function should be defined in the parent widget and
  /// passed to this action bar to handle the opening of the sticker editor
  /// interface.
  final Function() openStickerEditor;

  @override
  State<mainPictureScreen> createState() => _mainPictureScreenState();
}

class _mainPictureScreenState extends State<mainPictureScreen> {
  final Color _foregroundColor = const Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Hero(
                tag: 'frosted-glass-close-btn',
                child: BackgroundButtonWidget(
                  child: IconButton(
                    tooltip: widget.editor.configs.i18n.cancel,
                    onPressed: widget.editor.closeEditor,
                    icon: const Icon(Icons.close),
                    color: _foregroundColor,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Hero(
                tag: 'frosted-glass-done-btn',
                child: BackgroundButtonWidget(
                  child: IconButton(
                    tooltip: widget.editor.configs.i18n.done,
                    onPressed: widget.editor.doneEditing,
                    icon: Icon(
                      Icons.check,
                      color: _foregroundColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (!widget.editor.isSubEditorOpen)
            Align(
              alignment: Alignment.bottomLeft,
              child: SingleChildScrollView(
                key: const PageStorageKey('frosted_glass_main_bottombar'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    BackgroundButtonWidget(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 3,
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          direction: Axis.vertical,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              transitionBuilder: (child, animation) {
                                // Utilisation d'une courbe d'animation plus douce
                                final curvedAnimation = CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeInOut, // Courbe d'animation plus naturelle
                                );
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.2),
                                    end: Offset.zero,
                                  ).animate(curvedAnimation),
                                  //scale: animation,
                                  child: FadeTransition(
                                    opacity: curvedAnimation,
                                    child: child,
                                  ),
                                );
                              },
                              child: widget.editor.canRedo
                                  ? IconButton(
                                      tooltip: widget.editor.configs.i18n.undo,
                                      onPressed: widget.editor.redoAction,
                                      icon: const Icon(Icons.redo),
                                    )
                                  : null,
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              transitionBuilder: (child, animation) {
                                // Utilisation d'une courbe d'animation plus douce
                                final curvedAnimation = CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeInOut, // Courbe d'animation plus naturelle
                                );
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.2),
                                    end: Offset.zero,
                                  ).animate(curvedAnimation),
                                  //scale: animation,
                                  child: FadeTransition(
                                    opacity: curvedAnimation,
                                    child: child,
                                  ),
                                );
                              },
                              child: widget.editor.canUndo
                                  ? IconButton(
                                      tooltip: widget.editor.configs.i18n.undo,
                                      onPressed: widget.editor.undoAction,
                                      icon: const Icon(Icons.undo),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    BackgroundButtonWidget(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 3,
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        direction: Axis.vertical,
                        children: [
                          if (widget.editor.configs.paintEditorConfigs.enabled)
                            IconButton(
                              tooltip: widget.editor.configs.i18n.paintEditor.bottomNavigationBarText,
                              onPressed: widget.editor.openPaintingEditor,
                              // ignore: prefer_const_constructors
                              icon: Icon(Icons.edit),
                            ),
                          if (widget.editor.configs.textEditorConfigs.enabled)
                            IconButton(
                              tooltip: widget.editor.configs.i18n.textEditor.bottomNavigationBarText,
                              onPressed: () => widget.editor.openTextEditor(
                                duration: const Duration(milliseconds: 150),
                              ),
                              icon: const Icon(Icons.title),
                            ),
                          if (widget.editor.configs.cropRotateEditorConfigs.enabled)
                            IconButton(
                              tooltip: widget.editor.configs.i18n.cropRotateEditor.bottomNavigationBarText,
                              onPressed: widget.editor.openCropRotateEditor,
                              icon: const Icon(Icons.crop_rotate),
                            ),
                          if (widget.editor.configs.filterEditorConfigs.enabled)
                            IconButton(
                              tooltip: widget.editor.configs.i18n.filterEditor.bottomNavigationBarText,
                              onPressed: widget.editor.openFilterEditor,
                              icon: const Icon(Icons.filter),
                            ),
                          if (widget.editor.configs.blurEditorConfigs.enabled)
                            IconButton(
                              tooltip: widget.editor.configs.i18n.blurEditor.bottomNavigationBarText,
                              onPressed: widget.editor.openBlurEditor,
                              icon: const Icon(Icons.blur_on),
                            ),
                          if (widget.editor.configs.stickerEditorConfigs?.enabled == true || widget.editor.configs.emojiEditorConfigs.enabled)
                            IconButton(
                              key: const ValueKey('whatsapp-open-sticker-editor-btn'),
                              tooltip: widget.editor.configs.i18n.stickerEditor.bottomNavigationBarText,
                              onPressed: widget.openStickerEditor,
                              icon: const Icon(Icons.sticky_note_2_rounded),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
