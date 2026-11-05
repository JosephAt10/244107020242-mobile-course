import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_providers.dart';
import '../features/ai/presentation/providers/ai_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(darkModeProvider);
    final lastOpened = ref.watch(lastOpenedProvider);
    final offline = ref.watch(forceOfflineProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AiKeySettingsCard(),
          SwitchListTile(
            title: const Text('Dark theme'),
            subtitle: const Text('Saved on this device'),
            value: theme.valueOrNull ?? false,
            onChanged: theme.isLoading
                ? null
                : (_) => ref.read(darkModeProvider.notifier).toggle(),
          ),
          SwitchListTile(
            title: const Text('Force offline mode'),
            subtitle: const Text('Disable simulated sync and network refresh'),
            value: offline,
            onChanged: (value) =>
                ref.read(forceOfflineProvider.notifier).state = value,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Last opened'),
            subtitle: lastOpened.when(
              data: (value) => Text(
                value == null
                    ? 'Not recorded yet'
                    : DateTime.tryParse(value)?.toLocal().toString() ?? value,
              ),
              loading: () => const Text('Loading…'),
              error: (error, stack) => const Text('Unavailable'),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.storage_outlined),
            title: Text('Storage'),
            subtitle: Text(
              'SharedPreferences for settings; SQLite for notes and cached posts.',
            ),
          ),
        ],
      ),
    );
  }
}

class AiKeySettingsCard extends ConsumerStatefulWidget {
  const AiKeySettingsCard({super.key});

  @override
  ConsumerState<AiKeySettingsCard> createState() => _AiKeySettingsCardState();
}

class _AiKeySettingsCardState extends ConsumerState<AiKeySettingsCard> {
  final _controller = TextEditingController();
  bool _saving = false;
  bool _obscure = true;
  String? _message;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      await ref.read(secureApiKeyStoreProvider).save(_controller.text);
      _controller.clear();
      ref.invalidate(hasAiApiKeyProvider);
      if (mounted) {
        setState(() => _message = 'API key saved securely on this device.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'Could not save the API key. Try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _remove() async {
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      await ref.read(secureApiKeyStoreProvider).delete();
      ref.invalidate(hasAiApiKeyProvider);
      if (mounted) {
        setState(() => _message = 'API key removed from this device.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'Could not remove the API key. Try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyStatus = ref.watch(hasAiApiKeyProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gemini API key',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            keyStatus.when(
              data: (hasKey) => Text(
                hasKey ? 'Key is saved on this device.' : 'No key saved.',
              ),
              loading: () => const Text('Checking secure storage…'),
              error: (error, stack) =>
                  const Text('Secure storage is unavailable.'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              obscureText: _obscure,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: 'Paste your Gemini API key',
                helperText:
                    'Never share this key or commit it to source control.',
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Show key while entering' : 'Hide key',
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 8),
              Text(_message!),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Saving…' : 'Save key'),
                ),
                TextButton(
                  onPressed: _saving ? null : _remove,
                  child: const Text('Remove saved key'),
                ),
              ],
            ),
            const Text(
              'Lab note: direct mobile API calls are for this learning demo. '
              'Use a server proxy in production.',
            ),
          ],
        ),
      ),
    );
  }
}

final lastOpenedProvider = FutureProvider<String?>(
  (ref) => ref.watch(prefsRepositoryProvider).getLastOpened(),
);
