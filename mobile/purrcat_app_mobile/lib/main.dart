import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'utils/routes.dart';
import 'ui/features/auth/view_models/auth_provider.dart';
import 'ui/core/theme.dart';

void main() {
  runApp(const PurrCatApp());
}

class PurrCatApp extends StatelessWidget {
  const PurrCatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp.router(
        title: 'PurrCat App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: brandPink),
          useMaterial3: true,
        ),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
