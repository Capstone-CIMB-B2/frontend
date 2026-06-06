import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/transfer_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/tagihan_screen.dart';
import 'screens/qris_screen.dart';

void main() {
  runApp(const OctoApp());
}

class AuthState {
  static bool isLoggedIn = false;
}

class OctoApp extends StatelessWidget {
  const OctoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCTO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFCC0000)),
        useMaterial3: true,
        fontFamily: 'Calibri',
      ),

      home: const OctoSplashScreen(),

      routes: {
        '/login':        (context) => const LoginScreen(),
        '/register':     (context) => const Placeholder(),
        '/transfer':     (context) => const TransferScreen(),
        '/tagihan':      (context) => const TagihanScreen(),
        '/tanpa-kartu':  (context) => const Placeholder(),
        '/kartu':        (context) => const Placeholder(),
        '/verify':       (context) => const Placeholder(),
        '/jadwal':       (context) => const Placeholder(),
        '/investasi':    (context) => const Placeholder(),
        '/promo':        (context) => const Placeholder(),
        '/tabungan':     (context) => const Placeholder(),
        '/qris':         (context) => const QrisScreen(),
        '/account':      (context) => const Placeholder(),
        '/wealth':       (context) => const Placeholder(),
        '/settings':     (context) => const Placeholder(),

        // ── Route khusus: setelah login berhasil ──
        '/home-loggedin': (context) => const OctoHomeScreenLoggedIn(),
      },
    );
  }
}
