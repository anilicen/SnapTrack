// ignore_for_file: deprecated_member_use

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart' hide View;
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:st/src/app/constants.dart';
import 'package:st/src/app/navigator.dart';
import 'package:st/src/app/widgets/action_bar.dart';
import 'package:st/src/app/widgets/alert_dialog.dart';
import 'package:st/src/app/widgets/primary_icon_button.dart';
import 'package:st/src/data/constants.dart';
import 'package:st/src/data/repositories/data_route_repository.dart';
import 'package:st/src/data/utils/string_utils.dart';
import 'package:st/src/domain/entities/checkpoint.dart';
import 'package:st/src/domain/types/geolocation.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'create_route_controller.dart';

class CreateRouteView extends View {
  @override
  State<StatefulWidget> createState() {
    return _CreateRouteViewState(
      CreateRouteController(
        DataRouteRepository(),
      ),
    );
  }
}

class _CreateRouteViewState extends ViewState<CreateRouteView, CreateRouteController> {
  _CreateRouteViewState(CreateRouteController controller) : super(controller);

  @override
  Widget get view {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      key: globalKey,
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ControlledWidgetBuilder<CreateRouteController>(
                    builder: (context, controller) {
                      return FlutterMap(
                        mapController: controller.mapController,
                        options: MapOptions(
                          // TODO fix it
                          initialCenter: Geolocation(latitude: 39.8898, longitude: 32.7801).toLatLng(),
                          initialZoom: defaultMapZoom,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: mapUrl,
                            userAgentPackageName: agentPackageName,
                            maxZoom: 19,
                          ),
                          CurrentLocationLayer(followOnLocationUpdate: AlignOnUpdate.always),
                          if (controller.unpublishedRoute != null)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  color: Colors.blue,
                                  isDotted: true,
                                  strokeWidth: 7,
                                  points: controller.unpublishedRoute!.path.map((e) => e.toLatLng()).toList(),
                                ),
                              ],
                            ),
                          if (controller.unpublishedRoute != null)
                            MarkerLayer(
                              markers: [
                                for (Checkpoint checkpoint in controller.unpublishedRoute!.checkpoints)
                                  Marker(
                                    point: checkpoint.location.toLatLng(),
                                    width: 30,
                                    height: 30,
                                    child: SvgPicture.asset(
                                      'assets/icons/location.svg',
                                      color: Colors.red,
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
            ControlledWidgetBuilder<CreateRouteController>(
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
                  header: controller.unpublishedRoute == null
                      ? Container(
                          height: 87,
                          width: size.width,
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                        )
                      : _PanelHeaderWidget(
                          checkpointCount: controller.unpublishedRoute!.checkpoints.length,
                          duration: controller.unpublishedRoute!.duration,
                        ),
                  panelBuilder: (sc) => controller.unpublishedRoute == null
                      ? Container(
                          margin: EdgeInsets.only(top: 87),
                          color: kBackgroundColor,
                        )
                      : Container(
                          margin: EdgeInsets.only(top: 87),
                          color: kBackgroundColor,
                          child: ListView(
                            cacheExtent: 1650,
                            addAutomaticKeepAlives: false,
                            padding: EdgeInsets.only(bottom: 120),
                            controller: sc,
                            children: [
                              for (int index = 0; index < controller.unpublishedRoute!.checkpoints.length; index++)
                                Column(
                                  children: [
                                    SizedBox(height: 5),
                                    _CheckpointContainer(controller.unpublishedRoute!.checkpoints[index], index,
                                        controller.deleteCheckpoint),
                                  ],
                                ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      STNavigator.navigateToAddCheckpoint(context, controller.unpublishedRoute!.id,
                                          controller.unpublishedRoute!.checkpointsCount);
                                    },
                                    child: DottedBorder(
                                      borderType: BorderType.RRect,
                                      color: kPrimaryColorPale,
                                      radius: Radius.circular(10),
                                      dashPattern: [10, 5],
                                      child: Container(
                                        width: 220,
                                        height: 50,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              'assets/icons/add.svg',
                                              color: kPrimaryColorPale,
                                              width: 30,
                                              height: 30,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              'Add Checkpoint',
                                              style: TextStyle(
                                                color: kPrimaryColorPale,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                  footer: ActionBar(
                    text: 'Finish Creating Route',
                    onPressed: () {
                      if (controller.unpublishedRoute != null) STNavigator.navigateToEnterRouteDetailsView(context);
                    },
                    isButtonEnabled: true,
                    isButtonLoading: false,
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
              left: (size.width - 182) / 2,
              top: padding.top + 15,
              child: Container(
                alignment: Alignment.center,
                height: 40,
                width: 182,
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
                  'New Route',
                  style: TextStyle(
                    color: kBlack,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelHeaderWidget extends StatelessWidget {
  final int checkpointCount;
  final Duration duration;

  const _PanelHeaderWidget({required this.checkpointCount, required this.duration});

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
                Text(
                  '$checkpointCount Checkpoints',
                  style: TextStyle(
                    color: kBlack,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  ' • ',
                  style: TextStyle(
                    color: kBlackHint,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  StringUtils.formatRouteDurationShort(duration),
                  style: TextStyle(
                    color: kBlackHint,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
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
  final int index;
  final Function(int) deleteCheckpoint;
  const _CheckpointContainer(this.checkpoint, this.index, this.deleteCheckpoint);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        // TODO: Checkpoint Edit
        print('Navigate to checkpoint add with inital value');
      },
      child: Slidable(
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return STAlertDialog.getDeleteDialog(context, () => deleteCheckpoint(index));
                  },
                );
              },
              backgroundColor: Colors.red,
              icon: Icons.delete,
            ),
          ],
        ),
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
                  SizedBox(height: 10),
                  Text(
                    '${checkpoint.location.latitude.toStringAsFixed(3)} • ${checkpoint.location.longitude.toStringAsFixed(3)}',
                    style: TextStyle(
                      color: kBlackHint,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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
