// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart' hide View;
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:st/src/app/constants.dart';
import 'package:st/src/app/pages/route_details/route_details_controller.dart';
import 'package:st/src/app/widgets/action_bar.dart';
import 'package:st/src/app/widgets/primary_icon_button.dart';
import 'package:st/src/data/constants.dart';
import 'package:st/src/data/repositories/data_challenge_repository.dart';
import 'package:st/src/data/repositories/data_route_repository.dart';
import 'package:st/src/data/utils/string_utils.dart';
import 'package:st/src/domain/entities/checkpoint.dart';
import 'package:st/src/domain/entities/route.dart' as st;
import 'package:st/src/domain/types/geolocation.dart';

class RouteDetailsView extends View {
  final st.Route route;
  RouteDetailsView(
    this.route,
  );

  @override
  State<StatefulWidget> createState() {
    return _RouteDetailsViewState(
      RouteDetailsController(
        DataChallengeRepository(),
        DataRouteRepository(),
        this.route,
      ),
    );
  }
}

class _RouteDetailsViewState extends ViewState<RouteDetailsView, RouteDetailsController> {
  _RouteDetailsViewState(RouteDetailsController controller) : super(controller);

  @override
  Widget get view {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      key: globalKey,
      resizeToAvoidBottomInset: false,
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 90, right: 5),
        child: ControlledWidgetBuilder<RouteDetailsController>(builder: (context, controller) {
          return FloatingActionButton(
            shape: CircleBorder(),
            backgroundColor: kPrimaryColor,
            onPressed: () {
              MapsLauncher.launchCoordinates(
                controller.route.checkpoints.first.location.latitude.toDouble(),
                controller.route.checkpoints.first.location.longitude.toDouble(),
              );
            },
            child: Icon(
              Icons.location_on,
              color: kWhite,
              size: 30,
            ),
          );
        }),
      ),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: ControlledWidgetBuilder<RouteDetailsController>(
          builder: (context, controller) {
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: FlutterMap(
                        mapController: controller.mapController,
                        options: MapOptions(
                          initialCenter: widget.route.firstCheckpoint.location.toLatLng(),
                          initialZoom: defaultMapZoom,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: mapUrl,
                            userAgentPackageName: agentPackageName,
                            maxZoom: 19,
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                color: Colors.blue,
                                isDotted: true,
                                strokeWidth: 7,
                                points: controller.route.path.isEmpty
                                    ? controller.route.checkpoints.map((e) => e.location.toLatLng()).toList()
                                    : controller.route.path.map((e) => e.toLatLng()).toList(),
                              ),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              for (Checkpoint checkpoint in controller.route.checkpoints)
                                Marker(
                                  point: checkpoint.location.toLatLng(),
                                  width: 25,
                                  height: 25,
                                  alignment: Alignment.topCenter,
                                  child: SvgPicture.asset(
                                    'assets/icons/location.svg',
                                    color: kPrimaryColor,
                                  ),
                                ),
                            ],
                          ),
                          CurrentLocationLayer(
                            followOnLocationUpdate: FollowOnLocationUpdate.never,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 170),
                  ],
                ),
                SlidingUpPanel(
                  controller: controller.panelController,
                  minHeight: 179 + padding.bottom,
                  maxHeight: size.height - 75 - padding.top,
                  snapPoint: 0.35,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Colors.transparent,
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      blurRadius: 8.0,
                      color: Color.fromRGBO(0, 0, 0, 0.09),
                    )
                  ],
                  header: _PanelHeaderWidget(
                    checkpointCount: controller.route.checkpoints.length,
                    duration: controller.route.duration,
                    createdBy: controller.route.createdBy.username,
                  ),
                  panelBuilder: (sc) => Container(
                    margin: EdgeInsets.only(top: 87),
                    color: kBackgroundColor,
                    child: ListView(
                      cacheExtent: 1650,
                      addAutomaticKeepAlives: false,
                      padding: EdgeInsets.only(bottom: 120),
                      controller: sc,
                      children: [
                        for (Checkpoint checkpoint in controller.route.checkpoints)
                          Column(
                            children: [
                              SizedBox(height: 5),
                              _CheckpointContainer(checkpoint),
                            ],
                          ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  footer: ActionBar(
                    text: 'Start Route',
                    onPressed: () {
                      return showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return _DifficultySelectionDialog(
                            selectDifficulty: controller.selectDifficulty,
                          );
                        },
                      );
                    },
                    isButtonEnabled: true,
                    isButtonLoading: controller.loading,
                  ),
                ),
                Positioned(
                  left: 15,
                  top: padding.top + 15,
                  child: PrimaryIconButton(
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  left: (size.width - 200) / 2,
                  top: padding.top + 15,
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    width: 200,
                    padding: EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 4),
                          blurRadius: 4,
                          color: Colors.black12,
                        ),
                      ],
                    ),
                    child: Text(
                      controller.route.name,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: kBlack,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 15,
                  top: padding.top + 15,
                  child: PrimaryIconButton(
                    iconPath: 'assets/icons/menu.svg',
                    onPressed: () {
                      controller.toggleButtonsVisibility();
                    },
                  ),
                ),
                Positioned(
                  right: 15,
                  top: padding.top + 65,
                  child: IgnorePointer(
                    ignoring: !controller.areButtonsVisible,
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: 300),
                      opacity: controller.areButtonsVisible ? 1.0 : 0.0,
                      child: controller.checkIsSavedRoute()
                          ? PrimaryIconButton(
                              iconPath: 'assets/icons/bookmark.svg',
                              onPressed: () {
                                controller.removeSavedRoute();
                              },
                            )
                          : PrimaryIconButton(
                              iconPath: 'assets/icons/bookmark-outlined.svg',
                              onPressed: () {
                                controller.addSavedRoute();
                              },
                            ),
                    ),
                  ),
                ),
                Positioned(
                  right: 15,
                  top: padding.top + 115,
                  child: IgnorePointer(
                    ignoring: !controller.areButtonsVisible,
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: 300),
                      opacity: controller.areButtonsVisible ? 1.0 : 0.0,
                      child: PrimaryIconButton(
                        iconPath: 'assets/icons/share.svg',
                        onPressed: () {
                          Share.share(
                              "Get ready for an exciting challenge! This is an amazing route in SnapTrack. Tap to join the thrill!\n\n" +
                                  controller.route.shareLink);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PanelHeaderWidget extends StatelessWidget {
  final int checkpointCount;
  final Duration duration;
  final String createdBy;

  const _PanelHeaderWidget({
    required this.checkpointCount,
    required this.duration,
    required this.createdBy,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: 87,
      width: size.width,
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(width: 20),
                SvgPicture.asset(
                  'assets/icons/routes.svg',
                  color: kPrimaryColor,
                ),
                SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$checkpointCount Checkpoints',
                          style: TextStyle(
                            color: kBlack,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Created by ' + createdBy,
                      style: TextStyle(
                        color: kBlackHint,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: size.width,
            color: kBorderColor,
            height: 0.5,
          )
        ],
      ),
    );
  }
}

class _CheckpointContainer extends StatelessWidget {
  final Checkpoint checkpoint;

  const _CheckpointContainer(this.checkpoint);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ControlledWidgetBuilder<RouteDetailsController>(
      builder: (context, controller) {
        return GestureDetector(
          onTap: () async {
            await controller.panelController.close();
            controller.mapController.move(checkpoint.location.toLatLng(), 19);
          },
          child: Container(
            height: 90,
            width: size.width,
            color: kWhite,
            child: Row(
              children: [
                SizedBox(width: 10),
                Container(
                  height: 70,
                  width: 70,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      checkpoint.photoUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      checkpoint.name,
                      style: TextStyle(
                        color: kBlack,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DifficultySelectionDialog extends StatelessWidget {
  final Function(String) selectDifficulty;

  _DifficultySelectionDialog({required this.selectDifficulty});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Dialog(
        backgroundColor: kWhite,
        surfaceTintColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: kBackgroundColor,
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choose Difficulty Level",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(
                color: kBlack.withOpacity(0.09),
              ),
              SizedBox(height: 5),
              Text(
                "Select from 4 difficulty levels to set image comparison threshold",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 15,
                runSpacing: 15,
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: kBlack.withOpacity(0.12),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        selectDifficulty("easy");
                        Navigator.pop(context);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.thumb_up_alt,
                            size: 50,
                            color: Colors.green,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Easy (60%)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: kBlack.withOpacity(0.12),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        selectDifficulty("medium");
                        Navigator.pop(context);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 50,
                            color: Color.fromARGB(255, 221, 201, 24),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Medium (70%)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: kBlack.withOpacity(0.12),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        selectDifficulty("hard");
                        Navigator.pop(context);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning,
                            size: 50,
                            color: kPrimaryColor,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Hard (80%)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: kBlack.withOpacity(0.12),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        selectDifficulty("extreme");
                        Navigator.pop(context);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.dangerous,
                            size: 50,
                            color: Color.fromARGB(255, 245, 53, 39),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Extreme (90%)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
