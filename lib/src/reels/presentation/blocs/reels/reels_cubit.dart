import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reels_demo/core/utils/utils.dart';
import 'package:reels_demo/src/reels/domain/entities/reels.dart';
import 'package:reels_demo/src/reels/domain/use_cases/fetch_reels_usecase.dart';

part 'reels_state.dart';

class ReelsCubit extends Cubit<ReelsState> {
  final FetchReelsUsecase _fetchReelsUsecase;
  ReelsCubit()
    : _fetchReelsUsecase = FetchReelsUsecase(),
      super(ReelsState.initial());

  FutureOr<void> fetchReels() async {
    emit(state.copyWith(reels: LoadingState()));
    final result = await _fetchReelsUsecase.call();

    result.fold(
      (l) => emit(state.copyWith(reels: ErrorState(l))),
      (r) => emit(state.copyWith(reels: LoadedState(r))),
    );
  }
}
