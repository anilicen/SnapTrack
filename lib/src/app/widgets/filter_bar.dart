import 'package:flutter/material.dart';
import 'package:st/src/app/constants.dart';

// ignore: must_be_immutable
class FilterBar extends StatefulWidget {
  final String title;
  var filterValue;
  final double barWidth;
  final double barHeight;
  final double scale;
  final ValueChanged<double> onChanged;

  FilterBar({
    required this.title,
    required this.filterValue,
    required this.barWidth,
    required this.barHeight,
    required this.scale,
    required this.onChanged,
  });

  @override
  _FilterBarState createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  double _currentFilterValue = 0.0;

  @override
  void initState() {
    super.initState();
    _currentFilterValue = widget.filterValue;
  }

  @override
  void didUpdateWidget(FilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filterValue != oldWidget.filterValue) {
      setState(() {
        _currentFilterValue = widget.filterValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              (_currentFilterValue).toStringAsFixed(1) + (widget.title == "Minimum Duration" ? " hr" : " km"),
            ),
          ],
        ),
        SizedBox(height: 5),
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              double newValue = (details.localPosition.dx / widget.barWidth) * widget.scale;
              newValue = newValue.clamp(0.0, widget.scale); // Clamp the value within the range
              _currentFilterValue = newValue;
              widget.onChanged(newValue);
            });
          },
          child: Container(
            width: widget.barWidth,
            height: widget.barHeight,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: widget.barHeight / 2 - 2.5,
                  child: Container(
                    height: 5.0,
                    color: kPrimaryColorPale,
                  ),
                ),
                Positioned(
                  left: (_currentFilterValue / widget.scale) * (widget.barWidth - 15.0),
                  top: widget.barHeight / 2 - 10,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        double newValue = (details.localPosition.dx / widget.barWidth) * widget.scale;
                        newValue = newValue.clamp(0.0, widget.scale);
                        _currentFilterValue = newValue;
                        widget.onChanged(newValue);
                      });
                    },
                    child: Container(
                      width: 15.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
