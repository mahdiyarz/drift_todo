import 'package:drift_todo/database/my_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => MyDatabase().taskDao,
      child: const MaterialApp(
        title: 'Task Management',
        home: HomeScreen(),
      ),
    );
  }
}
