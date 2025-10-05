import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/resume_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  runApp(const ProviderScope(child: MyApp()));
  await Hive.init();
  var box = Hive.openBox("newbox");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customizable Resume Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const ResumeScreen(),
    );
  }
}
