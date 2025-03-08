import 'package:flutter/material.dart';
import 'package:reels_demo/core/core.dart';
import 'package:reels_demo/src/reels/presentation/widgets/icon_count_builder.dart';
import 'package:reels_demo/src/reels/presentation/widgets/selectable_icon_count_builder.dart';

const _imageSize = 42.0;

class ReelsActions extends StatelessWidget {
  const ReelsActions({
    super.key,
    this.like = 0,
    this.comment = 0,
    this.bookmark = 0,
    this.share = 0,
  });

  final int like;
  final int comment;
  final int bookmark;
  final int share;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16.0,
        children: [
          UserAvatar(),
          SelectableIconCountBuilder(
            path: AssetList.like,
            count: like,
            onChanged: (value) {},
          ),
          DefaultIconCountBuilder(
            path: AssetList.comment,
            count: comment,
            onPressed: () {},
          ),
          SelectableIconCountBuilder(
            path: AssetList.bookmark,
            count: bookmark,
            onChanged: (value) {},
          ),
          DefaultIconCountBuilder(
            path: AssetList.share,
            count: share,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Stack(
        children: [
          Container(
            width: _imageSize,
            height: _imageSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 1.5),
              image: DecorationImage(
                image: AssetImage(AssetList.user),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 0,
            left: 0,
            child: Container(
              width: 20,
              height: 20,
              padding: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.red,
                border: Border.all(color: AppColors.white, width: 1.5),
              ),
              child: ImageViewer(path: AssetList.add, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
