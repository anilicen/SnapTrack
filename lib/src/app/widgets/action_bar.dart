import 'package:flutter/material.dart';
import 'package:st/src/app/constants.dart';
import 'package:st/src/app/widgets/primary_button.dart';

class ActionBar extends StatelessWidget {
  final String text;
  final Function() onPressed;
  final bool isButtonEnabled;
  final bool isButtonLoading;

  const ActionBar({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isButtonEnabled,
    required this.isButtonLoading,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    return Container(
      width: size.width,
      height: 90 + padding.bottom,
      color: kWhite,
      padding: EdgeInsets.only(bottom: padding.bottom),
      alignment: Alignment.center,
      child: PrimaryButton(
        text: text,
        onPressed: onPressed,
        isEnabled: isButtonEnabled,
        isLoading: isButtonLoading,
      ),
    );
  }
}
