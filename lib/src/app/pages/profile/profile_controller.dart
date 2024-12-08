import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:st/src/app/navigator.dart';
import 'package:st/src/app/pages/core/core_controller.dart';
import 'package:st/src/domain/entities/user.dart';
import 'package:st/src/domain/repositories/user_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class ProfileController extends Controller {
  ProfileController(
    UserRepository UserRepository,
  ) : _userRepository = UserRepository;

  UserRepository _userRepository;

  User? user;

  @override
  void onInitState() {
    getProfile();
    super.onInitState();
  }

  @override
  void initListeners() {}

  void getProfile() async {
    user = await _userRepository.getUser();

    refreshUI();
  }

  Future<void> pickImageAndUpdateProfile() async {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final String imageUrl = await uploadImage(image.path);

      await _userRepository.updateProfilePicture(imageUrl);

      user = user!.copyWith(profilePictureUrl: imageUrl);
      refreshUI();
    }
  }

  Future<String> uploadImage(String filePath) async {
    File file = File(filePath);
    String fileName = path.basename(file.path);

    Reference ref = FirebaseStorage.instance.ref().child('profile-pictures/$fileName');

    UploadTask uploadTask = ref.putFile(file);

    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});

    final String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  Future<void> signOut() async {
    await _userRepository.signOut();

    STNavigator.navigateToLoginView(CoreController().coreContext);
  }
}
