import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:st/src/app/pages/challenge/challenge_view.dart';
import 'package:st/src/app/pages/challenge_completion/challenge_completion_view.dart';
import 'package:st/src/app/pages/checkpoint/checkpoint_view.dart';
import 'package:st/src/app/pages/core/core_controller.dart';
import 'package:st/src/app/pages/create_route/create_route_view.dart';
import 'package:st/src/app/pages/create_route_info/create_route_info_view.dart';
import 'package:st/src/app/pages/camera/camera_view.dart';
import 'package:st/src/app/pages/joined_challenges/joined_challenges_view.dart';
import 'package:st/src/app/pages/log_in/log_in_view.dart';
import 'package:st/src/app/pages/my_routes/my_routes_view.dart';
import 'package:st/src/app/pages/register/register_view.dart';
import 'package:st/src/app/pages/route_details/route_details_view.dart';
import 'package:st/src/app/pages/saved_routes/saved_routes_view.dart';
import 'package:st/src/app/pages/splash/splash_view.dart';
import 'package:st/src/domain/entities/challenge.dart';
import 'package:st/src/domain/entities/route.dart' as st;
import 'package:st/src/app/pages/enter_route_details/enter_route_details_view.dart';
import 'package:st/src/app/pages/route_completion/route_completion_view.dart';

class STNavigator {
  static Future<void> navigateToSplashView(BuildContext context) async {
    await Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(builder: (context) => SplashView()),
      (_) => false,
    );
  }

  static Future<void> navigateToRegisterView(BuildContext context) async {
    await Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(builder: (context) => RegisterView()),
      (_) => false,
    );
  }

  static Future<void> navigateToLoginView(BuildContext context) async {
    await Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(builder: (context) => LoginView()),
      (_) => false,
    );
  }

  static Future<void> navigateToCreateRouteInfoView() async {
    await Navigator.push(
      CoreController().coreContext,
      MaterialPageRoute(
        builder: (context) => CreateRouteInfoView(),
      ),
    );
  }

  static Future<void> navigateToCreateRouteView(BuildContext context) async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRouteView(),
      ),
    );
  }

  static Future<String?> navigateToSTCameraView(BuildContext context, String? photoUrl) async {
    return await Navigator.push<String?>(
      context,
      CupertinoPageRoute(builder: (context) => STCameraView(photoUrl: photoUrl)),
    );
  }

  static Future<void> navigateToRouteDetailsView(st.Route route) async {
    await Navigator.push(
      CoreController().coreContext,
      CupertinoPageRoute(
        builder: (context) => RouteDetailsView(route),
        settings: RouteSettings(name: '/route-details'),
      ),
    );
  }

  static Future<void> navigateToAddCheckpoint(BuildContext context, String routeId, int order) async {
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => CheckpointView(routeId: routeId, order: order),
      ),
    );
  }

  static Future<void> navigateToEnterRouteDetailsView(BuildContext context) async {
    await Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => EnterRouteDetailsView()),
    );
  }

  static Future<void> navigateToRouteCompletionView(BuildContext context, String routeId) async {
    await Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => RouteCompletionView(routeId)),
    );
  }

  static Future<void> navigateToMyRoutesView(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyRoutesView(),
      ),
    );
  }

  static Future<void> navigateToJoinedChallengesView(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JoinedChallengesView(),
      ),
    );
  }

  static Future<void> navigateToChallengeView(BuildContext context, Challenge challenge, int thresholdValue) async {
    await Navigator.pushReplacement(
      context,
      CupertinoPageRoute(builder: (context) => ChallengeView(challenge, thresholdValue)),
    );
  }

  static Future<void> navigateToChallengeCompletionView(BuildContext context, String routeId) async {
    await Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => ChallengeCompletionView(routeId)),
    );
  }

  static Future<void> navigateToSavedRoutesView(BuildContext context) async {
    await Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => SavedRoutesView()),
    );
  }
}
