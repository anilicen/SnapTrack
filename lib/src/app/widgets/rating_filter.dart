import 'package:flutter/material.dart';

class RatingFilter extends StatefulWidget {
  final int rating;
  final ValueChanged<int> onChanged;

  const RatingFilter({
    Key? key,
    required this.rating,
    required this.onChanged,
  }) : super(key: key);

  @override
  _RatingFilterState createState() => _RatingFilterState();
}

class _RatingFilterState extends State<RatingFilter> {
  int _currentRating = 0;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
  }

  @override
  void didUpdateWidget(RatingFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rating != oldWidget.rating) {
      setState(() {
        _currentRating = widget.rating;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Minimum Rating",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: List.generate(
            5,
            (index) => GestureDetector(
              onTap: () {
                setState(
                  () {
                    _currentRating = index + 1;
                    widget.onChanged(_currentRating);
                  },
                );
              },
              child: Icon(
                index < _currentRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 40,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
