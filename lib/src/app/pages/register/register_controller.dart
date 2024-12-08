import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:st/src/app/navigator.dart';
import 'package:st/src/data/exceptions/unavailable_email_exception.dart';
import 'package:st/src/data/exceptions/weak_password_exception.dart';
import 'package:st/src/domain/entities/user.dart' as ent;
import 'package:st/src/domain/repositories/user_repository.dart';

class RegisterController extends Controller {
  RegisterController(
    UserRepository userRepository,
  ) : _userRepository = userRepository;

  UserRepository _userRepository;
  String username = '';
  String email = '';
  String password = '';
  String passwordAgain = '';
  bool? passwordsMatch;
  bool termsAndPrivacyAccepted = false;
  bool isLoading = false;
  ent.User? user;
  bool? isEmailAvaliable;
  bool? isPasswordAvaliable;
  bool? isUsernameAvaliable;

  @override
  void onInitState() {
    super.onInitState();
  }

  @override
  void initListeners() {}

  void registerUser() async {
    isLoading = true;
    if (password != passwordAgain) {
      passwordsMatch = false;
      isLoading = false;
      refreshUI();
      return;
    }

    refreshUI();

    isUsernameAvaliable = await _userRepository.checkIfUsernameIsAvaliable(username);
    if (isUsernameAvaliable == false) {
      isLoading = false;
      refreshUI();
      return;
    }
    user = ent.User(id: '', username: username, email: email, profilePictureUrl: null);

    try {
      await _userRepository.registerUser(user!, password);
    } catch (e) {
      if (e is UnavailableEmailException) {
        isEmailAvaliable = false;
      } else if (e is WeakPasswordException) {
        isPasswordAvaliable = false;
      }
    }

    if (isEmailAvaliable == false || isPasswordAvaliable == false) {
      isLoading = false;
      refreshUI();
      return;
    }

    STNavigator.navigateToSplashView(getContext());
  }

  void setUsername(String value) {
    isUsernameAvaliable = null;
    this.username = value;
    refreshUI();
  }

  void setPassword(String value) {
    passwordsMatch = null;
    isPasswordAvaliable = null;
    this.password = value;
    refreshUI();
  }

  void setPasswordAgain(String value) {
    passwordsMatch = null;
    this.passwordAgain = value;
    refreshUI();
  }

  void setEmail(String value) {
    isEmailAvaliable = null;
    this.email = value;
    refreshUI();
  }

  void toggleTermsAndPolicy() {
    termsAndPrivacyAccepted = !termsAndPrivacyAccepted;
    refreshUI();
  }

  bool isFieldsAreInitialized() {
    return this.email != '' && this.password != '' && this.username != '' && this.termsAndPrivacyAccepted;
  }
}
