// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart' hide View hide Route;
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:st/src/app/constants.dart';
import 'package:st/src/app/widgets/action_bar.dart';
import 'package:st/src/app/widgets/alert_dialog.dart';
import 'package:st/src/app/widgets/primary_icon_button.dart';
import 'package:st/src/data/constants.dart';
import 'package:st/src/data/repositories/data_challenge_repository.dart';
import 'package:st/src/data/utils/string_utils.dart';
import 'package:st/src/domain/entities/challenge.dart';
import 'package:st/src/domain/entities/checkpoint.dart';
import 'package:st/src/domain/types/geolocation.dart';

import 'challenge_controller.dart';

class ChallengeView extends View {
  final Challenge challenge;
  final int thresholdValue;

  ChallengeView(this.challenge, this.thresholdValue);

  @override
  State<StatefulWidget> createState() {
    return _ChallengeViewState(
      ChallengeController(
        DataChallengeRepository(),
        this.challenge,
        this.thresholdValue,
      ),
    );
  }
}

class _ChallengeViewState extends ViewState<ChallengeView, ChallengeController> {
  _ChallengeViewState(ChallengeController controller) : super(controller);

  @override
  Widget get view {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    return Scaffold(
      key: globalKey,
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ControlledWidgetBuilder<ChallengeController>(
                    builder: (context, controller) {
                      return FlutterMap(
                        mapController: controller.mapController,
                        options: MapOptions(
                          initialCenter: Geolocation(latitude: 39.8898, longitude: 32.7801).toLatLng(),
                          initialZoom: defaultMapZoom,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: mapUrl,
                            userAgentPackageName: agentPackageName,
                            maxZoom: 19,
                          ),
                          CurrentLocationLayer(followOnLocationUpdate: AlignOnUpdate.once),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                color: Colors.blue,
                                isDotted: true,
                                strokeWidth: 7,
                                points: controller.challenge.route.path.isEmpty
                                    ? controller.challenge.route.checkpoints.map((e) => e.location.toLatLng()).toList()
                                    : controller.challenge.route.path.map((e) => e.toLatLng()).toList(),
                              ),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              for (Checkpoint checkpoint in controller.challenge.route.checkpoints)
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
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 170),
              ],
            ),
            ControlledWidgetBuilder<ChallengeController>(
              builder: (context, controller) {
                return SlidingUpPanel(
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
                    leftCheckpointCount: controller.challenge.route.checkpoints.length -
                        controller.challenge.completedCheckpointIds.length,
                    duration: controller.challenge.route.duration,
                    createdBy: controller.challenge.route.createdBy.username,
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
                        for (Checkpoint checkpoint in controller.challenge.route.checkpoints)
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
                    text: controller.isRouteCompleted ? 'Complete Route' : 'Complete Checkpoint',
                    onPressed: controller.completeCheckpoint,
                    isButtonEnabled: true,
                    isButtonLoading: controller.loading,
                  ),
                );
              },
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
                child: ControlledWidgetBuilder<ChallengeController>(builder: (context, controller) {
                  return Text(
                    controller.nextCheckpoint.name,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: kBlack,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  );
                }),
              ),
            ),
            Positioned(
              right: 15,
              top: padding.top + 15,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: kWhite.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 13,
                      spreadRadius: 5,
                      color: kBlack.withOpacity(0.12),
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: ControlledWidgetBuilder<ChallengeController>(builder: (context, controller) {
                  if (controller.thresholdValue == 60) {
                    return Icon(
                      Icons.thumb_up_alt,
                      size: 30,
                      color: Colors.green,
                    );
                  } else if (controller.thresholdValue == 70) {
                    return Icon(
                      Icons.check_circle_outline,
                      size: 30,
                      color: Color.fromARGB(255, 221, 201, 24),
                    );
                  } else if (controller.thresholdValue == 80) {
                    return Icon(
                      Icons.warning,
                      size: 30,
                      color: kPrimaryColor,
                    );
                  } else {
                    return Icon(
                      Icons.dangerous,
                      size: 30,
                      color: Color.fromARGB(255, 245, 53, 39),
                    );
                  }
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelHeaderWidget extends StatelessWidget {
  final int leftCheckpointCount;
  final Duration duration;
  final String createdBy;

  const _PanelHeaderWidget({required this.leftCheckpointCount, required this.duration, required this.createdBy});

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
                          '$leftCheckpointCount Checkpoints Left',
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
    return ControlledWidgetBuilder<ChallengeController>(
      builder: (context, controller) {
        return GestureDetector(
          onTap: () async {
            await controller.panelController.close();
            controller.mapController.move(checkpoint.location.toLatLng(), 18);
          },
          child: Stack(
            children: [
              Container(
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
                    Spacer(),
                    SizedBox(width: 10),
                    Container(
                      height: 27,
                      width: 27,
                      decoration: BoxDecoration(
                        color: controller.isCheckpointCompleted(checkpoint.id) ? kPrimaryColor : kDeactiveColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: kWhite,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 15),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => STAlertDialog.getImageDialog(checkpoint.photoUrl, checkpoint.name),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    width: 80,
                    height: 70,
                    color: Colors.transparent,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
