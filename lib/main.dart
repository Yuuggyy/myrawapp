import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/projects/projects_screen.dart';
import 'presentation/screens/projects/new_project_screen.dart';
import 'presentation/screens/chat/chat_screen.dart';
import 'presentation/screens/kyc/kyc_screen.dart';
import 'presentation/screens/transfer/transfer_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyRawApp());
}

final GoRouter _router = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
    GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
    GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterScreen()),
    GoRoute(path: AppRoutes.forgotPassword, builder: (_, __) => const LoginScreen()),
    GoRoute(path: AppRoutes.dashboard, builder: (_, __) => const DashboardScreen()),
    GoRoute(path: AppRoutes.projects, builder: (_, __) => const ProjectsScreen()),
    GoRoute(path: AppRoutes.newProject, builder: (_, __) => const NewProjectScreen()),
    GoRoute(
      path: '/projects/:id/chat',
      builder: (_, state) => ChatScreen(projectId: state.pathParameters['id']!),
    ),
    GoRoute(path: AppRoutes.kyc, builder: (_, __) => const KycScreen()),
    GoRoute(path: '/transfer', builder: (_, __) => const TransferScreen()),
  ],
  errorBuilder: (_, state) => Scaffold(
    body: Center(child: Text('Page introuvable: ${state.uri}')),
  ),
);

class MyRawApp extends StatelessWidget {
  const MyRawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MyRawApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
