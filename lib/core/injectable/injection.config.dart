// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:reels_demo/core/core.dart' as _i101;
import 'package:reels_demo/core/network/remote_service_impl.dart' as _i575;
import 'package:reels_demo/src/reels/data/repository/reels_remote_repository_impl.dart'
    as _i1055;
import 'package:reels_demo/src/reels/domain/repositories/reels_remote_repository.dart'
    as _i633;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i101.RemoteService>(() => _i575.RemoteServiceImpl());
    gh.factory<_i633.ReelsRemoteRepository>(
      () => _i1055.ReelsRemoteRepositoryImpl(),
    );
    return this;
  }
}
