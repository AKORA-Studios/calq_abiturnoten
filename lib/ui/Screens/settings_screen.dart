import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Settings"),
        ),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: ListView(
            children: const [
              ListTile(
                title: Text("Anzahl Prüfungen"),
                tileColor: Colors.orange,
              ),
              ListTile(
                title: Text("Anzahl Prüfungen"),
                tileColor: Colors.orange,
              ),
              ListTile(
                title: Text("Regenbogen"),
                tileColor: Colors.orange,
              ),
              Text("Noten importieren"),
              Text("Noten exportieren")
            ],
          ),
        ));
  }
}
