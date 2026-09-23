import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/article_thumbnail.dart';
import '../../bloc/article_editor/article_editor_cubit.dart';
import '../../bloc/article_editor/article_editor_state.dart';
import '../../widgets/article_failure_text.dart';

/// Skeleton of the article editor: plain form fields wired to
/// [ArticleEditorCubit]. It covers the whole flow (write, attach a cover,
/// save as draft, publish) so the feature can be tested before the designed
/// UI replaces it.
class ArticleEditorScreen extends StatefulWidget {
  const ArticleEditorScreen({super.key});

  @override
  State<ArticleEditorScreen> createState() => _ArticleEditorScreenState();
}

class _ArticleEditorScreenState extends State<ArticleEditorScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fillControllersWith(context.read<ArticleEditorCubit>().state);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArticleEditorCubit, ArticleEditorState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStateChanged,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state.isEditingStoredArticle ? 'Edit article' : 'New article',
            ),
          ),
          body: state.status == ArticleEditorStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : _buildForm(context, state),
          bottomNavigationBar: _buildActions(context, state),
        );
      },
    );
  }

  Widget _buildForm(BuildContext context, ArticleEditorState state) {
    final cubit = context.read<ArticleEditorCubit>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Title'),
          onChanged: cubit.titleChanged,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: 'Description'),
          maxLines: 2,
          onChanged: cubit.descriptionChanged,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _contentController,
          decoration: const InputDecoration(labelText: 'Content'),
          maxLines: 8,
          onChanged: cubit.contentChanged,
        ),
        const SizedBox(height: 16),
        _buildThumbnailSection(context, state),
        if (state.validationErrors.isNotEmpty) ...[
          const SizedBox(height: 16),
          ArticleFailureText(state.error),
        ],
      ],
    );
  }

  Widget _buildThumbnailSection(
    BuildContext context,
    ArticleEditorState state,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            state.hasThumbnail
                ? state.article.thumbnailUrl
                : 'No cover image attached',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: state.isBusy ? null : () => _attachSampleThumbnail(context),
          icon: state.status == ArticleEditorStatus.uploadingThumbnail
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.image),
          label: const Text('Attach cover'),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, ArticleEditorState state) {
    final cubit = context.read<ArticleEditorCubit>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.status == ArticleEditorStatus.autosaved)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('Draft saved', style: TextStyle(fontSize: 12)),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: state.isBusy ? null : cubit.saveDraft,
                    child: const Text('Save draft'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: state.isBusy ? null : cubit.publish,
                    child: const Text('Publish'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, ArticleEditorState state) {
    if (state.status == ArticleEditorStatus.editing) {
      _fillControllersWith(state);
      return;
    }
    // Only an explicit save closes the editor. `autosaved` deliberately does
    // nothing here: popping on it would throw the journalist out of the
    // article every time they paused typing.
    if (state.status == ArticleEditorStatus.saved) {
      Navigator.pop(context);
      return;
    }
    if (state.status == ArticleEditorStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ArticleFailureText.messageFor(state.error))),
      );
    }
  }

  /// Keeps the text fields in sync with an article loaded asynchronously.
  void _fillControllersWith(ArticleEditorState state) {
    if (_titleController.text != state.article.title) {
      _titleController.text = state.article.title;
    }
    if (_descriptionController.text != state.article.description) {
      _descriptionController.text = state.article.description;
    }
    if (_contentController.text != state.article.content) {
      _contentController.text = state.article.content;
    }
  }

  /// Placeholder for the image picker: it hands the use case a valid in memory
  /// image so the upload flow can be exercised before the picker is added.
  void _attachSampleThumbnail(BuildContext context) {
    context.read<ArticleEditorCubit>().uploadThumbnail(
          ArticleThumbnailEntity(
            fileName: 'cover.jpg',
            bytes: Uint8List(64 * 1024),
          ),
        );
  }
}
