import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'UP VIMS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: const Color(0xFF0D3B66),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF0D3B66),
            secondary: Color(0xFFF4A261),
            error: Color(0xFFE76F51),
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
          textTheme: GoogleFonts.nunitoTextTheme().apply(
            bodyColor: const Color(0xFF2D3436),
            displayColor: const Color(0xFF2D3436),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: const Color(0xFF0D3B66),
              foregroundColor: Colors.white,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF0D3B66),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isAuthenticated) {
              return const DashboardScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
