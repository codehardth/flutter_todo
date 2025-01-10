import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/todo_provider.dart';
import 'routes/route.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      onGenerateRoute: Routes.generateRoute,
      initialRoute: Routes.initialRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
