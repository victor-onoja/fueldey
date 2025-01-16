import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fueldey/auth/auth_bloc.dart';
import 'package:fueldey/auth/auth_repo.dart';
import 'package:fueldey/business_logic/fuel_station/fuel_station_repository.dart';
import 'package:fueldey/business_logic/map/map_screen_bloc.dart';
import 'package:fueldey/splash_screen.dart';
import 'package:fueldey/utils/app_theme_colors.dart';
import 'package:fueldey/utils/location_service.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseApp = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(FuelFinderApp(firebaseApp: firebaseApp));
}

class FuelFinderApp extends StatelessWidget {
  final FirebaseApp firebaseApp;
  const FuelFinderApp({super.key, required this.firebaseApp});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (context) => FirebaseAuthRepository()),
          RepositoryProvider(create: (context) => FuelStationRepository()),
          RepositoryProvider(create: (context) => LocationService())
        ],
        child: MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (context) => AuthBloc(
                      authRepository: context.read<FirebaseAuthRepository>())),
              BlocProvider(
                  create: (context) => MapScreenBloc(
                      locationService: context.read<LocationService>(),
                      fuelStationRepository:
                          context.read<FuelStationRepository>()))
            ],
            child: MaterialApp(
              title: 'Fuel Finder',
              theme: AppTheme.lightTheme,
              debugShowCheckedModeBanner: false,
              home: const SplashScreen(),
            )));
  }
}
