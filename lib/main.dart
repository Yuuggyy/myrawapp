import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/projects/projects_screen.dart';
import 'presentation/screens/projects/new_project_screen.dart';
import 'presentation/screens/chat/chat_screen.dart';
import 'presentation/screens/kyc/kyc_screen.dart';
import 'presentation/screens/transfer/transfer_screen.dart';
import 'presentation/screens/accounts/accounts_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';

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

class MyRawApp extends StatelessWidget {
  const MyRawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyRawApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => const DashboardScreen());
          case '/projects':
            return MaterialPageRoute(builder: (_) => const ProjectsScreen());
          case '/projects/new':
            return MaterialPageRoute(builder: (_) => const NewProjectScreen());
          case '/kyc':
            return MaterialPageRoute(builder: (_) => const KycScreen());
          case '/transfer':
            return MaterialPageRoute(builder: (_) => const TransferScreen());
          case '/accounts':
            return MaterialPageRoute(builder: (_) => const AccountsScreen());
          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfileScreen());
          default:
            // Handle dynamic routes like /projects/:id and /projects/:id/chat
            final uri = Uri.parse(settings.name ?? '/');
            if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'projects') {
              final projectId = uri.pathSegments[1];
              return MaterialPageRoute(
                builder: (_) => ChatScreen(projectId: projectId),
              );
            }
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text('Page introuvable: ${settings.name}')),
              ),
            );
        }
      },
    );
  }
}
