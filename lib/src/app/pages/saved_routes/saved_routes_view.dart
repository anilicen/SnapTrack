// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart' hide View hide Route;
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:st/src/app/constants.dart';
import 'package:st/src/app/navigator.dart';
import 'package:st/src/app/pages/saved_routes/saved_routes_controller.dart';
import 'package:st/src/app/widgets/app_bar.dart';
import 'package:st/src/data/helpers/dynamic_link_helper.dart';
import 'package:st/src/data/utils/string_utils.dart';
import 'package:st/src/data/repositories/data_route_repository.dart';
import 'package:flutter_svg/svg.dart';
import 'package:st/src/domain/entities/route.dart';
import 'package:transparent_image/transparent_image.dart';

class SavedRoutesView extends View {
  @override
  State<StatefulWidget> createState() {
    return _SavedRoutesViewState(
      SavedRoutesController(
        DataRouteRepository(),
      ),
    );
  }
}

class _SavedRoutesViewState extends ViewState<SavedRoutesView, SavedRoutesController> {
  _SavedRoutesViewState(SavedRoutesController controller) : super(controller);

  @override
  Widget get view {
    return Scaffold(
      body: Column(
        children: [
          STAppBarWithBack('Saved Routes'),
          ControlledWidgetBuilder<SavedRoutesController>(
            builder: (context, controller) {
              return controller.savedRoutes == null
                  ? Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        child: Container(
                          color: kBackgroundColor,
                          child: Column(
                            children: controller.savedRoutes!.length == 0
                                ? [
                                    SizedBox(height: 150),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.search_outlined,
                                          color: Colors.grey,
                                          size: 100.0,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          'No Saved Routes Found',
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Start exploring and save routes to view them here.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]
                                : controller.savedRoutes!.map((route) => _RouteWidget(route: route)).toList(),
                          ),
                        ),
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }
}

class _RouteWidget extends StatelessWidget {
  const _RouteWidget({
    required this.route,
  });

  final Route route;

  @override
  Widget build(BuildContext context) {
    return ControlledWidgetBuilder<SavedRoutesController>(
      builder: (context, controller) {
        return GestureDetector(
          onTap: () {
            STNavigator.navigateToRouteDetailsView(route);
          },
          child: Column(
            children: [
              SizedBox(height: 10),
              Slidable(
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) async {
                        final link = await DynamicLinkHelper.buildDynamicLink([route.id]);

                        Share.share(
                            "Get ready for an exciting challenge! This is an amazing route in SnapTrack. Tap to join the thrill!\n\n" +
                                link);
                      },
                      backgroundColor: Color(0xFF21B7CA),
                      foregroundColor: Colors.white,
                      icon: Icons.share,
                    ),
                    SlidableAction(
                      onPressed: (context) {
                        controller.removeSavedRoute(route);
                      },
                      backgroundColor: Colors.red,
                      icon: Icons.delete,
                    ),
                  ],
                ),
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FadeInImage.memoryNetwork(
                            fadeInDuration: kFadeInDuration,
                            placeholder: kTransparentImage,
                            image: route.coverPhotoUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        height: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              route.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  child: SvgPicture.asset(
                                    'assets/icons/checkpoint.svg',
                                    color: kPrimaryColor,
                                  ),
                                ),
                                SizedBox(width: 3),
                                Container(
                                  child: Text(
                                    route.checkpoints.length.toString() + " Checkpoints",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  child: SvgPicture.asset(
                                    'assets/icons/clock.svg',
                                    color: kPrimaryColor,
                                  ),
                                ),
                                SizedBox(width: 3),
                                Container(
                                  child: Text(
                                    StringUtils.formatRouteLengthShort(route.length) +
                                        ' · ' +
                                        StringUtils.formatRouteDurationShort(route.duration),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  child: SvgPicture.asset(
                                    'assets/icons/star.svg',
                                    color: kPrimaryColor,
                                  ),
                                ),
                                SizedBox(width: 3),
                                Container(
                                  child: Text(
                                    route.rating.toString() + " (" + route.participantCount.toString() + ")",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
