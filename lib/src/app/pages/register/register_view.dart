import 'package:flutter/material.dart' hide View;
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:st/src/app/constants.dart';
import 'package:st/src/app/navigator.dart';
import 'package:st/src/app/widgets/st_text_field.dart';
import 'package:st/src/app/widgets/primary_button.dart';
import 'package:st/src/data/repositories/data_user_repository.dart';

import 'register_controller.dart';

class RegisterView extends View {
  @override
  State<StatefulWidget> createState() {
    return _RegisterViewState(
      RegisterController(
        DataUserRepository(),
      ),
    );
  }
}

class _RegisterViewState extends ViewState<RegisterView, RegisterController> {
  _RegisterViewState(RegisterController controller) : super(controller);

  bool isChecked = false;

  @override
  Widget get view {
    Size size = MediaQuery.of(context).size;
    EdgeInsets padding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: kWhite,
      key: globalKey,
      body: Container(
        width: size.width,
        height: size.height,
        padding: EdgeInsets.only(left: 20, right: 20),
        child: ControlledWidgetBuilder<RegisterController>(
          builder: (context, controller) {
            return ListView(
              physics: BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                SizedBox(
                  height: padding.top + 20,
                ),
                Text(
                  "Create Account",
                  textAlign: TextAlign.center,
                  style: kTitleStyle(),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10),
                  width: size.width - 60,
                  child: Text(
                    "Welcome to SnapTrack. It is time to become an adventurer!",
                    textAlign: TextAlign.center,
                    style: kSubtitleStyle(),
                  ),
                ),
                SizedBox(height: 50),
                STTextField(
                  size: size,
                  title: "Username",
                  hintText: "Your username",
                  isObscure: false,
                  onChanged: controller.setUsername,
                  color: controller.isUsernameAvaliable == false ? Colors.red : null,
                ),
                SizedBox(height: 20),
                STTextField(
                  size: size,
                  title: "Email",
                  hintText: "Your Email",
                  isObscure: false,
                  onChanged: controller.setEmail,
                  color: controller.isEmailAvaliable == false ? Colors.red : null,
                ),
                SizedBox(height: 20),
                STTextField(
                  size: size,
                  title: "Password",
                  hintText: "Your Password",
                  isObscure: true,
                  onChanged: controller.setPassword,
                ),
                SizedBox(height: 20),
                STTextField(
                  size: size,
                  title: "Password Again",
                  hintText: "Your Password",
                  isObscure: true,
                  onChanged: controller.setPasswordAgain,
                  color: controller.passwordsMatch == false ? Colors.red : null,
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: controller.toggleTermsAndPolicy,
                  child: Row(
                    children: [
                      SizedBox(width: 10),
                      Checkbox(
                          value: controller.termsAndPrivacyAccepted,
                          onChanged: (_) {
                            controller.toggleTermsAndPolicy();
                          }),
                      Container(
                        child: Text(
                          "I accept the terms and privacy policy",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                PrimaryButton(
                  text: "Sign Up",
                  onPressed: controller.registerUser,
                  isEnabled: controller.isFieldsAreInitialized(),
                  isLoading: controller.isLoading,
                ),
                SizedBox(height: 20),
                if (controller.passwordsMatch == false)
                  Text(
                    "Passwords do not match!",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.red,
                    ),
                  ),
                if (controller.isEmailAvaliable == false)
                  Text(
                    "Email is already in use!",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.red,
                    ),
                  ),
                if (controller.isPasswordAvaliable == false)
                  Text(
                    "Your password is too weak!\nPassword should be at least 6 characters!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.red,
                    ),
                  ),
                if (controller.isUsernameAvaliable == false)
                  Text(
                    "This username is already taken!",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.red,
                    ),
                  ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        STNavigator.navigateToLoginView(context);
                      },
                      child: Text(
                        "Log in",
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
