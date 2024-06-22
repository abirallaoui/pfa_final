import 'dart:math';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:pfa/prof/CodeQR.dart';

import '../admin/Niveau.dart';
import '../admin/Profil.dart';
import 'Modules.dart';
import 'Rapports.dart';
import 'Setting.dart';
import 'constants.dart';
import 'RapportsSmestriel.dart'; // Importer le fichier RapportsSemestriel.dart ici


enum SideBarItem {
  Modules,
  Rapports,
  CodeQR,
  Profil,

}
final userSessionProvider = StateProvider<Map<String, dynamic>?>((ref) => null);
// Fonction pour effacer les données de session de l'utilisateur
void clearUserSession(WidgetRef ref) {
  ref.read(userSessionProvider.notifier).state = null;
}


final sideBarItemProvider = StateProvider<SideBarItem>((ref) => SideBarItem.Modules);

class DashboardProf extends ConsumerWidget {

  final Map<String, dynamic>? user;

  DashboardProf({Key? key, this.user}) : super(key: key);

  Widget getBodyForItem(SideBarItem item) {
    switch (item) {
      case SideBarItem.Modules:
        return ModulesScreen(email: user != null ? user!['email'] : '');
      case SideBarItem.Rapports:
        return RapportsScreen(user: user ?? {});
        
      
      
      case SideBarItem.Profil:
        return ProfilScreen(user: user ?? {});
      case SideBarItem.CodeQR:
        return CodeQRScreen(user: user ?? {});
    }
  }

  SideBarItem getSideBarItem1(AdminMenuItem item) {
    for (var value in SideBarItem.values) {
      if (item.route == value.toString().split('.').last) {
        return value;
      }
    }
    return SideBarItem.Modules;
  }

  final Map<SideBarItem, IconData> sideBarItemIcons = {
    SideBarItem.Modules: Icons.book,
    SideBarItem.Rapports: Icons.assessment,

    SideBarItem.CodeQR: Icons.qr_code,


    SideBarItem.Profil: Icons.person,

  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sideBarItem = ref.watch(sideBarItemProvider);
    final sideBarkey = ValueKey(Random().nextInt(1000000));
    const String stringParam = 'String parameter';
    const int intParam = 1000000;

    return AdminScaffold(
      appBar: AppBar(
        title: const Text('Espace Professeur'),
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(color:Colors.black, fontSize: 14,),
        iconTheme: const IconThemeData(color: Colors.black),
        
      ),
      
      sideBar: SideBar(
        key: sideBarkey,
        backgroundColor: Colors.white,
        borderColor: Colors.white,
        textStyle: const TextStyle(color:Colors.black, fontSize: 14),
        activeTextStyle: const TextStyle(color:Colors.black, fontSize: 14,fontWeight: FontWeight.bold),
        activeBackgroundColor: const Color(0xFF1976D2),
        header: Container(
          height: 150,
          width: double.infinity,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              
              const CircleAvatar(
                backgroundImage:  NetworkImage("https://cdn-icons-png.flaticon.com/256/3899/3899618.png"),
                radius: 50,
              ),
              
              SizedBox(
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
            backgroundColor: Colors.white,
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