import 'package:flutter/material.dart';
import 'package:st/src/app/constants.dart';
import 'package:st/src/app/pages/splash/splash_view.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kBackgroundColor,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: SplashView(),
    );
  }
}
