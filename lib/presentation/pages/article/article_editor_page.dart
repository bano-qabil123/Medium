import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/core/utils/validators.dart';
import 'package:medium_clone/data/models/article_model.dart';
import 'package:medium_clone/presentation/providers/article_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_button.dart';
import 'package:medium_clone/presentation/widgets/common/app_text_field.dart';
import 'package:medium_clone/presentation/widgets/common/app_loading.dart';
import 'package:medium_clone/presentation/widgets/layout/main_layout.dart';

class ArticleEditorPage extends ConsumerStatefulWidget {
  final String? articleId;
  
  const ArticleEditorPage({super.key, this.articleId});

  @override
  ConsumerState<ArticleEditorPage> createState() => _ArticleEditorPageState();
}

class _ArticleEditorPageState extends ConsumerState<ArticleEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _quillController = QuillController.basic();
  
  bool _isLoading = false;
  String? _errorMessage;
  ArticleModel? _article;
  
  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  Future<void> _loadArticle() async {
    if (widget.articleId != null) {
      setState(() => _isLoading = true);
      try {
        final article = await ref.read(articleDetailProvider(widget.articleId!).future);
        setState(() {
          _article = article;
          _titleController.text = article.title;
          _quillController.document = Document.fromJson(article.content);
        });
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
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
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      if (widget.articleId != null) {
        // Update existing article
        await ref.read(articleControllerProvider.notifier).updateArticle(
          articleId: widget.articleId!,
          title: _titleController.text.trim(),
          content: _quillController.document.toPlainText(),
          status: 'published',
        );
      } else {
        // Create new article
        await ref.read(articleControllerProvider.notifier).createArticle(
          title: _titleController.text.trim(),
          content: _quillController.document.toPlainText(),
          status: 'published',
        );
      }
      
      // Navigate to home on success
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSaveDraft() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      if (widget.articleId != null) {
        // Update existing article as draft
        await ref.read(articleControllerProvider.notifier).updateArticle(
          articleId: widget.articleId!,
          title: _titleController.text.trim(),
          content: _quillController.document.toPlainText(),
          status: 'draft',
        );
      } else {
        // Create new article as draft
        await ref.read(articleControllerProvider.notifier).createArticle(
          title: _titleController.text.trim(),
          content: _quillController.document.toPlainText(),
          status: 'draft',
        );
      }
      
      // Navigate to home on success
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: widget.articleId != null ? 'Edit Article' : 'New Article',
      showBackButton: true,
      actions: [
        if (widget.articleId != null)
          TextButton(
            onPressed: () {
              // TODO: Show delete confirmation
            },
            child: Text(
              'Delete',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
      ],
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Title
                AppTextField(
                  controller: _titleController,
                  labelText: 'Title',
                  hintText: 'Enter article title',
                  validator: (value) => Validators.validateArticleTitle(value),
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                ),
                
                const SizedBox(height: AppDimensions.spacingMedium),
                
                // Cover Image (placeholder for now)
                Container(
                  width: double.infinity,
                  height: AppDimensions.coverImageHeight,
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    border: BorderSide(color: AppColors.border),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: AppDimensions.iconLarge,
                          color: AppColors.grey,
                        ),
                        const SizedBox(height: AppDimensions.spacingSmall),
                        Text(
                          'Add Cover Image',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spacingLarge),
                
                // Editor
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    border: BorderSide(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      // Toolbar
                      QuillToolbar.basic(
                        controller: _quillController,
                        multiRowsDisplay: false,
                        showAlignmentButtons: true,
                        showListNumbers: true,
                        showListBullets: true,
                        showListCheck: true,
                        showCodeBlock: true,
                        showQuote: true,
                        showLink: true,
                        showImage: false, // We'll handle image upload separately
                        toolbarIconAlignment: WrapAlignment.start,
                        color: AppColors.primary,
                        iconTheme: QuillIconTheme(
                          iconSelectedColor: AppColors.primary,
                          iconUnselectedColor: AppColors.grey,
                          iconSelectedFillColor: AppColors.primary.withOpacity(0.1),
                          iconUnselectedFillColor: Colors.transparent,
                        ),
                      ),
                      
                      // Editor
                      Container(
                        constraints: const BoxConstraints(
                          minHeight: 200,
                        ),
                        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                        child: QuillEditor(
                          controller: _quillController,
                          readOnly: false,
                          autoFocus: false,
                          expands: false,
                          padding: EdgeInsets.zero,
                          placeholder: 'Start writing...',
                          style: DefaultTextBlockStyle(
                            TextStyle(
                              fontSize: AppTypography.bodyLarge.fontSize,
                              color: AppColors.onSurface,
                              height: 1.6,
                            ),
                            const TextStyle(),
                            const TextStyle(),
                            const TextStyle(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppDimensions.spacingMedium),
                  Text(
                    _errorMessage!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                
                const SizedBox(height: AppDimensions.spacingXLarge),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButtonSecondary(
                        text: 'Save Draft',
                        onPressed: _isLoading ? null : _handleSaveDraft,
                        isLoading: _isLoading,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMedium),
                    Expanded(
                      child: AppButton(
                        text: widget.articleId != null ? 'Update' : 'Publish',
                        onPressed: _isLoading ? null : _handlePublish,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
