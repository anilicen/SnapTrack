import 'package:flutter/cupertino.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:st/src/app/pages/core/core_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:st/src/app/pages/register/register_view.dart';

class SplashController extends Controller {
  SplashController();

  final auth = FirebaseAuth.instance;

  @override
  void onInitState() {
    Future.delayed(Duration(milliseconds: 500)).then((_) {
      Navigator.pushAndRemoveUntil(
        getContext(),
        CupertinoPageRoute(
          builder: (context) => auth.currentUser == null ? RegisterView() : CoreView(),
        ),
        (_) => false,
      );
    });
    super.onInitState();
  }

  @override
  void initListeners() {}
}
