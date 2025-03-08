sealed class AppState<T> {
  const AppState();
}

class InitialState<T> extends AppState<T> {
  const InitialState();
}

class LoadingState<T> extends AppState<T> {
  const LoadingState();
}

class ErrorState<T> extends AppState<T> {
  const ErrorState(this.exception);

  final Exception exception;
}

class LoadedState<T> extends AppState<T> {
  const LoadedState(this.data);
  final T data;
}

extension AppStateExt<T> on AppState<T> {
  bool get isInitial => this is InitialState;
  bool get isLoading => this is LoadingState;
  bool get isError => this is ErrorState;
  bool get isLoaded => this is LoadedState;

  bool get isFinalState => isError || isLoaded;

  A when<A>({
    required A Function(Exception e) error,
    required A Function() loading,
    required A Function(T data) loaded,
  }) {
    return switch (this) {
      InitialState() || LoadingState() => loading(),
      ErrorState(:final exception) => error(exception),
      LoadedState(:final data) => loaded(data),
    };
  }
}
