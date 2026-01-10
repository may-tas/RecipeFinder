import 'package:get_it/get_it.dart';
import 'services/api_service.dart';
import 'services/local_storage_service.dart';
import 'cubit/home_cubit.dart';
import 'cubit/recipe_detail_cubit.dart';
import 'cubit/favorites_cubit.dart';

final locator = GetIt.instance;

Future<void> init() async {
  final localStorageService = LocalStorageService();
  await localStorageService.init();
  locator.registerSingleton<LocalStorageService>(localStorageService);

  locator.registerLazySingleton(() => ApiService());

  // Block/Cubit
  locator.registerFactory(() => HomeCubit(locator()));
  locator.registerFactory(() => RecipeDetailCubit(locator(), locator()));
  locator.registerFactory(() => FavoritesCubit(locator()));
}
