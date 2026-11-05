import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/app_providers.dart';
import '../features/notes/presentation/providers/search_providers.dart';
import '../features/notes/presentation/widgets/no_search_results.dart';
import '../widgets/note_tile.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(prefsRepositoryProvider).markOpenedNow());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                decoration: const InputDecoration(labelText: 'Note'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
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
      await ref
          .read(notesProvider.notifier)
          .add(
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
            tooltip: 'AI study chat',
            onPressed: () => context.push('/ai-chat'),
            icon: const Icon(Icons.auto_awesome_outlined),
          ),
          IconButton(
            tooltip: 'Cached posts',
            onPressed: () => context.push('/posts'),
            icon: const Icon(Icons.article_outlined),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          MaterialBanner(
            content: Text(
              offline
                  ? 'Offline demo is on. Local notes still work.'
                  : 'Online mode. Notes are stored on this device.',
            ),
            leading: Icon(
              offline ? Icons.cloud_off_outlined : Icons.cloud_done_outlined,
            ),
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
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search note titles',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: dirtyCount.when(
                    data: (count) => Text(
                      count == 0
                          ? 'All notes synced'
                          : '$count unsynced ${count == 1 ? 'note' : 'notes'}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    loading: () => const Text('Checking sync queue…'),
                    error: (error, stack) =>
                        const Text('Sync status unavailable'),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: offline
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            final count = await ref
                                .read(notesProvider.notifier)
                                .sync();
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  count == 0
                                      ? 'No pending notes to sync'
                                      : 'Synced $count ${count == 1 ? 'note' : 'notes'}',
                                ),
                              ),
                            );
                          } catch (error) {
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(content: Text('Sync failed: $error')),
                            );
                          }
                        },
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync'),
                ),
              ],
            ),
          ),
          Expanded(
            child: notes.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Could not load notes.'),
                    TextButton(
                      onPressed: () => ref.invalidate(notesProvider),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text('No notes yet. Add one to get started.'),
                  );
                }
                final visibleItems = ref.watch(
                  searchNotesProvider((notes: items, query: _searchQuery)),
                );
                if (visibleItems.isEmpty) {
                  return NoSearchResults(
                    query: _searchQuery.trim(),
                    onClear: _clearSearch,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: visibleItems.length,
                  itemBuilder: (context, index) => NoteTile(
                    note: visibleItems[index],
                    onTap: () =>
                        context.push('/note/${visibleItems[index].id}'),
                    onDelete: () => ref
                        .read(notesProvider.notifier)
                        .delete(visibleItems[index].id!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNote,
        icon: const Icon(Icons.add),
        label: const Text('New note'),
      ),
    );
  }
}
