import 'package:dog_book/components/custom_drawer.dart';
import 'package:dog_book/screens/auth_screens/forgot_password_screen.dart';
import 'package:dog_book/screens/auth_screens/onboard_screen.dart';
import 'package:dog_book/screens/auth_screens/register_page.dart';
import 'package:dog_book/screens/home_screens/edit_profile_screen.dart';
import 'package:dog_book/screens/home_screens/home_screen.dart';
import 'package:dog_book/screens/home_screens/messages.dart';
import 'package:dog_book/screens/home_screens/next_vaccine_list.dart';
import 'package:dog_book/screens/home_screens/profile_screen.dart';
import 'package:dog_book/screens/home_screens/shop.dart';
import 'package:dog_book/screens/home_screens/shop_buy.dart';
import 'package:dog_book/screens/home_screens/vaccine_status.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth_screens/splash_screen.dart';
import '../screens/auth_screens/login_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/Spalsh',
    routes: [
      GoRoute(
        path: '/Spalsh',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/onboard',
        builder: (context, state) => const OnboardScreen(),
      ),
      GoRoute(
        path: '/notification',
        builder:
            (context, state) =>
                const PetsListScreen(isNotificationEnabled: false),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/drawer',
        builder: (context, state) => const CustomDrawer(),
      ),
      GoRoute(
        path: '/vaccination',
        builder: (context, state) => const VaccinationStatusScreen(petId: ''),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/editProfile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(path: '/shop', builder: (context, state) => const Shops()),
      GoRoute(path: '/messages', builder: (context, state) => const Messages()),
      GoRoute(
        path: '/cartbuy',
        builder: (context, state) => const CartBuyScreen(cartItems: []),
      ),
    ],
  );
}
