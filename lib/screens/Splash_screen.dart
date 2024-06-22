

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pfa/screens/login/login_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../admin/DashboardAdmin.dart';
import 'package:pfa/prof/DashboardProf.dart';
import 'package:pfa/student/DashboardStudent.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SharedPreferences? _sharedPreferences;

  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    await Future.delayed(Duration(seconds: 2));
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    final int? userId = _sharedPreferences?.getInt('userid');
    final String? userEmail = _sharedPreferences?.getString('usermail');
    final String? userRole = _sharedPreferences?.getString('role');

    print('UserId: $userId, UserEmail: $userEmail, UserRole: $userRole'); // Débogage

    if (userId == null || userEmail == null) {
      _navigateToLogin();
    } else {
      _navigateToDashboard(userRole);
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginModel()),
    );
  }

  void _navigateToDashboard(String? role) {
    if (role == null) {
      _navigateToLogin();
      return;
    }

    Widget dashboard;
    if (role == 'admin') {
      dashboard = DashboardAdmin(user: {
        'id': _sharedPreferences?.getInt('userid'),
        'email': _sharedPreferences?.getString('usermail'),
        'nom': _sharedPreferences?.getString('username'),
        'role': role
      });
    } else if (role == 'prof') {
      dashboard = DashboardProf(user: {
        'id': _sharedPreferences?.getInt('userid'),
        'email': _sharedPreferences?.getString('usermail'),
        'nom': _sharedPreferences?.getString('username'),
        'role': role
      });
    } else if (role == 'student') {
      dashboard = DashboardStudent(user: {
        'id': _sharedPreferences?.getInt('userid'),
        'email': _sharedPreferences?.getString('usermail'),
        'nom': _sharedPreferences?.getString('username'),
        'role': role
      });
    } else {
      dashboard = LoginModel();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => dashboard),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/logo.jpg"),
          ],
        ),
      ),
    );
  }
}
