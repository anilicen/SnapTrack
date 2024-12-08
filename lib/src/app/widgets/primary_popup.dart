import 'package:flutter/material.dart';
import 'package:st/src/app/constants.dart';

class PrimaryPopup {
  final BuildContext context;
  final String title;
  final String content;
  final Function()? onPressed;

  final Size size;

  PrimaryPopup({
    required this.context,
    required this.title,
    required this.content,
    this.onPressed,
  }) : this.size = MediaQuery.of(context).size;

  Future<void> showDefaultPopup() async {
    await showDialog(
      context: this.context,
      builder: (context) {
        return Dialog(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: kBackgroundColor,
            ),
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: size.width - 120,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        this.title,
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        this.content,
                        style: TextStyle(
                          color: kBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        width: size.width - 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: onPressed ?? () => Navigator.pop(context),
                              child: Text(
                                'Okay',
                                style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
