import 'package:calq_abiturnoten/database/database.dart';
import 'package:calq_abiturnoten/ui/Screens/exams/exam_screen.dart';
import 'package:calq_abiturnoten/ui/Screens/newGrade/add_grade_screen.dart';
import 'package:calq_abiturnoten/ui/Screens/overview_screen.dart';
import 'package:calq_abiturnoten/ui/Screens/subjectList/subjects_screen.dart';
import 'package:calq_abiturnoten/ui/components/styling.dart';
import 'package:flutter/material.dart';

import 'ui/Screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DatabaseClass.initDb().then((value) {
    DatabaseClass.Shared.getSettings(); // Init Settings
    // Force Database load before App starts
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void initState() {
    DatabaseClass.Shared.fetchSubjects().then((value) {
      // print(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calq Abiturnotenrechner',
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: calqColor,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: calqColor,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
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
                color: Theme.of(context)
                    .colorScheme
                    .inversePrimary
                    .withOpacity(0.4),
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
