import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/features/tum/ui/tum_root_page.dart';
import 'src/core/services/notification_service.dart';
import 'src/core/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.init();
  await NotificationService.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tum - Save & Think',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TumRootPage(),
    );
  }
}
