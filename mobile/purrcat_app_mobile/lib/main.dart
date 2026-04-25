import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Utils
import 'utils/routes.dart';

// Providers
import 'providers/auth_provider.dart';

void main() {
  runApp(const PurrCatApp());
}

// Global Theme Colors (from feed_screen.dart)
const Color brandPink = Color(0xFFF28C94);
const Color headingColor = Color(0xFF1A1A1A);
const Color bodyColor = Color(0xFF757575);
const Color backgroundColor = Colors.white;

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
