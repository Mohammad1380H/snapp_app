import 'package:flutter/material.dart';
import 'package:snapp_app/map_screen.dart';
import 'package:snapp_app/res/dimens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                fixedSize: const MaterialStatePropertyAll(
                    Size(double.infinity, Dimens.larg * 2.1)),
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimens.medium))),
                elevation: const MaterialStatePropertyAll(0),
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return const Color.fromARGB(255, 161, 219, 163);
                  }
                  return const Color.fromARGB(255, 150, 238, 96);
                }))),
        primarySwatch: Colors.blue,
      ),
      home: const MappScreen(),
    );
  }
}
