import 'package:flutter/material.dart';
import 'package:st/src/app/constants.dart';

class STSearchBar extends StatefulWidget {
  final String hintText;
  final void Function(String value) onSearched;
  final void Function() onCleared;

  const STSearchBar({
    required this.onSearched,
    required this.onCleared,
    required this.hintText,
    super.key,
  });

  @override
  _STSearchBarState createState() => _STSearchBarState();
}

class _STSearchBarState extends State<STSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      width: size.width - 20,
      child: TextField(
        controller: _controller,
        style: TextStyle(
          fontSize: 14,
          color: kBlack,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(fontSize: 14, color: kBlackHint),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: kBorderColor),
            borderRadius: BorderRadius.circular(25),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: kPrimaryColorPale),
            borderRadius: BorderRadius.circular(25),
          ),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIconConstraints: BoxConstraints(maxHeight: 44),
          prefixIconConstraints: BoxConstraints(maxHeight: 44),
          prefixIcon: Container(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: Icon(Icons.search),
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  iconSize: 22,
                  onPressed: () {
                    setState(() {
                      _controller.clear();
                      widget.onCleared();
                    });
                  },
                )
              : null,
        ),
        onSubmitted: (value) {
          setState(() {
            widget.onSearched(value);
          });
        },
      ),
    );
  }
}
