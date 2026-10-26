import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/data/models/tag_model.dart';
import 'package:medium_clone/presentation/providers/tag_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_loading.dart';
import 'package:medium_clone/presentation/widgets/common/app_empty_state.dart';
import 'package:medium_clone/presentation/widgets/common/app_chip.dart';
import 'package:medium_clone/presentation/widgets/layout/main_layout.dart';

class TagsPage extends ConsumerWidget {
  const TagsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingTagsAsync = ref.watch(trendingTagsProvider);
    final allTagsAsync = ref.watch(allTagsProvider);
    final followedTagsAsync = ref.watch(followedTagsProvider);

    return MainLayout(
      title: 'Tags',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trending Tags
            _SectionHeader(
              title: 'Trending Tags',
              action: TextButton(
                onPressed: () => context.push('/tags/all'),
                child: const Text('See All'),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            trendingTagsAsync.when(
              loading: () => const AppShimmerTags(),
              error: (error, stack) => Text(
                'Error loading tags: ${error.toString()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
              ),
              data: (tags) {
                if (tags.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.local_fire_department_outlined,
                    title: 'No Trending Tags',
                    message: 'Tags will appear here when articles are published',
                    showIcon: false,
                  );
                }
                return _TagChipsRow(tags: tags);
              },
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            
            // Followed Tags
            _SectionHeader(title: 'Tags You Follow'),
            const SizedBox(height: AppDimensions.spacingSmall),
            followedTagsAsync.when(
              loading: () => const AppShimmerTags(),
              error: (error, stack) => Text(
                'Error loading followed tags: ${error.toString()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
              ),
              data: (tags) {
                if (tags.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.tag_outlined,
                    title: 'No Followed Tags',
                    message: 'Follow tags to see articles on topics you care about',
                    showIcon: false,
                  );
                }
                return _TagChipsRow(tags: tags);
              },
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            
            // All Tags
            _SectionHeader(
              title: 'All Tags',
              action: TextButton(
                onPressed: () => context.push('/tags/all'),
                child: const Text('Browse All'),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            allTagsAsync.when(
              loading: () => const AppShimmerTags(),
              error: (error, stack) => Text(
                'Error loading all tags: ${error.toString()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
              ),
              data: (tags) {
                if (tags.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.tag_outlined,
                    title: 'No Tags',
                    message: 'No tags have been created yet',
                    showIcon: false,
                  );
                }
                return _TagList(tags: tags);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const _SectionHeader({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class _TagChipsRow extends StatelessWidget {
  final List<TagModel> tags;

  const _TagChipsRow({required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.spacingSmall,
      runSpacing: AppDimensions.spacingSmall,
      children: tags.map((tag) => AppChip(
        key: ValueKey('tag-chip-${tag.id}'),
        label: tag.name,
        onPressed: () => context.push('/tag/${tag.slug}'),
      )).toList(),
    );
  }
}

class _TagList extends StatelessWidget {
  final List<TagModel> tags;

  const _TagList({required this.tags});

  @override
  Widget build(BuildContext context) {
    // Sort tags alphabetically
    final sortedTags = [...tags]..sort((a, b) => a.name.compareTo(b.name));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedTags.map((tag) => Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.spacingSmall),
        child: ListTile(
          key: ValueKey('tag-list-${tag.id}'),
          title: Text(tag.name),
          subtitle: tag.description != null
              ? Text(tag.description!)
              : null,
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/tag/${tag.slug}'),
        ),
      )).toList(),
    );
  }
}

class AppShimmerTags extends StatelessWidget {
  const AppShimmerTags({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.spacingSmall,
      runSpacing: AppDimensions.spacingSmall,
      children: List.generate(10, (index) => Container(
        width: 80,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
      )),
    );
  }
}
