// import 'package:flutter/material.dart';

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(title: const Text('Student Profile')),
//         body: const Center(
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             Icon(Icons.sports_soccer, size: 72),
//             SizedBox(height: 16),
//             Text('Joseph', style: TextStyle(fontSize: 24)),
//             Text('Mobile Programming - Week 1'),
//           ]),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

void main() {
  runApp(const StudentProfileApp());
}

class StudentProfileApp extends StatelessWidget {
  const StudentProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Student Profile'),
          backgroundColor: Colors.blue,
        ),
        body: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text('Name: Joseph', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              // Required Element 1: Student ID
              Text('Student ID: 244107020242', style: TextStyle(fontSize: 18, color: Colors.grey)),
              SizedBox(height: 10),
              // Required Element 2: Additional Info
              Text('Major: Informatics Engineering', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
