import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:brightside/features/metro/metro.dart';
import 'package:brightside/features/metro/metro_provider.dart';
import 'package:brightside/features/story/model/story.dart';
import 'package:brightside/features/story/providers/story_providers.dart';
import 'package:brightside/shared/services/firebase_boot.dart';
import 'package:brightside/core/theme/app_theme.dart';
import 'package:brightside/core/utils/ui.dart';

class SubmitScreen extends ConsumerStatefulWidget {
  const SubmitScreen({super.key});

  @override
  ConsumerState<SubmitScreen> createState() => _SubmitScreenState();
}

class _SubmitScreenState extends ConsumerState<SubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String? _selectedMetroId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize metro selection with current active metro
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final metroState = ref.read(metroProvider);
      setState(() {
        _selectedMetroId = metroState.metroId;
      });

      // Ensure user is authenticated (anonymous if needed)
      _ensureAuthenticated();
    });
  }

  Future<void> _ensureAuthenticated() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      try {
        await FirebaseAuth.instance.signInAnonymously();
      } catch (e) {
        if (mounted) {
          UIHelpers.showErrorSnackBar(
            context,
            'Authentication required to submit stories',
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Story'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Content policy notice
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.secondaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.paddingSmall),
                    Expanded(
                      child: Text(
                        'We may lightly edit for grammar/format; no politics or sensitive content.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textPrimaryColor,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),

              // Metro selector
              Text(
                'Metro',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.paddingSmall),
              DropdownButtonFormField<String>(
                initialValue: _selectedMetroId,
                decoration: const InputDecoration(
                  hintText: 'Select metro',
                  prefixIcon: Icon(Icons.location_city),
                ),
                items: kMetros.map((metro) {
                  return DropdownMenuItem(
                    value: metro.id,
                    child: Text('${metro.name}, ${metro.state}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMetroId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a metro';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.paddingLarge),

              // Title field
              Text(
                'Title',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.paddingSmall),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter story title',
                  counterText: '${_titleController.text.length}/80',
                ),
                maxLength: 80,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.trim().length < 10) {
                    return 'Title must be at least 10 characters';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppTheme.paddingLarge),

              // Body field
              Text(
                'Story',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.paddingSmall),
              TextFormField(
                controller: _bodyController,
                decoration: InputDecoration(
                  hintText: 'Share your story...',
                  counterText: '${_bodyController.text.length}/1200',
                  alignLabelWithHint: true,
                ),
                maxLength: 1200,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your story';
                  }
                  if (value.trim().length < 50) {
                    return 'Story must be at least 50 characters';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppTheme.paddingLarge),

              // Optional image URL field
              Text(
                'Image URL (Optional)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.paddingSmall),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  hintText: 'https://example.com/image.jpg',
                  prefixIcon: Icon(Icons.image),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final uri = Uri.tryParse(value.trim());
                    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                      return 'Please enter a valid URL';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.paddingXLarge),

              // Submit button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Submit Story'),
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // Cancel button
              TextButton(
                onPressed: _isSubmitting ? null : _handleClear,
                child: const Text('Clear Form'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Ensure user is authenticated
    final uid = ref.read(userUidProvider);
    if (uid == null) {
      await _ensureAuthenticated();
      final newUid = ref.read(userUidProvider);
      if (newUid == null) {
        if (mounted) {
          UIHelpers.showErrorSnackBar(
            context,
            'Authentication required to submit stories',
          );
        }
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = ref.read(storyRepositoryProvider);

      // Generate unique submission ID
      final submissionId = 'sub_${DateTime.now().millisecondsSinceEpoch}';

      // Create story draft
      final story = Story(
        id: submissionId,
        metroId: _selectedMetroId!,
        type: StoryType.user,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        createdAt: DateTime.now(),
        status: StoryStatus.queued,
      );

      // Submit to repository (will upload photo if local file path provided)
      await repository.submitUserStory(story);

      // Invalidate providers to refresh lists
      ref.invalidate(todayStoriesProvider);
      ref.invalidate(popularStoriesProvider);

      if (mounted) {
        // Show success snackbar with submission ID
        UIHelpers.showSuccessSnackBar(
          context,
          'Story submitted successfully! ID: $submissionId',
        );

        // Clear form
        _titleController.clear();
        _bodyController.clear();
        _imageUrlController.clear();
      }
    } catch (e) {
      if (mounted) {
        // Show error snackbar
        UIHelpers.handleError(
          context,
          e,
          customMessage: 'Failed to submit story',
          onRetry: _handleSubmit,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _handleClear() {
    _titleController.clear();
    _bodyController.clear();
    _imageUrlController.clear();
    setState(() {});
  }
}
