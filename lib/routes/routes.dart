import 'package:flutter/material.dart';
import 'package:sql_edit/screens/home/HomeScreen.dart';
import 'package:sql_edit/screens/sqlEditScreen/SqlEditScreen.dart';
import 'package:sql_edit/screens/settings/SettingsScreen.dart';
import 'package:sql_edit/screens/about/AboutScreen.dart';
import 'package:sql_edit/screens/database/DatabaseManagerScreen.dart';

class AppRoutes {
  static const String home = '/';
  static const String sqlEditor = '/sql-editor';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String databaseManager = '/database-manager';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const HomeScreen(),
    sqlEditor: (context) => const SqlEditorScreen(),
    settings: (context) => const SettingsScreen(),
    about: (context) => const AboutScreen(),
    databaseManager: (context) => const DatabaseManagerScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
          settings: settings,
        );
      case sqlEditor:
        return MaterialPageRoute(
          builder: (context) => const SqlEditorScreen(),
          settings: settings,
        );
      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (context) => const SettingsScreen(),
          settings: settings,
        );
      case AppRoutes.about:
        return MaterialPageRoute(
          builder: (context) => const AboutScreen(),
          settings: settings,
        );
      case AppRoutes.databaseManager:
        return MaterialPageRoute(
          builder: (context) => const DatabaseManagerScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
          settings: settings,
        );
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: const Center(
          child: Text('The requested page could not be found.'),
        ),
      ),
    );
  }
}
