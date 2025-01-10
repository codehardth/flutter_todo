import 'package:flutter/material.dart';

import '../pages/home/home_page.dart';
import '../pages/login/login_page.dart';
import 'app_routes.dart';

class Routes {
  const Routes._();

  static const String initialRoute = AppRoutes.homePage;

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
      case AppRoutes.homePage:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );
      default:
        return MaterialPageRoute<dynamic>(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Page not found'),
            ),
            body: const Center(
              child: Text('404'),
            ),
          ),
        );
    }
  }
}
