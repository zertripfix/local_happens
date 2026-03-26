import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:local_happens/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:local_happens/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:local_happens/firebase_options.dart';
import 'package:local_happens/ui/theme/theme_data.dart';
import 'injection_container.dart' as di;
import 'router/app_router.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/events/presentation/cubit/events_cubit.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('uk_UA', null);

  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
    try {
      await mapsImplementation.initializeWithRenderer(
        AndroidMapRenderer.latest,
      );
    } on PlatformException catch (e) {
      if (e.code == 'Renderer already initialized') {
        debugPrint("Google Maps Renderer already initialized.");
      } else {
        rethrow;
      }
    }
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthCubit>()..listenAuthStateChanges(),
        ),
        BlocProvider(create: (_) => di.sl<AdminCubit>()),
        BlocProvider(create: (_) => di.sl<EventsCubit>()..subscribeEvents()),
        BlocProvider(create: (_) => di.sl<ProfileCubit>()),
        BlocProvider(create: (_) => di.sl<FavoritesCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Local Happens',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
