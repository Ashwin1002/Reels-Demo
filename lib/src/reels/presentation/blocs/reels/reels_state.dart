part of 'reels_cubit.dart';

class ReelsState extends Equatable {
  const ReelsState({required this.reels});

  final AppState<List<Reels>> reels;

  factory ReelsState.initial() => ReelsState(reels: InitialState());

  @override
  List<Object?> get props => [reels];

  ReelsState copyWith({AppState<List<Reels>>? reels}) {
    return ReelsState(reels: reels ?? this.reels);
  }
}
