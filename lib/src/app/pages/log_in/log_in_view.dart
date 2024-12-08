import 'package:flutter/material.dart' hide View;
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:st/src/app/constants.dart';
import 'package:st/src/app/navigator.dart';
import 'package:st/src/app/pages/log_in/log_in_controller.dart';
import 'package:st/src/app/widgets/st_text_field.dart';
import 'package:st/src/app/widgets/primary_button.dart';
import 'package:st/src/data/repositories/data_user_repository.dart';

class LoginView extends View {
  @override
  State<StatefulWidget> createState() {
    return _LoginViewState(
      LoginController(
        DataUserRepository(),
      ),
    );
  }
}

class _LoginViewState extends ViewState<LoginView, LoginController> {
  _LoginViewState(LoginController controller) : super(controller);
  @override
  Widget get view {
    Size size = MediaQuery.of(context).size;
    EdgeInsets padding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: kWhite,
      resizeToAvoidBottomInset: false,
      key: globalKey,
      body: Container(
        width: size.width,
        height: size.height,
        child: ControlledWidgetBuilder<LoginController>(
          builder: (context, controller) {
            return Column(
              children: [
                SizedBox(
                  height: padding.top + 60,
                  width: size.width,
                ),
                Text(
                  "Log in",
                  textAlign: TextAlign.center,
                  style: kTitleStyle(),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10),
                  width: size.width - 60,
                  child: Text(
                    "Welcome back!",
                    textAlign: TextAlign.center,
                    style: kSubtitleStyle(),
                  ),
                ),
                SizedBox(height: 20),
                STTextField(
                  size: size,
                  title: "Email Address",
                  hintText: "Your email",
                  isObscure: false,
                  onChanged: controller.setEmail,
                  color: (controller.isEmailValid == false || controller.isLoginValid == false) ? Colors.red : null,
                ),
                SizedBox(height: 20),
                STTextField(
                  size: size,
                  title: "Password",
                  hintText: "Your password",
                  isObscure: true,
                  onChanged: controller.setPassword,
                ),
                SizedBox(height: 15),
                Container(
                  width: size.width - 40,
                  child: Text(
                    "Forgot password?",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 50),
                PrimaryButton(
                    text: "Log in",
                    onPressed: controller.logIn,
                    isEnabled: controller.isFieldsAreInitialized(),
                    isLoading: controller.isLoading),
                if (controller.isLoginValid == false)
                  Text(
                    "User information is not correct",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.red,
                    ),
                  ),
                if (controller.isEmailValid == false)
                  Text(
                    "Email is not a valid email",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.red,
                    ),
                  ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        STNavigator.navigateToRegisterView(context);
                      },
                      child: Text(
                        "Sign Up",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: kPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }
}
