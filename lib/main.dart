import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const OctoApp());
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
        fontFamily: 'Poppins',
      ),
      home: const OctoHomeScreen(),

      // ➡️ Daftarkan semua route halaman di sini
      // Ganti Placeholder() dengan widget halaman yang sudah kamu buat
      routes: {
        '/login':       (context) => const Placeholder(), // → LoginPage()
        '/register':    (context) => const Placeholder(), // → RegisterPage()
        '/transfer':    (context) => const Placeholder(),
        '/tagihan':     (context) => const Placeholder(),
        '/tanpa-kartu': (context) => const Placeholder(),
        '/kartu':       (context) => const Placeholder(),
        '/verify':      (context) => const Placeholder(),
        '/jadwal':      (context) => const Placeholder(),
        '/investasi':   (context) => const Placeholder(),
        '/promo':       (context) => const Placeholder(),
        '/tabungan':    (context) => const Placeholder(),
        '/qris':        (context) => const Placeholder(),
        '/account':     (context) => const Placeholder(),
        '/wealth':      (context) => const Placeholder(),
        '/settings':    (context) => const Placeholder(),
      },
    );
  }
}