import 'package:flutter/material.dart' hide View;
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:st/src/app/constants.dart';
import 'package:st/src/app/navigator.dart';
import 'package:st/src/app/widgets/action_bar.dart';
import 'package:st/src/app/widgets/primary_icon_button.dart';

import 'create_route_info_controller.dart';

class CreateRouteInfoView extends View {
  @override
  State<StatefulWidget> createState() {
    return _CreateRouteInfoViewState(
      CreateRouteInfoController(),
    );
  }
}

class _CreateRouteInfoViewState extends ViewState<CreateRouteInfoView, CreateRouteInfoController> {
  _CreateRouteInfoViewState(CreateRouteInfoController controller) : super(controller);

  @override
  Widget get view {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: kWhite,
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Column(
          children: [
            SizedBox(
              width: size.width,
              height: size.width / 1.16,
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/maps_preview.png',
                    width: size.width,
                    height: size.width / 1.16,
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.center,
                  ),
                  Positioned(
                    left: 15,
                    top: padding.top + 15,
                    child: PrimaryIconButton(
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Create New Route",
                      textAlign: TextAlign.center,
                      style: kTitleStyle(),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Design your own challenge by creating a unique route. Choose your checkpoints, visit each location, and capture the essence with a unique photo. It's about the stories you create along the way. Start your journey today! Also, don't forget to share your new route with your friends at the end!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ActionBar(
              text: 'Start Creating Route',
              onPressed: () => STNavigator.navigateToCreateRouteView(context),
              isButtonEnabled: true,
              isButtonLoading: false,
            )
          ],
        ),
      ),
    );
  }
}
