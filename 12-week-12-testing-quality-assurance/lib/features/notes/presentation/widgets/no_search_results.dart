import 'package:flutter/material.dart';

class NoSearchResults extends StatelessWidget {
  const NoSearchResults({
    super.key,
    required this.query,
    required this.onClear,
  });

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 48),
          const SizedBox(height: 12),
          Text('No notes match "$query".'),
          TextButton(onPressed: onClear, child: const Text('Clear search')),
        ],
      ),
    ),
  );
}
