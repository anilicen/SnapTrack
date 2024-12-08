// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart' hide View;
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter_svg/svg.dart';
import 'package:st/src/app/constants.dart';
import 'package:st/src/app/navigator.dart';

import 'core_controller.dart';

class CoreView extends View {
  @override
  State<StatefulWidget> createState() {
    return _CoreViewState(
      CoreController(),
    );
  }
}

class _CoreViewState extends ViewState<CoreView, CoreController> {
  _CoreViewState(CoreController controller) : super(controller);

  @override
  Widget get view {
    Size size = MediaQuery.of(context).size;
    EdgeInsets padding = MediaQuery.of(context).padding;
    return ControlledWidgetBuilder<CoreController>(
      builder: (context, controller) {
        return WillPopScope(
          onWillPop: () async {
            return controller.handleOnWillPop();
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            key: globalKey,
            body: SizedBox(
              width: size.width,
              height: size.height,
              child: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: controller.pageController,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        for (Widget page in controller.pages) page,
                      ],
                    ),
                  ),
                  _NavigationBar(size, padding),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavigationBar extends StatelessWidget {
  final EdgeInsets padding;
  final Size size;

  const _NavigationBar(
    this.size,
    this.padding,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + padding.bottom,
      width: size.width,
      color: kWhite,
      padding: EdgeInsets.only(
        bottom: padding.bottom,
        left: 20,
        right: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ControlledWidgetBuilder<CoreController>(
            builder: (context, controller) => _NavigationBarItemButton(
              iconPath: controller.navigationItems[0]['iconPath'],
              onPressed: controller.onNavigationItemTap,
              index: 0,
              width: 55,
              isSelected: controller.selectedIndex == 0,
            ),
          ),
          _NavigationBarItemButton(
            iconPath: 'add-new-route.svg',
            onPressed: () => STNavigator.navigateToCreateRouteInfoView(),
            width: 55,
            isSelected: false,
          ),
          ControlledWidgetBuilder<CoreController>(
            builder: (context, controller) => _NavigationBarItemButton(
              iconPath: controller.navigationItems[1]['iconPath'],
              onPressed: controller.onNavigationItemTap,
              index: 1,
              width: 55,
              isSelected: controller.selectedIndex == 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationBarItemButton extends StatelessWidget {
  final String iconPath;
  final Function onPressed;
  final int? index;
  final bool isSelected;
  final double width;

  _NavigationBarItemButton({
    required this.iconPath,
    required this.onPressed,
    this.index,
    required this.isSelected,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected ? kPrimaryColor : kDeactiveColor;
    return Container(
      width: width,
      height: 64,
      child: TextButton(
        style: ButtonStyle(
          overlayColor: MaterialStateColor.resolveWith((_) => Colors.transparent),
        ),
        onPressed: () => index == null ? onPressed() : onPressed(index),
        child: Container(
          height: 35,
          child: SvgPicture.asset(
            'assets/icons/$iconPath',
            color: color,
          ),
        ),
      ),
    );
  }
}
