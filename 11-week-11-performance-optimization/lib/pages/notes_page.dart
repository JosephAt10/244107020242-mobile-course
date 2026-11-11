import 'dart:async';

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
  Widget build(BuildContext context) => Scaffold(
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
    body: const Column(
      children: [
        OfflineStatusBanner(),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: DebouncedNotesSearchField(),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SyncStatusAndAction(),
        ),
        Expanded(child: NotesListView()),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _addNote,
      icon: const Icon(Icons.add),
      label: const Text('New note'),
    ),
  );
}

/// Only this banner rebuilds when the offline-mode switch changes.
class OfflineStatusBanner extends ConsumerWidget {
  const OfflineStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(forceOfflineProvider);
    return MaterialBanner(
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
    );
  }
}

/// Debouncing keeps a long notes list from being filtered on every keystroke.
class DebouncedNotesSearchField extends ConsumerStatefulWidget {
  const DebouncedNotesSearchField({super.key});

  @override
  ConsumerState<DebouncedNotesSearchField> createState() =>
      _DebouncedNotesSearchFieldState();
}

class _DebouncedNotesSearchFieldState
    extends ConsumerState<DebouncedNotesSearchField> {
  static const _debounceDelay = Duration(milliseconds: 250);

  final _controller = TextEditingController();
  Timer? _debounce;
  bool _hasText = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() => _hasText = value.isNotEmpty);
    _debounce?.cancel();
    _debounce = Timer(
      _debounceDelay,
      () => ref.read(noteSearchQueryProvider.notifier).state = value,
    );
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    setState(() => _hasText = false);
    ref.read(noteSearchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    onChanged: _onChanged,
    decoration: InputDecoration(
      hintText: 'Search note titles',
      prefixIcon: const Icon(Icons.search),
      suffixIcon: _hasText
          ? IconButton(
              tooltip: 'Clear search',
              onPressed: _clear,
              icon: const Icon(Icons.clear),
            )
          : null,
      border: const OutlineInputBorder(),
    ),
  );
}

/// The sync count and offline action update independently of the note list.
class SyncStatusAndAction extends ConsumerWidget {
  const SyncStatusAndAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dirtyCount = ref.watch(dirtyCountProvider);
    final offline = ref.watch(forceOfflineProvider);
    return Row(
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
            error: (error, stack) => const Text('Sync status unavailable'),
          ),
        ),
        OutlinedButton.icon(
          onPressed: offline
              ? null
              : () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final count = await ref.read(notesProvider.notifier).sync();
                    if (!context.mounted) return;
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
                    if (!context.mounted) return;
                    messenger.showSnackBar(
                      SnackBar(content: Text('Sync failed: $error')),
                    );
                  }
                },
          icon: const Icon(Icons.sync),
          label: const Text('Sync'),
        ),
      ],
    );
  }
}

/// Keeps filtering and scroll paints within the list subtree.
class NotesListView extends ConsumerWidget {
  const NotesListView({super.key});

  void _clearSearch(WidgetRef ref) {
    ref.read(noteSearchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final query = ref.watch(noteSearchQueryProvider);
    return RepaintBoundary(
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
            searchNotesProvider((notes: items, query: query)),
          );
          if (visibleItems.isEmpty) {
            return NoSearchResults(
              query: query.trim(),
              onClear: () => _clearSearch(ref),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: visibleItems.length,
            itemBuilder: (context, index) {
              final note = visibleItems[index];
              return NoteTile(
                note: note,
                onTap: () => context.push('/note/${note.id}'),
                onDelete: () =>
                    ref.read(notesProvider.notifier).delete(note.id!),
              );
            },
          );
        },
      ),
    );
  }
}
