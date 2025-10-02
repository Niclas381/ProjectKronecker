import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // Root widget
      home: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Kronecker Projekt', style: TextStyle(color: Colors.white),),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,        // ← wichtig
            children: [
              const Text('Hallo', style: TextStyle(color: Colors.white, fontSize: 40),),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}