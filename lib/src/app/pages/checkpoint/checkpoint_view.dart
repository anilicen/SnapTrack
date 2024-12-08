// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart' hide View;
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter_svg/svg.dart';
import 'package:st/src/app/navigator.dart';
import 'package:st/src/app/pages/checkpoint/checkpoint_controller.dart';
import 'package:st/src/app/widgets/action_bar.dart';
import 'package:st/src/app/widgets/app_bar.dart';
import 'package:st/src/app/widgets/st_text_field.dart';
import 'package:st/src/data/repositories/data_route_repository.dart';

class CheckpointView extends View {
  final String routeId;
  final int order;
  CheckpointView({
    required this.routeId,
    required this.order,
  });

  @override
  State<StatefulWidget> createState() {
    return _CheckpointViewState(
      CheckpointController(
        DataRouteRepository(),
        this.routeId,
        this.order,
      ),
    );
  }
}

class _CheckpointViewState extends ViewState<CheckpointView, CheckpointController> {
  _CheckpointViewState(CheckpointController controller) : super(controller);

  @override
  Widget get view {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: globalKey,
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: ControlledWidgetBuilder<CheckpointController>(
          builder: (context, controller) {
            return Column(
              children: [
                STAppBarWithBack('New Checkpoint'),
                GestureDetector(
                  onTap: () async {
                    final result = await STNavigator.navigateToSTCameraView(context, null);
                    if (result != null) {
                      controller.setImagePath(result);
                    }
                  },
                  child: controller.imagePath == null
                      ? Container(
                          height: size.width / 1.6,
                          width: size.width,
                          color: Color(0xf8f8f8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/camera.svg',
                                width: 96,
                                height: 96,
                                color: Colors.black.withOpacity(0.25),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to take a photo',
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.25),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          height: size.width / 1.6,
                          width: size.width,
                          child: Image.file(
                            File(controller.imagePath!),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    child: Column(
                      children: [
                        STTextField(
                          size: size,
                          title: "Checkpoint Name",
                          hintText: "A Checkpoint Name",
                          isObscure: false,
                          onChanged: controller.setName,
                        ),
                      ],
                    ),
                  ),
                ),
                ActionBar(
                  text: 'Add Checkpoint',
                  onPressed: () {
                    controller.addCheckpoint();
                  },
                  isButtonEnabled: !controller.addingCheckpoint,
                  isButtonLoading: controller.addingCheckpoint,
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
