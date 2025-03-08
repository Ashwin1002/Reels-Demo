import 'package:flutter/cupertino.dart';
import 'package:reels_demo/core/core.dart';

class TapBouncer extends StatefulWidget {
  const TapBouncer({
    super.key,
    required this.onPressed,
    this.iconData,
    this.label = '',
    this.showIcon = true,
    this.iconAssetPath,

    this.showShadow = false,
    this.height,
    this.backgroundColor,
    this.borderRadius,
    this.boxShape,
    this.child,
    this.textColor,
    this.textStyle,
    this.trailing,
  });

  final double? height;
  final IconData? iconData;
  final String label;
  final bool showIcon;
  final String? iconAssetPath;
  final void Function() onPressed;
  final bool showShadow;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BoxShape? boxShape;
  final Widget? child;
  final Color? textColor;
  final TextStyle? textStyle;
  final Widget? trailing;

  @override
  State<TapBouncer> createState() => _TapBouncerState();
}

class _TapBouncerState extends State<TapBouncer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        FocusManager.instance.primaryFocus?.unfocus();

        // Animate bounce effect
        await _animationController.forward();
        await _animationController.reverse();

        // Debounce the tap action
        widget.onPressed.call();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 - _animationController.value,
            child: child,
          );
        },
        child: _ChildWidget(
          backgroundColor: widget.backgroundColor,
          borderRadius: widget.borderRadius,
          boxShape: widget.boxShape,
          showShadow: widget.showShadow,
          child: widget.child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _ChildWidget extends StatelessWidget {
  const _ChildWidget({
    required this.child,
    this.backgroundColor,
    this.showShadow = false,
    this.borderRadius,
    this.boxShape,
  });

  final Color? backgroundColor;
  final bool showShadow;
  final BorderRadius? borderRadius;
  final BoxShape? boxShape;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
            boxShape == BoxShape.circle
                ? null
                : borderRadius ?? BorderRadius.circular(12.0),
        shape: boxShape ?? BoxShape.rectangle,
        boxShadow:
            showShadow
                ? [
                  BoxShadow(
                    color:
                        context
                            .theme
                            .buttonTheme
                            .colorScheme
                            ?.secondaryContainer ??
                        AppColors.transparent,
                    blurRadius: 10,
                    offset: const Offset(5, 5),
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color:
                        context
                            .theme
                            .buttonTheme
                            .colorScheme
                            ?.primaryContainer ??
                        AppColors.transparent,
                    blurRadius: 10,
                    offset: -const Offset(5, 5),
                    spreadRadius: 8,
                  ),
                ]
                : null,
      ),
      child: child,
    );
  }
}
