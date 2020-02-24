import 'package:flutter/material.dart';

enum SlideDirection { RIGHT, LEFT }
enum ButtonState { NOTCONFIRMED, CONFIRMED }

class SlideContainerStack extends StatefulWidget {
  final Widget backgroundChild;
  final Widget slidingChild;
  final Color backgroundColor;
  final Color slidingBarColor;
  final double confirmPercentage;
  final double maxCompressPercentage;
  final bool isDraggable;
  final ValueSetter<double> onButtonSlide;
  final VoidCallback onButtonOpened;
  final VoidCallback onButtonClosed;
  final SlideDirection slideDirection;
  final bool isClosed;
  final double slidingStartSpace;
  final double slidingEndSpace;

  const SlideContainerStack({
    Key key,
    this.slidingChild,
    this.backgroundChild,
    this.confirmPercentage = 0.9,
    this.maxCompressPercentage = 0.2,
    this.isClosed = false,
    this.slidingStartSpace = 0.0,
    this.slidingEndSpace = 0.0,
    this.slideDirection = SlideDirection.RIGHT,
    this.isDraggable = true,
    this.onButtonSlide,
    this.onButtonOpened,
    this.onButtonClosed,
    @required this.backgroundColor,
    @required this.slidingBarColor,
  }) : super(key: key);

  @override
  _SlideContainerStackState createState() => _SlideContainerStackState();
}

class _SlideContainerStackState extends State<SlideContainerStack>
    with SingleTickerProviderStateMixin {
  AnimationController _slideAC;

  var _maxWidth = 0.0;
  var _maxHeight = 0.0;

  @override
  void initState() {
    super.initState();
    _slideAC = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        setState(() {});

        if (widget.onButtonSlide != null) widget.onButtonSlide(_slideAC.value);

        if (widget.onButtonOpened != null && _slideAC.value == 1.0)
          widget.onButtonOpened();

        if (widget.onButtonClosed != null &&
            _slideAC.value == widget.maxCompressPercentage)
          widget.onButtonClosed();
      });

    _slideAC.value = widget.maxCompressPercentage;

    if (widget.isClosed) {
      _slideAC.value = 1.0;
    }
  }

  @override
  void dispose() {
    _slideAC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _maxHeight = constraints.maxHeight;
      _maxWidth = constraints.maxWidth -
          widget.slidingStartSpace -
          widget.slidingEndSpace;

      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            color: widget.backgroundColor,
            child: widget.backgroundChild ?? null,
          ),
          GestureDetector(
            onVerticalDragUpdate: widget.isDraggable ? _onDrag : null,
            onVerticalDragEnd: widget.isDraggable ? _onDragEnd : null,
            child: Container(
              margin: EdgeInsets.only(
                left: widget.slidingStartSpace,
                right: widget.slidingEndSpace,
              ),
              child: Align(
                alignment: widget.slideDirection == SlideDirection.RIGHT
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: _slideAC.value,
                  heightFactor: 1.0,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 0.0,
                        child: Container(
                          width: _maxWidth,
                          height: _maxHeight,
                          color: widget.slidingBarColor,
                          child: widget.slidingChild ?? null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      );
    });
  }

  void _onDrag(DragUpdateDetails details) {
    if (widget.slideDirection == SlideDirection.RIGHT) {
      _slideAC.value = (details.globalPosition.dx) / _maxWidth;
    } //
    else {
      _slideAC.value = 1.0 - (details.globalPosition.dx) / _maxWidth;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_slideAC.isAnimating) return;

    if (_slideAC.value > widget.confirmPercentage) {
      _slideAC.fling(velocity: 1.0);
    } //
    else {
      _slideAC.animateTo(
        widget.maxCompressPercentage,
        duration: Duration(milliseconds: 300),
      );
    }
  }
}
