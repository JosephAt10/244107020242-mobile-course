import 'package:flutter/material.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context) {
    final known = <String, (String, String)>{
      '3': ('Schedule changed', 'Mobile class moved to Room A2 at 1:00 PM.'),
      '2': ('Library hours', 'The library is open until 8:00 PM this week.'),
      '1': ('Welcome to campus', 'Your weekly campus digest is ready.'),
    };
    final announcement = known[id] ?? ('Campus announcement', 'Announcement $id');
    return Scaffold(appBar: AppBar(title: const Text('Announcement')),
      body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24),
        child: Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.campaign, size: 42, color: Color(0xFF2457D6)),
          const SizedBox(height: 18),
          Text(announcement.$1, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(announcement.$2, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          Text('Announcement ID · $id', style: Theme.of(context).textTheme.bodySmall),
        ]))))));
  }
}
