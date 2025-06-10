import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/server_repository.dart';
import 'services/vpn_engine.dart';
import 'state/vpn_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => VpnProvider(
            repository: ServerRepository(),
            engine: VpnEngine(),
          )..init(),
        ),
      ],
      child: MaterialApp(
        title: 'XVPN',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1), // Основной цвет
            brightness: Brightness.light,
          ).copyWith(
            // Mullvad-inspired colors
            primary: const Color(0xFF5E4EBD), // Глубокий фиолетовый
            secondary: const Color(0xFF7B68EE), // Средний фиолетовый  
            tertiary: const Color(0xFF44337A), // Темный фиолетовый
            surface: const Color(0xFFFFFDF7), // Кремово-белый
            surfaceVariant: const Color(0xFFF3F2F7), // Светло-серый
            outline: const Color(0xFFE0DFE5), // Границы
          ),
          fontFamily: 'Inter', // Современный шрифт
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF44337A),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: const Color(0xFFE0DFE5),
                width: 1,
              ),
            ),
            color: const Color(0xFFFFFDF7),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Color(0xFF5E4EBD), width: 1.5),
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.dark,
          ).copyWith(
            // Mullvad dark theme
            primary: const Color(0xFF8B7CF6), // Светлый фиолетовый
            secondary: const Color(0xFFA78BFA), // Лавандовый
            tertiary: const Color(0xFF6366F1), // Средний фиолетовый
            surface: const Color(0xFF0F0F23), // Очень темный синий
            surfaceVariant: const Color(0xFF1A1B3E), // Темно-фиолетовый
            outline: const Color(0xFF2D2E52), // Границы
          ),
          fontFamily: 'Inter',
        ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.dark,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
          ),
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
