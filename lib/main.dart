import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth/logic/auth_bloc.dart';
import 'auth/logic/auth_repo.dart';
import 'business_logic/fuel_station/fuel_station_repository.dart';
import 'business_logic/map/map_screen_bloc.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'utils/app_theme_colors.dart';
import 'utils/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authRepository = AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );

  final fuelStationRepository = FuelStationRepository(
    firestore: FirebaseFirestore.instance,
  );

  final locationService = LocationService();

  runApp(FuelFinderApp(
    authRepository: authRepository,
    fuelStationRepository: fuelStationRepository,
    locationService: locationService,
  ));
}

class FuelFinderApp extends StatelessWidget {
  final AuthRepository authRepository;
  final FuelStationRepository fuelStationRepository;
  final LocationService locationService;

  const FuelFinderApp({
    super.key,
    required this.authRepository,
    required this.fuelStationRepository,
    required this.locationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: fuelStationRepository),
        RepositoryProvider.value(value: locationService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: authRepository,
            ),
          ),
          BlocProvider(
            create: (context) => MapScreenBloc(
              locationService: locationService,
              fuelStationRepository: fuelStationRepository,
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Fuel Finder',
          theme: ThemeData(
            primaryColor: AppColors.primary,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
            ),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
