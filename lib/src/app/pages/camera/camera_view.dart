// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart' hide View;
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter_svg/svg.dart';
import 'package:st/src/app/constants.dart';
import 'package:st/src/app/pages/camera/camera_controller.dart';
import 'package:st/src/app/widgets/alert_dialog.dart';
import 'package:st/src/app/widgets/primary_button.dart';
import 'package:st/src/app/widgets/primary_icon_button.dart';

class STCameraView extends View {
  final String? photoUrl;

  STCameraView({this.photoUrl});

  @override
  State<StatefulWidget> createState() {
    return _STCameraViewState(
      STCameraController(),
      this.photoUrl,
    );
  }
}

class _STCameraViewState extends ViewState<STCameraView, STCameraController> {
  String? photoUrl;

  _STCameraViewState(STCameraController controller, this.photoUrl) : super(controller);

  @override
  Widget get view {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kBlack,
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: ControlledWidgetBuilder<STCameraController>(
          builder: (context, controller) {
            return (controller.cameraController == null)
                ? Center(child: CircularProgressIndicator())
                : controller.isImageCaptured
                    ? _ImageWidget(cameraController: controller)
                    : _CameraWidget(
                        cameraController: controller,
                        photoUrl: photoUrl,
                      );
          },
        ),
      ),
    );
  }
}

class _CameraWidget extends StatelessWidget {
  const _CameraWidget({
    required this.cameraController,
    this.photoUrl,
  });

  final STCameraController cameraController;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    // fetch screen size
    final size = MediaQuery.of(context).size;

    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * cameraController.cameraController!.value.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    final padding = MediaQuery.of(context).padding;
    return ControlledWidgetBuilder<STCameraController>(
      builder: (context, controller) {
        return Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Transform.scale(
                scale: scale,
                child: CameraPreview(cameraController.cameraController!),
              ),
            ),
            if (photoUrl != null)
              Positioned(
                right: 15,
                top: padding.top + 15,
                child: GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => STAlertDialog.getImageDialog(photoUrl!, ''),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    width: size.width / 3,
                    height: size.height / 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Transform.scale(
                        scale: 2.0,
                        child: Image.network(
                          photoUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
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
              left: 15,
              bottom: padding.top + 15,
              child: PrimaryIconButton(
                onPressed: controller.switchCameraDirection,
                iconPath: 'assets/icons/switch_camera.svg',
                color: kWhite,
                backgroundEnabled: false,
              ),
            ),
            Positioned(
              right: 15,
              bottom: padding.top + 15,
              child: controller.flashModeIndex == 0
                  ? PrimaryIconButton(
                      onPressed: controller.setFlashMode,
                      iconPath: 'assets/icons/flash_off.svg',
                      color: kWhite,
                      backgroundEnabled: false,
                    )
                  : PrimaryIconButton(
                      onPressed: controller.setFlashMode,
                      iconPath: 'assets/icons/flash_on.svg',
                      color: kWhite,
                      backgroundEnabled: false,
                    ),
            ),
            Positioned(
              bottom: 15,
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        cameraController.captureImage();
                      },
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              height: 90,
                              width: 90,
                              'assets/icons/camera-button.svg',
                              color: Colors.white,
                            ),
                            SizedBox(height: 15),
                            Text(
                              'Tap to take a photo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ImageWidget extends StatelessWidget {
  const _ImageWidget({
    required this.cameraController,
  });

  final STCameraController cameraController;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.black,
          child: Image.file(
            File(cameraController.imagePath!),
          ),
        ),
        Positioned(
          top: 0,
          child: Container(
            height: 150,
            width: size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.black.withOpacity(0)],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            height: 150,
            width: size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black, Colors.black.withOpacity(0)],
              ),
            ),
          ),
        ),
        Positioned(
          left: 20,
          top: padding.top + 5,
          child: PrimaryIconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            backgroundEnabled: false,
            color: Colors.white,
          ),
        ),
        Positioned(
          right: 20,
          top: padding.top + 13,
          child: Container(
            height: 23,
            alignment: Alignment.center,
            child: TextButton(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: () => cameraController.retakeImage(),
              child: Text(
                'Retake',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 15,
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    onTap: () {
                      cameraController.captureImage();
                    },
                    child: PrimaryButton(
                      text: 'Use Photo',
                      onPressed: () {
                        Navigator.pop(context, cameraController.imagePath);
                      },
                      isEnabled: true,
                      isLoading: false,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
