import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/data/models/article_model.dart';
import 'package:medium_clone/presentation/providers/article_provider.dart';
import 'package:medium_clone/presentation/providers/tag_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_loading.dart';
import 'package:medium_clone/presentation/widgets/common/app_empty_state.dart';
import 'package:medium_clone/presentation/widgets/common/app_text_field.dart';
import 'package:medium_clone/presentation/widgets/article/article_card.dart';
import 'package:medium_clone/presentation/widgets/layout/main_layout.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  
  // Search filters
  String _selectedSort = 'relevance';
  String _selectedTime = 'all';
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _isSearching = _searchQuery.isNotEmpty;
    });
  }

  void _setSort(String sort) {
    setState(() {
      _selectedSort = sort;
    });
  }

  void _setTime(String time) {
    setState(() {
      _selectedTime = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Search',
      showBackButton: true,
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: AppTextField(
              key: const ValueKey('search-field'),
              controller: _searchController,
              hintText: 'Search articles, tags, writers...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isSearching
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                          _isSearching = false;
                        });
                      },
                    )
                  : null,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _isSearching = value.isNotEmpty;
                });
              },
              onSubmitted: (value) {
                setState(() {
                  _searchQuery = value;
                  _isSearching = value.isNotEmpty;
                });
              },
            ),
          ),
          
          // Filters
          if (_isSearching) ...[
            _buildFilters(context),
            const SizedBox(height: AppDimensions.spacingMedium),
          ],
          
          // Results
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildEmptyState()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
      child: Row(
        children: [
          // Sort filter
          _buildFilterChip(
            label: 'Relevance',
            isSelected: _selectedSort == 'relevance',
            onSelected: () => _setSort('relevance'),
          ),
          const SizedBox(width: AppDimensions.spacingXSmall),
          _buildFilterChip(
            label: 'Newest',
            isSelected: _selectedSort == 'newest',
            onSelected: () => _setSort('newest'),
          ),
          const SizedBox(width: AppDimensions.spacingXSmall),
          _buildFilterChip(
            label: 'Most Claps',
            isSelected: _selectedSort == 'claps',
            onSelected: () => _setSort('claps'),
          ),
          const SizedBox(width: AppDimensions.spacingXSmall),
          _buildFilterChip(
            label: 'Most Comments',
            isSelected: _selectedSort == 'comments',
            onSelected: () => _setSort('comments'),
          ),
          const SizedBox(width: AppDimensions.spacingMedium),
          
          // Time filter
          _buildFilterChip(
            label: 'All Time',
            isSelected: _selectedTime == 'all',
            onSelected: () => _setTime('all'),
          ),
          const SizedBox(width: AppDimensions.spacingXSmall),
          _buildFilterChip(
            label: 'Last 24h',
            isSelected: _selectedTime == '24h',
            onSelected: () => _setTime('24h'),
          ),
          const SizedBox(width: AppDimensions.spacingXSmall),
          _buildFilterChip(
            label: 'Last Week',
            isSelected: _selectedTime == 'week',
            onSelected: () => _setTime('week'),
          ),
          const SizedBox(width: AppDimensions.spacingXSmall),
          _buildFilterChip(
            label: 'Last Month',
            isSelected: _selectedTime == 'month',
            onSelected: () => _setTime('month'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onSelected(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: isSelected 
            ? Theme.of(context).colorScheme.onPrimary 
            : Theme.of(context).colorScheme.onSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      side: BorderSide(
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }

  Widget _buildEmptyState() {
    return AppEmptyState(
      icon: Icons.search,
      title: 'Search for Anything',
      message: 'Find articles, tags, and writers by typing above',
      showIcon: true,
    );
  }

  Widget _buildSearchResults() {
    final articlesAsync = ref.watch(searchArticlesProvider(_searchQuery));
    final tagsAsync = ref.watch(searchTagsProvider(_searchQuery));

    return articlesAsync.when(
      loading: () => const Center(child: AppLoading()),
      error: (error, stack) => AppEmptyStateError(
        message: error.toString(),
        onRetry: () => ref.refresh(searchArticlesProvider(_searchQuery)),
      ),
      data: (articles) {
        if (articles.isEmpty) {
          return AppEmptyStateNoResults(
            searchTerm: _searchQuery,
            onClear: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
                _isSearching = false;
              });
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          itemCount: articles.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              // Tags section
              return tagsAsync.when(
                loading: () => const SizedBox(),
                error: (error, stack) => const SizedBox(),
                data: (tags) {
                  if (tags.isEmpty) {
                    return const SizedBox();
                  }
                  return _TagsSection(tags: tags);
                },
              );
            }
            
            final article = articles[index - 1];
            return ArticleCard(
              key: ValueKey('search-result-${article.id}'),
              article: article,
              onTap: () => context.push('/article/${article.id}'),
            );
          },
        );
      },
    );
  }
}

class _TagsSection extends StatelessWidget {
  final List<TagModel> tags;

  const _TagsSection({required this.tags});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacingSmall),
          child: Text(
            'Tags',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Wrap(
          spacing: AppDimensions.spacingSmall,
          runSpacing: AppDimensions.spacingSmall,
          children: tags.map((tag) => AppChip(
            key: ValueKey('search-tag-${tag.id}'),
            label: tag.name,
            onPressed: () => context.push('/tag/${tag.slug}'),
          )).toList(),
        ),
        const SizedBox(height: AppDimensions.spacingLarge),
        Text(
          'Articles',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSmall),
      ],
    );
  }
}

// Search Providers
final searchArticlesProvider = FutureProvider.family<List<ArticleModel>, String>((ref, query) async {
  final repository = ref.watch(articleRepositoryProvider);
  return await repository.searchArticles(query);
});

final searchTagsProvider = FutureProvider.family<List<TagModel>, String>((ref, query) async {
  final repository = ref.watch(tagRepositoryProvider);
  return await repository.searchTags(query);
});

// Article Repository extension for search
class ArticleRepository {
  final SupabaseClient _supabase = SupabaseClient.instance;

  Future<List<ArticleModel>> searchArticles(String query) async {
    try {
      final response = await _supabase
          .from('articles')
          .select('*, author:users(*)')
          .textSearch('title,content,excerpt', query)
          .order('published_at', ascending: false)
          .limit(20);

      return (response as List)
          .map((json) => ArticleModel.fromSupabase(json, author: json['author'] != null 
            ? UserModel.fromSupabase(json['author'] as Map<String, dynamic>) 
            : null))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepository();
});
