import 'package:camera/camera.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

class STCameraController extends Controller {
  XFile? imageFile;
  List<CameraDescription>? cameras;
  CameraController? cameraController;
  CameraPreview? cameraPreview;
  bool isImageCaptured = false;
  String? imagePath;
  int flashModeIndex = 0;

  @override
  void initListeners() {}

  @override
  void onInitState() async {
    initCamera();
    super.onInitState();
  }

  @override
  void onDisposed() {
    cameraController!.dispose();
    super.onDisposed();
  }

  Future initCamera() async {
    try {
      cameras = await availableCameras();
      cameraController = CameraController(
        cameras!.firstWhere((e) => e.lensDirection == CameraLensDirection.back),
        ResolutionPreset.high,
      );
      await cameraController!.initialize();
      cameraController!.setFlashMode(FlashMode.off);
      refreshUI();
    } on CameraException catch (e, st) {
      print(e);
      print(st);
    }
  }

  void captureImage() async {
    imageFile = await cameraController!.takePicture();
    imagePath = await imageFile!.path;
    isImageCaptured = true;
    refreshUI();
  }

  void retakeImage() {
    isImageCaptured = false;
    refreshUI();
  }

  void setFlashMode() {
    flashModeIndex = (flashModeIndex + 1) % 2;
    cameraController!.setFlashMode(FlashMode.values[flashModeIndex]);
    refreshUI();
  }

  void switchCameraDirection() async {
    if (cameraController!.description.lensDirection == CameraLensDirection.back) {
      cameraController = CameraController(
        cameras!.firstWhere((e) => e.lensDirection == CameraLensDirection.front),
        ResolutionPreset.high,
      );
    } else {
      cameraController = CameraController(
        cameras!.firstWhere((e) => e.lensDirection == CameraLensDirection.back),
        ResolutionPreset.high,
      );
    }
    await cameraController!.initialize();
    refreshUI();
  }
}
