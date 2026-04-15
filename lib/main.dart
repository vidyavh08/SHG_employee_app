import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/env_config.dart';
import 'screens/dashboard_screen.dart';
import 'screens/survey_hub_screen.dart';
import 'screens/groups_screen.dart';
import 'screens/collection_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/sakhi_creation_screen.dart';
import 'services/auth_session.dart';

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  if (EnvConfig.isDevMode) {
    HttpOverrides.global = _DevHttpOverrides();
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await AuthSession.instance.init();

  runApp(const EmployeeApp());
}

class EmployeeApp extends StatelessWidget {
  const EmployeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SHG Employee App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AuthSession.instance.isLoggedIn
          ? const MainNavigation()
          : const LoginScreen(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    SakhiCreationScreen(),
    SurveyHubScreen(),
    GroupsScreen(),
    CollectionScreen(),
    ProfileScreen(),
  ];

  final List<NavigationItem> _navItems = [
    NavigationItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    NavigationItem(icon: Icons.person_add_alt_1_rounded, label: 'Create Sakhi'),
    NavigationItem(icon: Icons.assignment_rounded, label: 'Survey'),
    NavigationItem(icon: Icons.groups_rounded, label: 'Groups'),
    NavigationItem(icon: Icons.payments_rounded, label: 'Collect'),
    NavigationItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = _currentIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey[400],
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  const NavigationItem({required this.icon, required this.label});
}
