import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/core/utils/validators.dart';
import 'package:medium_clone/presentation/providers/article_provider.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_button.dart';
import 'package:medium_clone/presentation/widgets/common/app_text_field.dart';
import 'package:medium_clone/presentation/widgets/common/app_loading.dart';
import 'package:medium_clone/presentation/widgets/common/app_chip.dart';
import 'package:medium_clone/presentation/widgets/layout/main_layout.dart';

/// Advanced article editor with image upload and auto-save
class ArticleEditorPage extends ConsumerStatefulWidget {
  final String? articleId;

  const ArticleEditorPage({super.key, this.articleId});

  @override
  ConsumerState<ArticleEditorPage> createState() => _ArticleEditorPageState();
}

class _ArticleEditorPageState extends ConsumerState<ArticleEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _excerptController = TextEditingController();
  final _tagsController = TextEditingController();
  late QuillController _quillController;
  
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isPublishing = false;
  String? _errorMessage;
  ArticleModel? _article;
  String? _coverImagePath;
  
  // Auto-save timer
  final Duration _autoSaveInterval = const Duration(minutes: 1);
  Timer? _autoSaveTimer;
  DateTime? _lastSaveTime;

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
    _loadArticle();
    _startAutoSave();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _excerptController.dispose();
    _tagsController.dispose();
    _quillController.dispose();
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(_autoSaveInterval, (timer) {
      _autoSave();
    });
  }

  Future<void> _autoSave() async {
    if (_isSaving || _isPublishing) return;
    
    final hasChanges = _hasUnsavedChanges();
    if (!hasChanges) return;
    
    setState(() => _isSaving = true);
    
    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) return;
      
      await ref.read(articleControllerProvider.notifier).saveDraft(
        articleId: widget.articleId,
        title: _titleController.text.trim(),
        excerpt: _excerptController.text.trim(),
        content: _quillController.document.toPlainText(),
        coverImage: _coverImagePath,
        tags: _parseTags(_tagsController.text),
      );
      
      setState(() {
        _isSaving = false;
        _lastSaveTime = DateTime.now();
      });
    } catch (e) {
      setState(() => _isSaving = false);
    }
  }

  bool _hasUnsavedChanges() {
    if (_article == null) {
      return _titleController.text.isNotEmpty || 
             _quillController.document.length > 1;
    }
    
    return _titleController.text != _article!.title ||
           _excerptController.text != (_article!.excerpt ?? '') ||
           _quillController.document.toPlainText() != _article!.content ||
           _coverImagePath != _article!.coverImageUrl ||
           _tagsController.text != (_article!.tags.join(', '));
  }

  Future<void> _loadArticle() async {
    if (widget.articleId != null) {
      setState(() => _isLoading = true);
      try {
        final article = await ref.read(articleDetailProvider(widget.articleId!).future);
        setState(() {
          _article = article;
          _titleController.text = article.title;
          _excerptController.text = article.excerpt ?? '';
          _tagsController.text = article.tags.join(', ');
          _coverImagePath = article.coverImageUrl;
          _quillController.document = Document.fromJson(article.content);
        });
      } catch (e) {
        setState(() => _errorMessage = e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_quillController.document.length <= 1) {
      setState(() => _errorMessage = 'Please enter some content');
      return;
    }
    
    setState(() {
      _isPublishing = true;
      _errorMessage = null;
    });
    
    try {
      if (widget.articleId != null) {
        // Update existing article
        await ref.read(articleControllerProvider.notifier).updateArticle(
          articleId: widget.articleId!,
          title: _titleController.text.trim(),
          content: _quillController.document.toPlainText(),
          excerpt: _excerptController.text.trim(),
          coverImage: _coverImagePath,
          status: 'published',
          tags: _parseTags(_tagsController.text),
        );
      } else {
        // Create new article
        await ref.read(articleControllerProvider.notifier).createArticle(
          title: _titleController.text.trim(),
          content: _quillController.document.toPlainText(),
          excerpt: _excerptController.text.trim(),
          coverImage: _coverImagePath,
          status: 'published',
          tags: _parseTags(_tagsController.text),
        );
      }
      
      // Navigate to home on success
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception:', '').trim());
    } finally {
      setState(() => _isPublishing = false);
    }
  }

  Future<void> _handleSaveDraft() async {
    if (!_formFormKey.currentState!.validate()) return;
    
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    
    try {
      await ref.read(articleControllerProvider.notifier).saveDraft(
        articleId: widget.articleId,
        title: _titleController.text.trim(),
        content: _quillController.document.toPlainText(),
        excerpt: _excerptController.text.trim(),
        coverImage: _coverImagePath,
        tags: _parseTags(_tagsController.text),
      );
      
      setState(() {
        _isSaving = false;
        _lastSaveTime = DateTime.now();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft saved!')),
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    }
  }

  Future<void> _pickCoverImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        // For now, just store the path
        // In production, you would upload to Supabase Storage
        setState(() => _coverImagePath = pickedFile.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: ${e.toString()}')),
      );
    }
  }

  Future<void> _removeCoverImage() async {
    setState(() => _coverImagePath = null);
  }

  List<String> _parseTags(String text) {
    return text
        .split(',')
        .map((tag) => tag.trim().toLowerCase())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MainLayout(
        title: widget.articleId != null ? 'Edit Article' : 'New Article',
        child: const Center(child: AppLoading()),
      );
    }

    return MainLayout(
      title: widget.articleId != null ? 'Edit Article' : 'New Article',
      showBackButton: true,
      actions: [
        // Auto-save indicator
        if (_lastSaveTime != null)
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.paddingSmall),
            child: Center(
              child: Text(
                'Saved ${_formatTimeAgo(_lastSaveTime!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        if (_isSaving)
          const Padding(
            padding: EdgeInsets.only(right: AppDimensions.paddingSmall),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image
              _buildCoverImageSection(),
              const SizedBox(height: AppDimensions.spacingLarge),
              
              // Title
              Text(
                'Title',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSmall),
              AppTextField(
                controller: _titleController,
                hintText: 'Enter article title',
                validator: (value) => Validators.validateRequired(value, 'Title'),
                maxLength: 120,
              ),
              const SizedBox(height: AppDimensions.spacingLarge),
              
              // Excerpt
              Text(
                'Excerpt (Optional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSmall),
              AppTextField(
                controller: _excerptController,
                hintText: 'Short description (160 characters max)',
                maxLines: 3,
                maxLength: 160,
              ),
              const SizedBox(height: AppDimensions.spacingLarge),
              
              // Tags
              Text(
                'Tags (Optional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSmall),
              AppTextField(
                controller: _tagsController,
                hintText: 'Enter tags separated by commas (e.g., flutter, dart, programming)',
                maxLines: 1,
              ),
              const SizedBox(height: AppDimensions.spacingSmall),
              // Tag suggestions
              if (_tagsController.text.isNotEmpty) ...[
                Wrap(
                  spacing: AppDimensions.spacingXSmall,
                  runSpacing: AppDimensions.spacingXSmall,
                  children: _parseTags(_tagsController.text)
                      .map((tag) => AppChip(
                            label: tag,
                            onPressed: () {
                              // Remove tag
                              final tags = _parseTags(_tagsController.text);
                              tags.remove(tag);
                              _tagsController.text = tags.join(', ');
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: AppDimensions.spacingSmall),
              ],
              
              const SizedBox(height: AppDimensions.spacingLarge),
              
              // Content Editor
              Text(
                'Content',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSmall),
              
              // Quill Editor
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Column(
                  children: [
                    // Toolbar
                    QuillToolbar.basic(
                      controller: _quillController,
                      showDividers: false,
                      showAlignmentButtons: true,
                      showListNumbers: true,
                      showListBullets: true,
                      showCodeBlock: true,
                      showQuote: true,
                      showLink: true,
                      showImageButton: false, // We handle images separately
                    ),
                    
                    // Editor
                    Container(
                      height: 400,
                      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                      child: QuillEditor(
                        controller: _quillController,
                        readOnly: false,
                        autoFocus: false,
                        expands: false,
                        padding: EdgeInsets.zero,
                        embedBuilders: [
                          // Add custom embed builders for images, etc.
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppDimensions.spacingLarge),
              
              // Error message
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
              ],
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: AppButtonSecondary(
                      text: 'Save Draft',
                      onPressed: _isSaving ? null : _handleSaveDraft,
                      loading: _isSaving,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMedium),
                  Expanded(
                    child: AppButton(
                      text: widget.articleId != null ? 'Update' : 'Publish',
                      onPressed: _isPublishing ? null : _handlePublish,
                      loading: _isPublishing,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.spacingLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cover Image (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSmall),
        
        // Cover image preview or upload button
        if (_coverImagePath != null) ...[
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                child: Image.file(
                  File(_coverImagePath!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Remove button
              Container(
                margin: const EdgeInsets.all(AppDimensions.paddingSmall),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, size: AppDimensions.iconSmall),
                  color: AppColors.onPrimary,
                  onPressed: _removeCoverImage,
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(AppDimensions.buttonHeightSmall, AppDimensions.buttonHeightSmall),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          AppButtonSecondary(
            text: 'Change Image',
            onPressed: _pickCoverImage,
            fullWidth: false,
          ),
        ] else ...[
          // Upload button
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
                style: BorderStyle.solid,
              ),
            ),
            child: InkWell(
              onTap: _pickCoverImage,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: AppDimensions.iconXLarge,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Text(
                    'Add Cover Image',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXSmall),
                  Text(
                    'Recommended: 1200x600 pixels',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
