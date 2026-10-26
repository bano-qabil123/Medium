import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medium_clone/data/models/highlight_model.dart';
import 'package:medium_clone/data/repositories/highlight_repository.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';

// Highlight Repository Provider
final highlightRepositoryProvider = Provider<HighlightRepository>((ref) {
  return HighlightRepository();
});

// Highlight State for a specific article
class HighlightState {
  final List<HighlightModel> highlights;
  final bool isLoading;
  final String? error;
  final HighlightModel? selectedHighlight;
  final TextSelection? currentSelection;
  final OverlayEntry? highlightMenu;

  const HighlightState({
    this.highlights = const [],
    this.isLoading = false,
    this.error,
    this.selectedHighlight,
    this.currentSelection,
    this.highlightMenu,
  });

  HighlightState copyWith({
    List<HighlightModel>? highlights,
    bool? isLoading,
    String? error,
    HighlightModel? selectedHighlight,
    TextSelection? currentSelection,
    OverlayEntry? highlightMenu,
  }) {
    return HighlightState(
      highlights: highlights ?? this.highlights,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedHighlight: selectedHighlight ?? this.selectedHighlight,
      currentSelection: currentSelection ?? this.currentSelection,
      highlightMenu: highlightMenu ?? this.highlightMenu,
    );
  }
}

// Highlight Notifier for a specific article
class HighlightNotifier extends StateNotifier<HighlightState> {
  final HighlightRepository _highlightRepository;
  final String _articleId;
  final String? _userId;
  final BuildContext? _context;

  HighlightNotifier(this._highlightRepository, this._articleId, this._userId, [this._context])
      : super(const HighlightState());

  Future<void> loadHighlights() async {
    if (_userId == null) {
      state = state.copyWith(isLoading: false, error: 'Not authenticated');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final highlights = await _highlightRepository.getHighlightsForArticle(
        articleId: _articleId,
        userId: _userId!,
      );
      state = state.copyWith(
        highlights: highlights,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addHighlight({
    required String text,
    required int startIndex,
    required int endIndex,
    String color = 'FFFFD700',
  }) async {
    if (_userId == null) {
      state = state.copyWith(error: 'Please sign in to highlight');
      return;
    }

    try {
      final highlight = await _highlightRepository.addHighlight(
        articleId: _articleId,
        userId: _userId!,
        text: text,
        startIndex: startIndex,
        endIndex: endIndex,
        color: color,
      );
      
      // Reload highlights
      await loadHighlights();
      
      // Clear selection
      state = state.copyWith(
        currentSelection: null,
        selectedHighlight: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeHighlight(String highlightId) async {
    try {
      await _highlightRepository.removeHighlight(highlightId);
      await loadHighlights();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setCurrentSelection(TextSelection? selection) {
    state = state.copyWith(currentSelection: selection);
  }

  void setSelectedHighlight(HighlightModel? highlight) {
    state = state.copyWith(selectedHighlight: highlight);
  }

  void setHighlightMenu(OverlayEntry? menu) {
    state = state.copyWith(highlightMenu: menu);
  }

  List<HighlightModel> getHighlightsForRange(int start, int end) {
    return state.highlights.where((h) =>
      h.startIndex <= end && h.endIndex >= start
    ).toList();
  }

  bool hasHighlightAtPosition(int offset) {
    return state.highlights.any((h) =>
      offset >= h.startIndex && offset <= h.endIndex
    );
  }

  HighlightModel? getHighlightAtPosition(int offset) {
    try {
      return state.highlights.firstWhere((h) =>
        offset >= h.startIndex && offset <= h.endIndex
      );
    } catch (e) {
      return null;
    }
  }
}

// Highlight Provider for a specific article
final highlightProvider = StateNotifierProvider.family<
  HighlightNotifier,
  HighlightState,
  String
>((ref, articleId) {
  final userId = ref.watch(authProvider).valueOrNull?.id;
  final repository = ref.watch(highlightRepositoryProvider);
  final notifier = HighlightNotifier(repository, articleId, userId);
  notifier.loadHighlights();
  return notifier;
});

// All Highlights Provider for current user
final userHighlightsProvider = FutureProvider<List<HighlightModel>>((ref) async {
  final userId = ref.watch(authProvider).valueOrNull?.id;
  if (userId == null) return [];
  
  final repository = ref.watch(highlightRepositoryProvider);
  return await repository.getHighlightsByUser(userId);
});

// Highlight Color Provider
final highlightColorProvider = StateProvider<String>((ref) => 'FFFFD700'); // Default gold

// Highlight Menu Controller
class HighlightMenuController {
  static OverlayEntry? _currentOverlay;
  static TextSelection? _currentSelection;
  static String? _currentArticleId;
  static String? _currentSelectedText;

  static void showMenu({
    required BuildContext context,
    required TextSelection selection,
    required String selectedText,
    required String articleId,
    required Function(String color) onHighlight,
    required Function() onCancel,
  }) {
    // Hide current overlay
    hideMenu();

    _currentSelection = selection;
    _currentArticleId = articleId;
    _currentSelectedText = selectedText;

    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(
      renderBox.size.center(Offset.zero),
    );

    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy - 100,
        left: position.dx - 100,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Highlight',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Color options
                Wrap(
                  spacing: 8,
                  children: AppColors.highlightColors.map((color) {
                    return GestureDetector(
                      onTap: () {
                        onHighlight(color.toHex());
                        hideMenu();
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    onCancel();
                    hideMenu();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  static void hideMenu() {
    _currentOverlay?.remove();
    _currentOverlay = null;
    _currentSelection = null;
    _currentArticleId = null;
    _currentSelectedText = null;
  }

  static TextSelection? get currentSelection => _currentSelection;
  static String? get currentArticleId => _currentArticleId;
  static String? get currentSelectedText => _currentSelectedText;
}

// Extension to convert Color to hex string
extension on Color {
  String toHex() {
    return value.toRadixString(16).padLeft(8, '0').substring(2);
  }
}
