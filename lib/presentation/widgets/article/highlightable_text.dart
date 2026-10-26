import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/data/models/highlight_model.dart';
import 'package:medium_clone/presentation/providers/highlight_provider.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';

/// A widget that allows users to select and highlight text
class HighlightableText extends ConsumerStatefulWidget {
  final String text;
  final String articleId;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int maxLines;
  final TextOverflow? overflow;

  const HighlightableText({
    super.key,
    required this.text,
    required this.articleId,
    this.style,
    this.textAlign,
    this.maxLines = 1000,
    this.overflow,
  });

  @override
  ConsumerState<HighlightableText> createState() => _HighlightableTextState();
}

class _HighlightableTextState extends ConsumerState<HighlightableText> {
  TextSelection? _selection;
  OverlayEntry? _menuOverlay;
  final _textKey = GlobalKey();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(highlightProvider(widget.articleId).notifier).loadHighlights();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _hideMenu();
    super.dispose();
  }

  void _showHighlightMenu({
    required TextSelection selection,
    required String selectedText,
    required Offset position,
  }) {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null) {
      // Show sign-in prompt
      _showSignInPrompt();
      return;
    }

    _hideMenu();

    final renderBox = context.findRenderObject() as RenderBox;
    final globalPosition = renderBox.localToGlobal(position);

    _menuOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: globalPosition.dy - 120,
        left: globalPosition.dx - 100,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Container(
            width: AppDimensions.highlightMenuWidth,
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingSmall,
                    vertical: AppDimensions.paddingXSmall,
                  ),
                  child: Text(
                    'Highlight Color',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXSmall),
                // Color options
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingSmall,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: AppColors.highlightColors.map((color) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingXSmall,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            _addHighlight(
                              selection,
                              selectedText,
                              color.toHex(),
                            );
                            _hideMenu();
                          },
                          child: Container(
                            width: AppDimensions.clapsButtonSize - 8,
                            height: AppDimensions.clapsButtonSize - 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSmall),
                // Cancel button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingSmall,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _hideMenu,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingXSmall,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_menuOverlay!);
  }

  void _hideMenu() {
    _menuOverlay?.remove();
    _menuOverlay = null;
    setState(() {
      _selection = null;
    });
  }

  void _showSignInPrompt() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please sign in to highlight text'),
        action: SnackBarAction(
          label: 'Sign In',
          onPressed: (_) {
            context.push('/login');
          },
        ),
      ),
    );
  }

  Future<void> _addHighlight(
    TextSelection selection,
    String selectedText,
    String color,
  ) async {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null) {
      _showSignInPrompt();
      return;
    }

    final notifier = ref.read(highlightProvider(widget.articleId).notifier);
    
    await notifier.addHighlight(
      text: selectedText,
      startIndex: selection.start,
      endIndex: selection.end,
      color: color,
    );

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Highlight added!'),
        duration: const Duration(seconds: 1),
      ),
    );

    _hideMenu();
  }

  void _handleLongPress() {
    final textSpan = _buildTextSpan();
    final renderObject = _textKey.currentContext?.findRenderObject();
    
    if (renderObject is RenderParagraph && _selection != null) {
      final textLayout = renderObject.text as TextLayout;
      final position = textLayout.getPositionForOffset(_selection!.extentOffset);
      final lineHeight = textLayout.getLineHeightForOffset(_selection!.extentOffset);
      
      final selectedText = widget.text.substring(
        _selection!.start,
        _selection!.end,
      );

      if (selectedText.trim().isNotEmpty) {
        _showHighlightMenu(
          selection: _selection!,
          selectedText: selectedText,
          position: Offset(
            position.dx,
            position.dy + lineHeight,
          ),
        );
      }
    }
  }

  TextSpan _buildTextSpan() {
    final notifier = ref.read(highlightProvider(widget.articleId).notifier);
    final highlights = ref.watch(highlightProvider(widget.articleId)).highlights;
    final style = widget.style ?? Theme.of(context).textTheme.bodyLarge!;
    
    List<TextSpan> children = [];
    int currentPos = 0;

    // Sort highlights by start index
    final sortedHighlights = [...highlights]..sort((a, b) => a.startIndex.compareTo(b.startIndex));

    for (final highlight in sortedHighlights) {
      // Add text before highlight
      if (highlight.startIndex > currentPos) {
        children.add(
          TextSpan(
            text: widget.text.substring(currentPos, highlight.startIndex),
            style: style,
          ),
        );
      }

      // Add highlighted text
      final highlightText = widget.text.substring(
        highlight.startIndex,
        highlight.endIndex,
      );
      
      children.add(
        TextSpan(
          text: highlightText,
          style: style.copyWith(
            backgroundColor: highlight.highlightColor,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );

      currentPos = highlight.endIndex;
    }

    // Add remaining text
    if (currentPos < widget.text.length) {
      children.add(
        TextSpan(
          text: widget.text.substring(currentPos),
          style: style,
        ),
      );
    }

    return TextSpan(children: children, style: style);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(highlightProvider(widget.articleId).notifier);
    final highlights = ref.watch(highlightProvider(widget.articleId)).highlights;
    
    // Check if there are highlights at the current selection
    final hasHighlightAtSelection = _selection != null && notifier.hasHighlightAtPosition(_selection!.start);

    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPressStart: (details) {
          // Get position in text
          final renderObject = _textKey.currentContext?.findRenderObject();
          if (renderObject is RenderParagraph) {
            final textLayout = renderObject.text as TextLayout;
            final position = textLayout.getPositionForOffsetAtLocal(
              details.localPosition,
            );
            
            if (position != null) {
              // Select a word or sentence
              final wordBoundaries = _getWordBoundaries(position.offset);
              setState(() {
                _selection = TextSelection(
                  baseOffset: wordBoundaries.start,
                  extentOffset: wordBoundaries.end,
                );
              });
            }
          }
        },
        onLongPressEnd: (details) {
          if (_selection != null) {
            _handleLongPress();
          }
        },
        onTapDown: (details) {
          // Clear selection on tap
          setState(() {
            _selection = null;
          });
          _hideMenu();
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: RepaintBoundary(
            child: RichText(
              key: _textKey,
              text: _buildTextSpan(),
              textAlign: widget.textAlign ?? TextAlign.start,
              maxLines: widget.maxLines,
              overflow: widget.overflow ?? TextOverflow.ellipsis,
              selectionRegistrar: SelectionContainer.maybeOf(context),
              textSelectionControls: _CustomTextSelectionControls(
                onSelectionChanged: (selection, _) {
                  setState(() {
                    _selection = selection;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  ({int start, int end}) _getWordBoundaries(int offset) {
    // Find word boundaries
    int start = offset;
    int end = offset;

    // Move start backwards to beginning of word
    while (start > 0 && !RegExp(r'\s').hasMatch(widget.text[start - 1])) {
      start--;
    }

    // Move end forwards to end of word
    while (end < widget.text.length && !RegExp(r'\s').hasMatch(widget.text[end])) {
      end++;
    }

    // If we didn't find a word, select a sentence
    if (start == end) {
      start = offset;
      while (start > 0 && widget.text[start - 1] != '.' && widget.text[start - 1] != '!' && widget.text[start - 1] != '?') {
        start--;
      }
      end = offset;
      while (end < widget.text.length && widget.text[end] != '.' && widget.text[end] != '!' && widget.text[end] != '?') {
        end++;
      }
    }

    // Ensure we have at least some selection
    if (start == end) {
      start = offset;
      end = (offset + 1).clamp(0, widget.text.length);
    }

    return (start: start, end: end);
  }
}

/// Custom text selection controls that allow long press to highlight
class _CustomTextSelectionControls extends MaterialTextSelectionControls {
  final Function(TextSelection, SelectionChangedCause?) onSelectionChanged;

  _CustomTextSelectionControls({required this.onSelectionChanged});

  @override
  void handleLongPress(Offset longPressPosition) {
    // Don't show the default toolbar
    // We'll handle it in our own way
  }

  @override
  void updateHandlePosition(TextPosition position, TextSelectionHandleType handleType) {
    // Custom handle position update
    super.updateHandlePosition(position, handleType);
  }

  @override
  void onSelectionChanged(TextSelection selection, SelectionChangedCause? cause) {
    onSelectionChanged(selection, cause);
    super.onSelectionChanged(selection, cause);
  }
}

/// A simpler version that wraps Text with highlight support
class SimpleHighlightableText extends ConsumerStatefulWidget {
  final String text;
  final String articleId;
  final TextStyle? style;
  final List<HighlightModel> highlights;

  const SimpleHighlightableText({
    super.key,
    required this.text,
    required this.articleId,
    this.style,
    this.highlights = const [],
  });

  @override
  ConsumerState<SimpleHighlightableText> createState() => _SimpleHighlightableTextState();
}

class _SimpleHighlightableTextState extends ConsumerState<SimpleHighlightableText> {
  TextSelection? _selection;

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? Theme.of(context).textTheme.bodyLarge!;
    
    // Build text with highlights
    List<TextSpan> children = [];
    int currentPos = 0;

    final sortedHighlights = [...widget.highlights]..sort((a, b) => a.startIndex.compareTo(b.startIndex));

    for (final highlight in sortedHighlights) {
      // Add text before highlight
      if (highlight.startIndex > currentPos) {
        children.add(
          TextSpan(
            text: widget.text.substring(currentPos, highlight.startIndex),
            style: style,
          ),
        );
      }

      // Add highlighted text
      final highlightText = widget.text.substring(
        highlight.startIndex,
        highlight.endIndex,
      );
      
      children.add(
        TextSpan(
          text: highlightText,
          style: style.copyWith(
            backgroundColor: highlight.highlightColor,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );

      currentPos = highlight.endIndex;
    }

    // Add remaining text
    if (currentPos < widget.text.length) {
      children.add(
        TextSpan(
          text: widget.text.substring(currentPos),
          style: style,
        ),
      );
    }

    return SelectableText.rich(
      TextSpan(children: children, style: style),
      style: style,
      onSelectionChanged: (selection, cause) {
        setState(() {
          _selection = selection;
        });
      },
    );
  }
}

/// Highlight overlay for markdown content
class HighlightableMarkdownBody extends ConsumerStatefulWidget {
  final String data;
  final String articleId;
  final MarkdownStyleSheet? styleSheet;
  final void Function(String)? onTapLink;

  const HighlightableMarkdownBody({
    super.key,
    required this.data,
    required this.articleId,
    this.styleSheet,
    this.onTapLink,
  });

  @override
  ConsumerState<HighlightableMarkdownBody> createState() => _HighlightableMarkdownBodyState();
}

class _HighlightableMarkdownBodyState extends ConsumerState<HighlightableMarkdownBody> {
  @override
  Widget build(BuildContext context) {
    // For now, just render regular MarkdownBody
    // In a production app, you'd parse the markdown and make text selectable
    return Consumer(
      builder: (context, ref, child) {
        final highlights = ref.watch(highlightProvider(widget.articleId)).highlights;
        
        // TODO: Implement full markdown with selectable text
        // This is a complex feature that would require parsing markdown
        // and wrapping each text node with selection support
        
        return MarkdownBody(
          data: widget.data,
          styleSheet: widget.styleSheet,
          onTapLink: widget.onTapLink,
        );
      },
    );
  }
}
