// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'StartPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShapeShift',
      theme: ThemeData(
        brightness: Brightness.dark,
        visualDensity: VisualDensity.standard,
        //primaryColorBrightness: Brightness.dark,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) return Colors.grey;
              return null;
            }),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) return Colors.grey;
              return null;
            }),
          ),
        ),
        primarySwatch: Colors.red,
        primaryColor: Colors.red,
        primaryColorLight: Colors.red,
        primaryColorDark: Colors.red,
        //accentColor: Colors.redAccent,
        shadowColor: Colors.red,
        //bottomAppBarColor: Colors.red,
        cardColor: Colors.red,
        hoverColor: Colors.red,
        highlightColor: Colors.red,
        dialogBackgroundColor: Colors.red,
        indicatorColor: Colors.red,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.red,
          ),
          displayMedium: TextStyle(
            color: Colors.grey,
          ),
          displaySmall: TextStyle(
            color: Colors.red,
          ),
          headlineMedium: TextStyle(
            color: Colors.grey,
          ),
          headlineSmall: TextStyle(
            color: Colors.red,
          ),
          titleLarge: TextStyle(
            color: Colors.grey,
          ),
          bodySmall: TextStyle(
            color: Colors.grey,
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return null;
            }
            if (states.contains(MaterialState.selected)) {
              return Colors.red;
            }
            return null;
          }),
          trackColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return null;
            }
            if (states.contains(MaterialState.selected)) {
              return Colors.red;
            }
            return null;
          }),
        ),
        radioTheme: RadioThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return null;
            }
            if (states.contains(MaterialState.selected)) {
              return Colors.red;
            }
            return null;
          }),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return null;
            }
            if (states.contains(MaterialState.selected)) {
              return Colors.red;
            }
            return null;
          }),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const StartPage(),
        '/start': (context) => const StartPage(),
      },
    );
  }
}
