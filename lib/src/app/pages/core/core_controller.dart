import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:st/src/app/pages/profile/profile_view.dart';
import 'package:st/src/app/pages/routes/routes_view.dart';
import 'package:st/src/data/helpers/dynamic_link_helper.dart';

class CoreController extends Controller {
  CoreController._internal();
  static final _instance = CoreController._internal();
  factory CoreController() => _instance;

  BuildContext get coreContext => getContext();

  final routesPageKey = GlobalKey<NavigatorState>();
  final profilePageKey = GlobalKey<NavigatorState>();

  late List<Widget> pages;
  List<Map<String, dynamic>> navigationItems = [
    {'iconPath': 'routes.svg'},
    {'iconPath': 'profile.svg'},
  ];

  PageController pageController = PageController();
  int selectedIndex = 0;

  @override
  // It has vital importance, do not remove
  // ignore: must_call_super
  void onDisposed() {}

  @override
  void onInitState() async {
    selectedIndex = 0;
    pages = [
      Navigator(
        key: routesPageKey,
        pages: [MaterialPage(child: RoutesViewHolder())],
        onPopPage: (route, result) => route.didPop(result),
      ),
      Navigator(
        key: profilePageKey,
        pages: [MaterialPage(child: ProfileViewHolder())],
        onPopPage: (route, result) => route.didPop(result),
      ),
    ];

    DynamicLinkHelper.initDynamicLinks();
  }

  @override
  void initListeners() {}

  void onNavigationItemTap(int index) async {
    if (index == 0 && selectedIndex == 0) {
      try {
        await routesPageKey.currentState!.maybePop();
      } catch (e) {}
      return;
    }

    if (index == 1 && selectedIndex == 1) {
      try {
        await profilePageKey.currentState!.maybePop();
      } catch (e) {}
      return;
    }

    selectedIndex = index;
    pageController.jumpToPage(index);
    refreshUI();
  }

  Future<bool> handleOnWillPop() async {
    bool routesPop = false;
    bool profilePop = false;

    try {
      if (selectedIndex == 0) routesPop = await routesPageKey.currentState!.maybePop();
    } catch (e) {}
    try {
      if (selectedIndex == 1) profilePop = await profilePageKey.currentState!.maybePop();
    } catch (e) {}

    if (routesPop || profilePop) return false;

    return true;
  }
}
