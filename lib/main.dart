import 'package:calq_abiturnoten/database/database.dart';
import 'package:calq_abiturnoten/ui/Screens/add_grade_screen.dart';
import 'package:calq_abiturnoten/ui/Screens/exam_screen.dart';
import 'package:calq_abiturnoten/ui/Screens/overview_screen.dart';
import 'package:calq_abiturnoten/ui/Screens/subjects_screen.dart';
import 'package:flutter/material.dart';

import 'ui/Screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DatabaseClass.initDb().then((value) {
    // Force Database load before App starts
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  void initState() {
    //  DatabaseClass.Shared.createSubject();
    DatabaseClass.Shared.getSubjects().then((value) {
      // print(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calq Abiturnotenrechner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Calq'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 5,
        child: Scaffold(
            bottomNavigationBar: Container(
                color: Theme.of(context).colorScheme.inversePrimary,
                child: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.bar_chart)),
                    Tab(icon: Icon(Icons.book_outlined)),
                    Tab(icon: Icon(Icons.add)),
                    Tab(icon: Icon(Icons.library_books)),
                    Tab(icon: Icon(Icons.settings))
                  ],
                )),
            body: const TabBarView(
              children: [
                OverviewScreen(),
                SubjectsScreen(),
                AddGradeScreen(),
                ExamScreen(),
                SettingsScreen(),
              ],
            )));
  }
}
