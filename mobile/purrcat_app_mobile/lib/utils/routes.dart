import 'package:go_router/go_router.dart';

// Screens
import '../ui/features/auth/views/splash_screen.dart';
import '../ui/features/auth/views/login_screen.dart';
import '../ui/features/auth/views/register_screen.dart';
import '../ui/features/home/views/home_screen.dart';
import '../ui/features/feed/views/feed_screen.dart';
import '../ui/features/marketplace/views/marketplace_screen.dart';
import '../ui/features/feed/views/create_post_screen.dart';

import '../ui/features/marketplace/views/add_product_screen.dart';
import '../ui/features/add_service/views/add_service_screen.dart';
import '../ui/features/profile/views/verification_center_screen.dart';
import '../ui/features/cat_registry/views/cat_registry_screen.dart';
import '../ui/features/cat_registry/views/add_cat_screen.dart';
import '../ui/features/cat_registry/views/cat_detail_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/feed',
      builder: (context, state) => const FeedScreen(),
    ),
    GoRoute(
      path: '/marketplace',
      builder: (context, state) => const MarketplaceScreen(),
    ),
    GoRoute(
      path: '/marketplace/add',
      builder: (context, state) => const AddProductScreen(),
    ),
    GoRoute(
      path: '/feed/create',
      builder: (context, state) => const CreatePostScreen(),
    ),
    GoRoute(
      path: '/services/add',
      builder: (context, state) => const AddServiceScreen(),
    ),
    GoRoute(
      path: '/profile/verifications',
      builder: (context, state) => const VerificationCenterScreen(),
    ),
    GoRoute(
      path: '/cats',
      builder: (context, state) => const CatRegistryScreen(),
    ),
    GoRoute(
      path: '/cats/add',
      builder: (context, state) => const AddCatScreen(),
    ),
    GoRoute(
      path: '/cat-detail/:catId',
      builder: (context, state) {
        final catId = state.pathParameters['catId'] ?? '';
        final ownerId = state.uri.queryParameters['ownerId'];
        return CatDetailScreen(catId: catId, ownerId: ownerId);
      },
    ),
  ],
);
