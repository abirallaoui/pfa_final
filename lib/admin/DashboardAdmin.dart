import 'dart:math';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:pfa/admin/Profil.dart';
import 'package:pfa/admin/prof.dart';

import 'Niveau.dart';
import 'Student.dart';
import 'Users.dart';

final userSessionProvider = StateProvider<Map<String, dynamic>?>((ref) => null);
// Fonction pour effacer les données de session de l'utilisateur
void clearUserSession(WidgetRef ref) {
  ref.read(userSessionProvider.notifier).state = null;
}

enum SideBarItem {
  dashboard,
  Niveau,
  Professeur,
  Etudiants,
  Profil
}

final sideBarItemProvider = StateProvider<SideBarItem>((ref) => SideBarItem.dashboard);

class DashboardAdmin extends ConsumerWidget {
  final Map<String, dynamic>? user;

  DashboardAdmin({Key? key, this.user}) : super(key: key);

  Widget getBodyForItem(SideBarItem item) {
    switch (item) {
      case SideBarItem.dashboard:
        return UserScreen(user: user ?? {});
      case SideBarItem.Niveau:
        return NiveauScreen();
      case SideBarItem.Professeur:
        return ProfesseurScreen();
      case SideBarItem.Etudiants:
        return StudentScreen();
      case SideBarItem.Profil:
        return ProfilScreen(user: user ?? {});
    }
  }

  SideBarItem getSideBarItem1(AdminMenuItem item) {
    for (var value in SideBarItem.values) {
      if (item.route == value.toString().split('.').last) {
        return value;
      }
    }
    return SideBarItem.dashboard;
  }

  final Map<SideBarItem, IconData> sideBarItemIcons = {
    SideBarItem.dashboard: Icons.dashboard,
    SideBarItem.Niveau: Icons.backpack,
    SideBarItem.Professeur: Icons.person,
    SideBarItem.Etudiants: Icons.school,
    SideBarItem.Profil: Icons.person_2_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sideBarItem = ref.watch(sideBarItemProvider);
    final sideBarkey = ValueKey(Random().nextInt(1000000));
    const String stringParam = 'String parameter';
    const int intParam = 1000000;

    return AdminScaffold(
      appBar: AppBar(
        title: const Text('Espace Admin'),
        backgroundColor: Colors.grey.shade300,
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 14,),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Container(
            width: 100, // Ajustez la largeur selon vos besoins
            height: 100, // Ajustez la hauteur selon vos besoins
            child: Image.asset(
              'assets/logo.jpg', // Remplacez 'assets/your_logo.png' par le chemin de votre image
              fit: BoxFit.cover, // Assurez-vous que l'image remplit le Container sans déformation
            ),
          ),
        ],
      ),
      sideBar: SideBar(
        key: sideBarkey,
        backgroundColor:Colors.grey.shade300,
        borderColor: Colors.grey.shade300,
        textStyle: const TextStyle(color:Colors.black, fontSize: 14),
        activeTextStyle: const TextStyle(color:Colors.black, fontSize: 14,fontWeight: FontWeight.bold),
        activeBackgroundColor: const Color(0xFF1976D2),
        header: Container(
          height: 150,
          width: double.infinity,
          color: Colors.grey.shade300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                backgroundImage:  NetworkImage("https://cdn-icons-png.flaticon.com/256/3899/3899618.png"),
                radius: 50,
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                user != null ? '${user!['nom']} ${user!['prenom']}' : '',
                style: const TextStyle(fontSize: 20, letterSpacing: 3, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        onSelected: (item) {
          ref.read(sideBarItemProvider.notifier).state = getSideBarItem1(item!);
        },
        items: SideBarItem.values
            .map((e) => AdminMenuItem(
            title: e.toString().split('.').last,
            icon: sideBarItemIcons[e],
            route: e.toString().split('.').last))
            .toList(),
        selectedRoute: sideBarItem.name.toString().split('.').last,
        footer: Container(
          height: 50,
          width: double.infinity,
          child: SideBar(
            backgroundColor: Colors.grey.shade300,
            textStyle: const TextStyle(color:Colors.black, fontSize: 16),
            borderColor: Colors.white,
            items: const [
              AdminMenuItem(
                title: 'Log out',
                route: '/login',
                icon: Icons.logout,
              ),
            ],
            selectedRoute:'/',
            onSelected: (item) {
              if (item!.route != null && item.route == '/login') {
    // Effacer les données de session de l'utilisateur
    clearUserSession(ref);

    // Rediriger vers la page de connexion
    Navigator.of(context).pushReplacementNamed(item.route!);                
              }
            },
          ),
        ),
      ),
      body: getBodyForItem(sideBarItem),
    );
  }
}
