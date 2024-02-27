import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef ColorCodeBuilder = Widget Function(BuildContext context, Color color);

class CircleColorPicker extends StatefulWidget {
  const CircleColorPicker(
      {
        required this.onChanged,
        this.size = const Size(280, 280),
        this.strokeWidth = 2,
        this.thumbSize = 32,
        this.initialColor = const Color.fromARGB(255, 255, 0, 0),
        this.textStyle = const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        required this.colorCodeBuilder,
        this.widget});

  /// Called during a drag when the user is selecting a color.
  ///
  /// This callback called with latest color that user selected.
  final ValueChanged<Color> onChanged;

  /// The size of widget.
  /// Draggable area is thumb widget is included to the size,
  /// so circle is smaller than the size.
  ///
  /// Default value is 280 x 280.
  final Size size;

  /// The width of circle border.
  ///
  /// Default value is 2.
  final double strokeWidth;

  /// The size of thumb for circle picker.
  ///
  /// Default value is 32.
  final double thumbSize;

  /// Initial color for picker.
  /// [onChanged] callback won't be called with initial value.
  ///
  /// Default value is Red.
  final Color initialColor;

  /// Text style config
  ///
  /// Default value is Black
  final TextStyle textStyle;

  /// Widget builder that show color code section.
  /// This functions is called every time color changed.
  ///
  /// Default is Text widget that shows rgb strings;
  final ColorCodeBuilder colorCodeBuilder;

  final Widget? widget;

  double get initialLightness => HSLColor.fromColor(initialColor).lightness;

  double get initialHue => HSLColor.fromColor(initialColor).hue;

  @override
  _CircleColorPickerState createState() => _CircleColorPickerState();
}

class _CircleColorPickerState extends State<CircleColorPicker>
    with TickerProviderStateMixin {
  late AnimationController _lightnessController;
  late AnimationController _hueController;

  Color get _color {
    return HSLColor.fromAHSL(
      1,
      _hueController.value,
      1,
      _lightnessController.value,
    ).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          _HuePicker(
            initialHue: widget.initialHue,
            size: widget.size,
            strokeWidth: widget.strokeWidth,
            thumbSize: widget.thumbSize,
            onChanged: (hue) {
              _hueController.value = hue * 180 / pi;
            },
          ),
          Text("Color", style: TextStyle(
            fontSize: 35,fontWeight: FontWeight.bold
          ),),
          AnimatedBuilder(
            animation: _hueController,
            builder: (context, child) {
              return AnimatedBuilder(
                animation: _lightnessController,
                builder: (context, _) {
                  return Center(child: widget.widget);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _hueController = AnimationController(
      vsync: this,
      value: widget.initialHue,
      lowerBound: 0,
      upperBound: 360,
    )..addListener(_onColorChanged);
    _lightnessController = AnimationController(
      vsync: this,
      value: widget.initialLightness,
      lowerBound: 0,
      upperBound: 1,
    )..addListener(_onColorChanged);
  }

  void _onColorChanged() {
    widget.onChanged?.call(_color);
  }
}

class _HuePicker extends StatefulWidget {
  const _HuePicker({
    required this.onChanged,
    required this.size,
    required this.strokeWidth,
    required this.thumbSize,
    required this.initialHue,
  });

  final ValueChanged<double> onChanged;

  final Size size;

  final double strokeWidth;

  final double thumbSize;

  final double initialHue;

  @override
  _HuePickerState createState() => _HuePickerState();
}

class _HuePickerState extends State<_HuePicker> with TickerProviderStateMixin {
  late AnimationController _hueController;
  late AnimationController _scaleController;
  late Animation<Offset> _offset;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: SizedBox(
        width: widget.size.width,
        height: widget.size.height,
        child: Stack(
          children: <Widget>[
            SizedBox.expand(
              child: Padding(
                padding: EdgeInsets.all(
                  widget.thumbSize / 2 - widget.strokeWidth,
                ),
                child: CustomPaint(
                  painter: _CirclePickerPainter(widget.strokeWidth),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _offset,
              builder: (context, child) {
                return Positioned(
                  left: _offset.value.dx,
                  top: _offset.value.dy,
                  child: child!,
                );
              },
              child: AnimatedBuilder(
                animation: _hueController,
                builder: (context, child) {
                  final hue = _hueController.value * (180 / pi);
                  return ScaleTransition(
                    scale: _scaleController,
                    child: _Thumb(
                      size: widget.thumbSize,
                      color: HSLColor.fromAHSL(1, hue, 1, 0.5).toColor(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    final minSize = min(widget.size.width, widget.size.height);
    _hueController = AnimationController(
      vsync: this,
      value: widget.initialHue * pi / 180,
      lowerBound: 0,
      upperBound: 2 * pi,
    )..addListener(() => widget.onChanged(_hueController.value));
    _scaleController = AnimationController(
      vsync: this,
      value: 1,
      lowerBound: 0.9,
      upperBound: 1,
      duration: Duration(milliseconds: 50),
    );
    _offset = _CircleTween(
      minSize / 2 - widget.thumbSize / 2,
    ).animate(_hueController);
  }

  void _onPanStart(DragStartDetails details) {
    _scaleController.reverse();
    _updatePosition(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _updatePosition(details.localPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    _scaleController.forward();
  }

  void _updatePosition(Offset position) {
    final radians = atan2(
      position.dy - widget.size.height / 2,
      position.dx - widget.size.width / 2,
    );
    _hueController.value = radians % (2 * pi);
  }
}

class _CircleTween extends Tween<Offset> {
  _CircleTween(this.radius)
      : super(
    begin: _radiansToOffset(0, radius),
    end: _radiansToOffset(2 * pi, radius),
  );

  final double radius;

  @override
  Offset lerp(double t) => _radiansToOffset(t, radius);

  static Offset _radiansToOffset(double radians, double radius) {
    return Offset(
      radius + radius * cos(radians),
      radius + radius * sin(radians),
    );
  }
}

class _CirclePickerPainter extends CustomPainter {
  const _CirclePickerPainter(
      this.strokeWidth,
      );

  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    double radio = min(size.width, size.height) / 2 - strokeWidth;

    const sweepGradient = SweepGradient(
      colors: const [
        Color.fromARGB(255, 255, 0, 0),
        Color.fromARGB(255, 255, 255, 0),
        Color.fromARGB(255, 0, 255, 0),
        Color.fromARGB(255, 0, 255, 255),
        Color.fromARGB(255, 0, 0, 255),
        Color.fromARGB(255, 255, 0, 255),
        Color.fromARGB(255, 255, 0, 0),
      ],
    );

    final sweepShader = sweepGradient.createShader(
      Rect.fromCircle(center: center, radius: radio),
    );

    canvas.drawCircle(
      center,
      radio,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 3
        ..shader = sweepShader,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.size, required this.color});

  final double size;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromARGB(255, 255, 255, 255),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(16, 0, 0, 0),
            blurRadius: 4,
            spreadRadius: 4,
          )
        ],
      ),
      alignment: Alignment.center,
      child: Container(
        width: size - 6,
        height: size - 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
