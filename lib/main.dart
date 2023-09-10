import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'entities/code.dart';
import 'i18n.dart';
import 'pages/main.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(CodeAdapter());
  await Hive.openBox<Code>('codes');
  await Hive.openBox('settings');

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    AppLocalJsonLocalization.delegate.directories = ['i18n'];

    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      return MaterialApp(
        localizationsDelegates: [
          // delegate from flutter_localization
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          // delegate from localization package.
          AppLocalJsonLocalization.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
        ],
        theme: ThemeData(
          colorScheme: (lightDynamic ??
                  ColorScheme.fromSeed(
                    seedColor: Colors.deepPurple,
                    brightness: Brightness.light,
                  ))
              .harmonized(),
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorScheme: (darkDynamic ??
                  ColorScheme.fromSeed(
                    seedColor: Colors.deepPurple,
                    brightness: Brightness.dark,
                  ))
              .harmonized(),
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        home: const MainPage(),
      );
    });
  }
}
