import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_routes.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/drilling_repository.dart';
import 'data/services/image_service.dart';
import 'data/services/sensor_service.dart';
import 'ui/drilling_form/drilling_form_screen.dart';
import 'ui/home/home_screen.dart';
import 'ui/home/viewmodels/home_viewmodel.dart';

void main() {
  runApp(const DrillingLogApp());
}

class DrillingLogApp extends StatelessWidget {
  const DrillingLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DrillingRepository>(
          create: (_) => DrillingRepository(),
        ),
        Provider<ImageService>(
          create: (_) => ImageService(),
        ),
        Provider<SensorService>(
          create: (_) => SensorService(),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (context) =>
              HomeViewModel(context.read<DrillingRepository>()),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: AppRoutes.home,
        routes: {
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.drillingForm: (_) => const DrillingFormScreen(),
        },
      ),
    );
  }
}
