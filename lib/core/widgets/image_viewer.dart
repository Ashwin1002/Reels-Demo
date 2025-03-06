import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reels_demo/core/core.dart';
import 'package:reels_demo/core/extensions/string_extension.dart';

class ImageViewer extends StatelessWidget {
  const ImageViewer({super.key, required this.path, this.color, this.size});

  final String path;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    if (path.isSvg) {
      return SvgPicture.asset(
        path,
        colorFilter:
            color == null
                ? null
                : ColorFilter.mode(
                  color ?? AppColors.transparent,
                  BlendMode.srcIn,
                ),
        height: size,
        width: size,
      );
    }

    return Image.asset(path, height: size, width: size, color: color);
  }
}
