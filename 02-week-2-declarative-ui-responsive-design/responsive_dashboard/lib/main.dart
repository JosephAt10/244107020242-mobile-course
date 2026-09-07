// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// void main() {
//   runApp(const DashboardApp());
// }

// class DashboardApp extends StatefulWidget {
//   const DashboardApp({super.key});

//   @override
//   State<DashboardApp> createState() => _DashboardAppState();
// }

// class _DashboardAppState extends State<DashboardApp> {
//   bool isDark = false;

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,

//       // Light theme
//       theme: ThemeData(
//         useMaterial3: true,
//         colorSchemeSeed: Colors.indigo,
//       ),

//       // Dark theme
//       darkTheme: ThemeData(
//         useMaterial3: true,
//         brightness: Brightness.dark,
//         colorSchemeSeed: Colors.indigo,
//       ),

//       // Use the switch to control the theme
//       themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

//       home: DashboardPage(
//         isDark: isDark,
//         onDarkChanged: (value) {
//           setState(() {
//             isDark = value;
//           });
//         },
//       ),
//     );
//   }
// }

// class DashboardPage extends StatelessWidget {
//   const DashboardPage({
//     required this.isDark,
//     required this.onDarkChanged,
//     super.key,
//   });

//   final bool isDark;
//   final ValueChanged<bool> onDarkChanged;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Student Dashboard'),

//         actions: [
//           Row(
//             children: [
//               Icon(
//                 isDark ? Icons.dark_mode : Icons.light_mode,
//               ),

//               const SizedBox(width: 4),

//               CupertinoSwitch(
//                 value: isDark,
//                 onChanged: onDarkChanged,
//               ),

//               const SizedBox(width: 12),
//             ],
//           ),
//         ],
//       ),

//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           // 2 columns on wider screens,
//           // 1 column on smaller screens.
//           final columns = constraints.maxWidth >= 700 ? 2 : 1;

//           return GridView.count(
//             padding: const EdgeInsets.all(16),

//             crossAxisCount: columns,

//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,

//             childAspectRatio: 2.6,

//             children: const [
//               DashboardCard(
//                 title: 'Assignments',
//                 value: '8',
//               ),

//               DashboardCard(
//                 title: 'Attendance',
//                 value: '92%',
//               ),

//               DashboardCard(
//                 title: 'Portfolio',
//                 value: 'Ready',
//               ),

//               DashboardCard(
//                 title: 'Current Week',
//                 value: '02',
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class DashboardCard extends StatelessWidget {
//   const DashboardCard({
//     required this.title,
//     required this.value,
//     super.key,
//   });

//   final String title;
//   final String value;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(20),

//         child: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 title,
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//             ),

//             Text(
//               value,
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';

// void main() => runApp(const DashboardApp());

// class DashboardApp extends StatefulWidget {
//   const DashboardApp({super.key});

//   @override
//   State<DashboardApp> createState() => _DashboardAppState();
// }

// class _DashboardAppState extends State<DashboardApp> {
//   bool isDark = false;

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
//       darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: Colors.indigo),
//       themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
//       home: DashboardPage(
//         isDark: isDark,
//         onDarkChanged: (value) => setState(() => isDark = value),
//       ),
//     );
//   }
// }

// class DashboardPage extends StatelessWidget {
//   const DashboardPage({
//     required this.isDark,
//     required this.onDarkChanged,
//     super.key,
//   });
//   final bool isDark;
//   final ValueChanged<bool> onDarkChanged;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Student Dashboard'),
//         actions: [
//           Row(
//             children: [
//               Icon(isDark ? Icons.dark_mode : Icons.light_mode),
//               const SizedBox(width: 4),
//               Semantics(
//                 label: isDark ? 'Dark mode is on. Double tap to switch to light mode.' : 'Light mode is on. Double tap to switch to dark mode.',
//                 child: CupertinoSwitch(
//                   value: isDark,
//                   onChanged: onDarkChanged,
//                 ),
//               ),
//               const SizedBox(width: 12),
//             ],
//           ),
//         ],
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final columns = constraints.maxWidth >= 700 ? 2 : 1;
//           return GridView.count(
//             padding: const EdgeInsets.all(16),
//             crossAxisCount: columns,
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//             childAspectRatio: 2.6,
//             children: const [
//               DashboardCard(title: 'Assignments', value: '8'),
//               DashboardCard(title: 'Attendance', value: '92%'),
//               DashboardCard(title: 'Portfolio', value: 'Ready'),
//               DashboardCard(title: 'Current week', value: '02'),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class DashboardCard extends StatelessWidget {
//   const DashboardCard({required this.title, required this.value, super.key});
//   final String title;
//   final String value;
//   @override
//   Widget build(BuildContext context) {
//     return Semantics(
//       label: '$title: $value',
//       child: Card(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Row(
//             children: [
//               Expanded(child: Text(title)),
//               Text(value, style: Theme.of(context).textTheme.headlineSmall),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Single source of truth for the responsive breakpoint (refactor requirement #3).
const double kWideBreakpoint = 700;

void main() => runApp(const DashboardApp());

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool isDark = false;

  void _toggleTheme(bool value) => setState(() => isDark = value);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academic Overview',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: AcademicOverviewPage(isDark: isDark, onDarkChanged: _toggleTheme),
    );
  }
}

class AcademicOverviewPage extends StatelessWidget {
  const AcademicOverviewPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });

  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Overview'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Semantics(
              label: isDark ? 'Switch to light theme' : 'Switch to dark theme',
              toggled: isDark,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: theme.colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 4),
                  CupertinoSwitch(
                    value: isDark,
                    onChanged: onDarkChanged,
                    activeColor: theme.colorScheme.secondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ProfileHeader(
                name: 'Jo Alumno',
                role: 'BSc Computer Science · Year 2',
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= kWideBreakpoint;

                  const cards = [
                    InfoCard(
                      title: 'Assignments',
                      value: '8',
                      icon: Icons.assignment_outlined,
                    ),
                    InfoCard(
                      title: 'Attendance',
                      value: '92%',
                      icon: Icons.event_available_outlined,
                    ),
                    InfoCard(
                      title: 'Portfolio',
                      value: 'Ready',
                      icon: Icons.folder_open_outlined,
                    ),
                    InfoCard(
                      title: 'Current week',
                      value: '02',
                      icon: Icons.calendar_today_outlined,
                    ),
                  ];

                  if (!isWide) {
                    return Column(
                      children: [
                        for (final card in cards) ...[
                          card,
                          const SizedBox(height: 16),
                        ],
                      ],
                    );
                  }

                  final rows = <Widget>[];
                  for (var i = 0; i < cards.length; i += 2) {
                    final hasSecond = i + 1 < cards.length;
                    rows
                      ..add(
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: cards[i]),
                            const SizedBox(width: 16),
                            Expanded(
                              child:
                                  hasSecond ? cards[i + 1] : const SizedBox(),
                            ),
                          ],
                        ),
                      )
                      ..add(const SizedBox(height: 16));
                  }
                  return Column(children: rows);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.name, required this.role, super.key});

  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Profile: $name, $role',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                name.isNotEmpty ? name[0] : '?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable info card (refactor requirement #1). Colors/sizes come from
/// Theme.of(context) (refactor requirement #2), not hardcoded values.
class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.title,
    required this.value,
    this.icon,
    super.key,
  });

  final String title;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '$title: $value',
      child: Card(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}