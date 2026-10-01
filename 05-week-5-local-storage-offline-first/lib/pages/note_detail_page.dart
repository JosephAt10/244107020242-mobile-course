import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/app_providers.dart';
import '../data/local/note.dart';

final noteDetailProvider = FutureProvider.family<Note?, int>(
    (ref, id) => ref.watch(noteRepositoryProvider).getNote(id));

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.noteId});
  final int noteId;

  Future<void> _edit(BuildContext context, WidgetRef ref, Note note) async {
    final titleController = TextEditingController(text: note.title);
    final bodyController = TextEditingController(text: note.body);
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit note'),
        content: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a title'
                      : null),
              TextField(
                  controller: bodyController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Note')),
            ])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Save')),
        ],
      ),
    );
    if (saved == true) {
      await ref.read(notesProvider.notifier).saveNote(noteId,
          title: titleController.text.trim(), body: bodyController.text.trim());
      ref.invalidate(noteDetailProvider(noteId));
    }
    titleController.dispose();
    bodyController.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(title: const Text('Note details')),
        body: ref.watch(noteDetailProvider(noteId)).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  const Center(child: Text('Could not open this note.')),
              data: (note) {
                if (note == null) {
                  return const Center(
                      child: Text('This note no longer exists.'));
                }
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(note.title,
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        Text('Updated ${note.updatedAt.toLocal()}'),
                        if (note.dirty)
                          const Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Chip(label: Text('Unsynced'))),
                        const Divider(height: 32),
                        Expanded(
                            child: SingleChildScrollView(
                                child: Text(
                                    note.body.isEmpty
                                        ? 'No additional text.'
                                        : note.body,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge))),
                        Row(children: [
                          OutlinedButton.icon(
                              onPressed: () => _edit(context, ref, note),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Edit')),
                          const SizedBox(width: 12),
                          TextButton.icon(
                              onPressed: () async {
                                await ref
                                    .read(notesProvider.notifier)
                                    .delete(noteId);
                                if (context.mounted) context.pop();
                              },
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete')),
                        ]),
                      ]),
                );
              },
            ),
      );
}
