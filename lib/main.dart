import 'package:flutter/material.dart';

void main() {
  runApp(const HachiApp());
}

class HachiApp extends StatelessWidget {
  const HachiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hachi Wardrobe',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hachi Wardrobe'),
      ),
      body: const Center(
        child: Text('Welcome to Hachi Wardrobe\n(placeholder MVP)'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
