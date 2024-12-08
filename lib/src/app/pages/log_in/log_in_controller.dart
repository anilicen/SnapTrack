import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:st/src/app/navigator.dart';
import 'package:st/src/data/exceptions/invalid_email_exception.dart';
import 'package:st/src/data/exceptions/invalid_login_exception.dart';
import 'package:st/src/domain/repositories/user_repository.dart';

class LoginController extends Controller {
  LoginController(
    UserRepository userRepository,
  ) : _userRepository = userRepository;

  UserRepository _userRepository;

  String email = '';
  String password = '';
  bool isLoading = false;
  bool? isLoginValid;
  bool? isEmailValid;
  @override
  void onInitState() {
    super.onInitState();
  }

  @override
  void initListeners() {}

  void setPassword(String value) {
    this.password = value;
    isLoginValid = null;
    refreshUI();
  }

  void setEmail(String value) {
    this.email = value;
    isEmailValid = null;
    isLoginValid = null;
    refreshUI();
  }

  Future<void> logIn() async {
    isLoading = true;

    refreshUI();
    try {
      await _userRepository.logIn(email, password);
    } catch (e) {
      if (e is InvalidEmailException) {
        isEmailValid = false;
      } else if (e is InvalidLoginException) {
        isLoginValid = false;
      }
    }
    print(isLoginValid);
    if (isLoginValid == false || isEmailValid == false) {
      isLoading = false;
      refreshUI();
      return;
    }
    STNavigator.navigateToSplashView(getContext());
  }

  bool isFieldsAreInitialized() {
    return this.email != '' && this.password != '';
  }
}
