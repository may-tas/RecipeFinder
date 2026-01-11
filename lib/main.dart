import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:posha/utils/size_config.dart';
import 'constants/app_strings.dart';
import 'cubit/home_cubit.dart';
import 'cubit/favorites_cubit.dart';
import 'utils/app_router.dart';
import 'utils/app_theme.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive
  await Hive.initFlutter();
  // Initialize Dependency Injection
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final router = AppRouter.router;

    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(
          create: (context) => di.locator<HomeCubit>(),
        ),
        BlocProvider<FavoritesCubit>(
          create: (context) => di.locator<FavoritesCubit>(),
        ),
      ],
      child: MaterialApp.router(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: router,
      ),
    );
  }
}
