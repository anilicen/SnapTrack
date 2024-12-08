import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:st/src/app/constants.dart';
import 'package:st/src/app/navigator.dart';
import 'package:st/src/data/helpers/firestore_helper.dart';
import 'package:st/src/domain/entities/route.dart';

class DynamicLinkHelper {
  static Future<String> buildDynamicLink(List<String> params) async {
    String url = ST_DEEP_LINK;

    try {
      String urlInfo = params.reduce((value, element) => value + ',' + element);

      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: url,
        link: Uri.parse(url + '/' + '&$urlInfo'),
        androidParameters: AndroidParameters(
          packageName: "com.example.st",
          minimumVersion: 0,
        ),
        iosParameters: IOSParameters(
          bundleId: "com.example.st",
          minimumVersion: '0',
        ),
      );
      final ShortDynamicLink dynamicUrl = await FirebaseDynamicLinks.instance.buildShortLink(parameters);

      return dynamicUrl.shortUrl.toString();
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }

  static Future<void> initDynamicLinks() async {
    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();

    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      await handleDynamicLink(deepLink);
    }

    FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;
      if (deepLink != null) {
        await handleDynamicLink(deepLink);
      }
    }).onError((e) {
      print(e.message);
    });
  }

  static Future<void> handleDynamicLink(Uri url) async {
    try {
      String decodedUrl = Uri.decodeFull(url.toString());

      List<String> queryParams = decodedUrl.substring(decodedUrl.indexOf("&") + 1).split(',');
      String routeId = queryParams[0];
      Route? route = await FirestoreHelper.getRouteById(routeId);
      STNavigator.navigateToRouteDetailsView(route!);
    } catch (e, st) {
      print(e);
      print(st);
    }
  }
}
