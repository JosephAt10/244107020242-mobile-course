import 'package:flutter/material.dart';

import '../data/local/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile(
      {super.key,
      required this.note,
      required this.onTap,
      required this.onDelete});

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: ListTile(
          onTap: onTap,
          title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
              note.body.isEmpty
                  ? 'Updated ${_date(note.updatedAt)}'
                  : note.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (note.dirty)
              const Chip(
                  label: Text('Unsynced'),
                  visualDensity: VisualDensity.compact),
            IconButton(
                tooltip: 'Delete note',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline)),
          ]),
        ),
      );

  String _date(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
