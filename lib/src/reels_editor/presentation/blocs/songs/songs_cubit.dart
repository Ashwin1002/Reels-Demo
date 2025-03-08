import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reels_demo/core/utils/utils.dart';
import 'package:reels_demo/src/reels_editor/domain/entities/song.dart';
import 'package:reels_demo/src/reels_editor/domain/usescases/fetch_songs_usecase.dart';

class SongsCubit extends Cubit<AppState<List<Song>>> {
  SongsCubit()
    : _fetchSongsUsecase = FetchSongsUsecase(),
      super(InitialState());

  final FetchSongsUsecase _fetchSongsUsecase;

  FutureOr<void> fetchSongs() async {
    emit(LoadingState());
    final result = await _fetchSongsUsecase.call();
    result.fold((l) => emit(ErrorState(l)), (r) => emit(LoadedState(r)));
  }
}
