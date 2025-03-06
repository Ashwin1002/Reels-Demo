import 'package:flutter/cupertino.dart';
import 'package:reels_demo/core/core.dart';
import 'package:reels_demo/core/extensions/num_extension.dart';

/// Abstract class defining the common API for IconCountBuilder.
abstract class IconCountBuilder extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const IconCountBuilder({
    super.key,
    required this.count,
    required this.onPressed,
  });
}

/// The default concrete implementation of IconCountBuilder.
class DefaultIconCountBuilder extends IconCountBuilder {
  final String path;
  final Color? color;
  final double? size;

  const DefaultIconCountBuilder({
    super.key,
    required super.count,
    required super.onPressed,
    required this.path,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TapBouncer(
          onPressed: onPressed,
          child: ImageViewer(
            path: path,
            size: size ?? 30.0,
            color: color ?? AppColors.white,
          ),
        ),
        Text(
          count.toCountFormat(),
          style: context.theme.textTheme.labelMedium?.copyWith(
            color: AppColors.white70,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}
