import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import '../services/auth_manager.dart';

class OctoSplashScreen extends StatefulWidget {
  const OctoSplashScreen({super.key});

  @override
  State<OctoSplashScreen> createState() => _OctoSplashScreenState();
}

class _OctoSplashScreenState extends State<OctoSplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(seconds: 4), _checkLoginStatus);
  }

  Future<void> _checkLoginStatus() async {
    if (!mounted) return;
    final loggedIn = await AuthManager.isLoggedIn();
    if (!mounted) return;

    if (loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OctoHomeScreenLoggedIn()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/background/bg-screen.svg',
              fit: BoxFit.cover,
            ),
          ),
          // Logo Center
          Center(
            child: SvgPicture.asset(
              'assets/octo/octo-by-cimb.svg',
              width: 200,
            ),
          ),
          // Copyright Bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 40.0, right: 40.0, bottom: 40.0),
              child: Text(
                'Hak Cipta, 2026. PT Bank CIMB Niaga Tbk berizin & diawasi oleh Otoritas Jasa Keuangan & Bank Indonesia serta merupakan Peserta Penjaminan LPS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                  height: 1.4,
                  fontFamily: 'Calibri',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
