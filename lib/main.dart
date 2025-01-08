import 'package:flutter/material.dart';

import 'Screens/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 5,
        child: Scaffold(
            /* appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
               title: Text(widget.title),
            ),*/
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
            body: TabBarView(
              children: [
                SettingsScreen(),
                SettingsScreen(),
                SettingsScreen(),
                SettingsScreen(),
                SettingsScreen(),
              ],
            )));
  }
}
