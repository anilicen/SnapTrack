import 'package:flutter/material.dart' hide View;
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:st/src/app/constants.dart';

import 'splash_controller.dart';

class SplashView extends View {
  @override
  State<StatefulWidget> createState() {
    return _SplashViewState(
      SplashController(),
    );
  }
}

class _SplashViewState extends ViewState<SplashView, SplashController> {
  _SplashViewState(SplashController controller) : super(controller);

  @override
  Widget get view {
    return Scaffold(
      key: globalKey,
      backgroundColor: kPrimaryColor,
      body: Center(
        child: CircularProgressIndicator(color: kWhite),
      ),
    );
  }
}
