import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: 'TukarKultur',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: MaterialColor(
            0xFF9C854A, // Your custom color
            <int, Color>{
              50: Color(0xFFF5F2E8),
              100: Color(0xFFE8DFC6),
              200: Color(0xFFD9CAA0),
              300: Color(0xFFCAB57A),
              400: Color(0xFFBFA55E),
              500: Color(0xFF9C854A), // Primary color
              600: Color(0xFF8F7A42),
              700: Color(0xFF7F6D39),
              800: Color(0xFF6F6030),
              900: Color(0xFF594B1F),
            },
          ),
          primaryColor: Color(0xFF9C854A),
          scaffoldBackgroundColor: Color(0xFFFCFAF7), // Cream background
          fontFamily: 'Manrope',
          appBarTheme: AppBarTheme(
            elevation: 0,
            backgroundColor: Color(0xFFFCFAF7),
            foregroundColor: Colors.black,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize authentication on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.initialize().catchError((error) {
        // Handle initialization error
        print('Auth initialization error: $error');
        // Force stop loading if there's an error
        if (mounted) {
          setState(() {
            // Force navigation to login on error
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while initializing
        if (authProvider.isLoading) {
          return Scaffold(
            backgroundColor: Color(0xFFFCFAF7),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.language, size: 80, color: Color(0xFF9C854A)),
                  SizedBox(height: 16),
                  Text(
                    'TukarKultur',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9C854A),
                      fontFamily: 'Manrope',
                    ),
                  ),
                  SizedBox(height: 32),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF9C854A),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Show main app if logged in, otherwise show login screen
        if (authProvider.isLoggedIn) {
          return MainNavigation();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    MapScreen(),
    NotesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Color(0xFFF5F3F0),
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
            _buildNavItem(
              Icons.location_on_outlined,
              Icons.location_on,
              'Map',
              1,
            ),
            _buildNavItem(Icons.note_outlined, Icons.note, 'Notes', 2),
            _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
    int index,
  ) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: isSelected ? Colors.black : Color(0xFF9C854A),
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.black : Color(0xFF9C854A),
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
