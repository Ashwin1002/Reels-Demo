import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:reels_demo/core/constants/colors.dart';
import 'package:reels_demo/src/reels/presentation/widgets/widgets.dart';

class SelectableIconCountBuilder extends StatefulWidget {
  const SelectableIconCountBuilder({
    super.key,
    required this.path,
    this.isSelected,
    this.unSelectedColor,
    this.selectedColor,
    this.count = 0,
    this.onChanged,
  });

  final bool? isSelected;
  final Color? unSelectedColor;
  final Color? selectedColor;
  final String path;
  final int count;
  final void Function(bool value)? onChanged;

  @override
  State<SelectableIconCountBuilder> createState() =>
      _SelectableIconCountBuilderState();
}

class _SelectableIconCountBuilderState
    extends State<SelectableIconCountBuilder> {
  late final ValueNotifier<bool> _isSelectedNotifier;
  late final ValueNotifier<int> _countNotifier;

  @override
  void initState() {
    super.initState();
    _isSelectedNotifier = ValueNotifier(widget.isSelected ?? false);
    _countNotifier = ValueNotifier(widget.count);
    _isSelectedNotifier.addListener(_onSelectionChangeListener);

    log("init called");
  }

  @override
  void didUpdateWidget(covariant SelectableIconCountBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      _isSelectedNotifier.value = widget.isSelected ?? false;
    }

    if (widget.count != oldWidget.count) {
      _countNotifier.value = widget.count;
    }
  }

  @override
  void deactivate() {
    _isSelectedNotifier.removeListener(_onSelectionChangeListener);
    super.deactivate();
  }

  @override
  void dispose() {
    _countNotifier.dispose();
    _isSelectedNotifier.dispose();
    super.dispose();
  }

  void _onSelectionChangeListener() {
    widget.onChanged?.call(_isSelectedNotifier.value);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isSelectedNotifier,
      builder: (context, isSelected, _) {
        final activeColor = isSelected ? AppColors.white : AppColors.red;
        return ValueListenableBuilder<int>(
          valueListenable: _countNotifier,
          builder: (context, count, _) {
            return DefaultIconCountBuilder(
              path: widget.path,
              onPressed: () {
                _isSelectedNotifier.value = !isSelected;
                _countNotifier.value = isSelected ? count-- : count++;
                log('count => $count');
              },
              count: count,
              color: activeColor,
            );
          },
        );
      },
    );
  }
}
