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


import 'package:flutter/material.dart';

const double kWideBreakpoint = 700;
const Key themeToggleKey = Key('theme-toggle');

void main() => runApp(const DashboardApp());

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  ThemeMode themeMode = ThemeMode.light;

  ThemeData buildTheme(Brightness brightness) {
    final colors = ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academic Overview',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: themeMode,
      home: AcademicOverviewPage(
        isDark: themeMode == ThemeMode.dark,
        onThemeChanged: (isDark) {
          setState(() {
            themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
          });
        },
      ),
    );
  }
}

class AcademicOverviewPage extends StatelessWidget {
  const AcademicOverviewPage({
    required this.isDark,
    required this.onThemeChanged,
    super.key,
  });

  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academic Overview')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= kWideBreakpoint;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileHeader(
                  isDark: isDark,
                  onThemeChanged: onThemeChanged,
                ),
                const SizedBox(height: 28),
                Text(
                  'Academic progress',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                DashboardCards(isWide: isWide),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.isDark,
    required this.onThemeChanged,
    super.key,
  });

  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            child: const Icon(Icons.person),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Semantics(
              label: 'Student profile: Joseph Atem Deng, Mobile Programming, Sem Ganjil 2026',
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Joseph Atem Deng',
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge?.copyWith(
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      'Mobile Programming - Sem Ganjil 2026',
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Semantics(
            label: isDark ? 'Switch to light theme' : 'Switch to dark theme',
            toggled: isDark,
            child: Switch.adaptive(
              key: themeToggleKey,
              value: isDark,
              onChanged: onThemeChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardCards extends StatelessWidget {
  const DashboardCards({required this.isWide, super.key});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      const InfoCard(
        title: 'Current GPA',
        value: '3.72',
        icon: Icons.auto_graph,
      ),
      const InfoCard(
        title: 'Credits completed',
        value: '35 of 144',
        icon: Icons.school_outlined,
      ),
      const InfoCard(
        title: 'Attendance',
        value: '96%',
        icon: Icons.fact_check_outlined,
      ),
      const InfoCard(
        title: 'Upcoming assignments',
        value: '3 due this week',
        icon: Icons.assignment_outlined,
      ),
      const InfoCard(
        title: 'Research hours',
        value: '14 this month',
        icon: Icons.science_outlined,
      ),
      const InfoCard(
        title: 'Library books',
        value: '2 checked out',
        icon: Icons.menu_book_outlined,
      ),
    ];

    if (!isWide) {
      return Column(
        key: const Key('narrow-layout'),
        children: addGaps(cards),
      );
    }

    return Row(
      key: const Key('wide-layout'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: addGaps([cards[0], cards[2], cards[4]]),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: addGaps([cards[1], cards[3], cards[5]]),
          ),
        ),
      ],
    );
  }

  List<Widget> addGaps(List<Widget> cards) {
    return [
      for (var index = 0; index < cards.length; index++) ...[
        cards[index],
        if (index < cards.length - 1) const SizedBox(height: 16),
      ],
    ];
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    super.key,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      label: '$title: $value',
      child: Card(
        margin: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: colors.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text(value, style: textTheme.titleLarge),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}