import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Utils
import 'utils/routes.dart';

// Providers
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const PurrCatApp());
}

// Global Theme Colors (corrected to match Figma design)
const Color brandPink = Color(0xFFA03A57);
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
