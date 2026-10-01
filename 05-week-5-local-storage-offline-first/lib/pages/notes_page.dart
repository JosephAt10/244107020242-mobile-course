import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/app_providers.dart';
import '../widgets/note_tile.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(prefsRepositoryProvider).markOpenedNow());
  }

  Future<void> _addNote() async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New note'),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a title'
                  : null,
            ),
            TextField(
                controller: bodyController,
                decoration: const InputDecoration(labelText: 'Note')),
          ]),
        ),
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == true && mounted) {
      await ref.read(notesProvider.notifier).add(
            title: titleController.text.trim(),
            body: bodyController.text.trim(),
          );
    }
    titleController.dispose();
    bodyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    final dirtyCount = ref.watch(dirtyCountProvider);
    final offline = ref.watch(forceOfflineProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          IconButton(
              tooltip: 'Cached posts',
              onPressed: () => context.push('/posts'),
              icon: const Icon(Icons.article_outlined)),
          IconButton(
              tooltip: 'Settings',
              onPressed: () => context.push('/settings'),
              icon: const Icon(Icons.settings_outlined)),
        ],
      ),
      body: Column(children: [
        MaterialBanner(
          content: Text(offline
              ? 'Offline demo is on. Local notes still work.'
              : 'Online mode. Notes are stored on this device.'),
          leading: Icon(
              offline ? Icons.cloud_off_outlined : Icons.cloud_done_outlined),
          actions: [
            TextButton(
              onPressed: () =>
                  ref.read(forceOfflineProvider.notifier).state = !offline,
              child: Text(offline ? 'Go online' : 'Go offline'),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(children: [
            Expanded(
              child: dirtyCount.when(
                data: (count) => Text(
                    count == 0
                        ? 'All notes synced'
                        : '$count unsynced ${count == 1 ? 'note' : 'notes'}',
                    style: Theme.of(context).textTheme.titleSmall),
                loading: () => const Text('Checking sync queue…'),
                error: (error, stack) => const Text('Sync status unavailable'),
              ),
            ),
            OutlinedButton.icon(
              onPressed: offline
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        final count =
                            await ref.read(notesProvider.notifier).sync();
                        if (!mounted) return;
                        messenger.showSnackBar(SnackBar(
                            content: Text(count == 0
                                ? 'No pending notes to sync'
                                : 'Synced $count ${count == 1 ? 'note' : 'notes'}')));
                      } catch (error) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                            SnackBar(content: Text('Sync failed: $error')));
                      }
                    },
              icon: const Icon(Icons.sync),
              label: const Text('Sync'),
            ),
          ]),
        ),
        Expanded(
          child: notes.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Could not load notes.'),
                TextButton(
                    onPressed: () => ref.invalidate(notesProvider),
                    child: const Text('Try again')),
              ]),
            ),
            data: (items) => items.isEmpty
                ? const Center(
                    child: Text('No notes yet. Add one to get started.'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: items.length,
                    itemBuilder: (context, index) => NoteTile(
                      note: items[index],
                      onTap: () => context.push('/note/${items[index].id}'),
                      onDelete: () => ref
                          .read(notesProvider.notifier)
                          .delete(items[index].id!),
                    ),
                  ),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: _addNote,
          icon: const Icon(Icons.add),
          label: const Text('New note')),
    );
  }
}
