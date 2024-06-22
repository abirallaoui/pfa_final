import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Niveau.dart';
import 'Student.dart';
import 'Users.dart';
import 'package:pfa/admin/prof.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../nodejs/rest_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import '../nodejs/rest_api.dart';






enum SideBarItem {
  // Users(value: 'Dashboard', iconData: Icons.dashboard, body: UserScreen()),
  Niveau(value: 'Niveau', iconData: Icons.backpack, body: NiveauScreen()),
  Prof(value: 'Professeur', iconData: Icons.perm_identity_sharp, body: ProfesseurScreen()),

  Student(value: 'Etudiants', iconData: Icons.school, body: StudentScreen());
  
  const SideBarItem({required this.value, required this.iconData, required this.body});
  
  final String value;
  final IconData iconData;
  final Widget body;
}

final sideBarItemProvider = StateProvider<SideBarItem>((ref) => SideBarItem.Student);
final isProfileSelectedProvider = StateProvider<bool>((ref) => true);

class ProfilScreen extends ConsumerWidget {
  final Map<String, dynamic>? user;
  
  
  const ProfilScreen({Key? key, this.user}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sideBarItem = ref.watch(sideBarItemProvider);
    final isProfileSelected = ref.watch(isProfileSelectedProvider);
    final sideBarkey = ValueKey(Random().nextInt(1000000));
    
    return AdminScaffold(
      appBar: AppBar(
        title: const Text('Espace Admin'),
        backgroundColor: Colors.grey.shade300,
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 14),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      sideBar: SideBar(
        selectedRoute: sideBarItem.value,
        key: sideBarkey,
        backgroundColor: Colors.grey.shade300,
        borderColor: Colors.grey.shade300,
        textStyle: const TextStyle(color: Colors.black, fontSize: 14),
        activeTextStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        activeBackgroundColor: Color(0xFF1976D2),
        header: Container(
          height: 150,
          width: double.infinity,
          color: Colors.grey.shade300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                backgroundImage: NetworkImage("https://cdn-icons-png.flaticon.com/256/3899/3899618.png"),
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
          if (item.route == '/profil') {
            ref.read(isProfileSelectedProvider.notifier).state = true;
            
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilScreen(user: user)));
          } else if (item.route == '/login') {
            // Gérer la navigation vers la page de connexion (ou la suppression du token d'authentification, etc.)
            // Par exemple:
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          } else {
            ref.read(sideBarItemProvider.notifier).state = getSideBarItem(item);
            ref.read(isProfileSelectedProvider.notifier).state = false;
          }
        },
        items: [
          ...SideBarItem.values.map((e) => AdminMenuItem(
            title: e.value,
            icon: e.iconData,
            route: e.value,
            
          )),
          const AdminMenuItem(
            title: 'Profil',
            route: '/profil',
            icon: Icons.person,
          ),
          const AdminMenuItem(
            title: 'Log out',
            route: '/login',
            icon: Icons.logout,
          ),
        ],
      ),
      body: isProfileSelected ? buildProfileBody(context,user) : sideBarItem.body, // Utilisation de l'état actuel pour déterminer le corps à afficher
    );
  }
  
  SideBarItem getSideBarItem(AdminMenuItem item) {
    for (var value in SideBarItem.values) {
      if (item.route == value.value) {
        return value;
      }
    }
    return SideBarItem.Student;
  }

  
  

Widget buildProfileBody(BuildContext context, Map<String, dynamic>? user) {
  // Contrôleurs de texte pour les champs du formulaire
  TextEditingController nomController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Remplissage des contrôleurs de texte si des données utilisateur sont disponibles
  if (user != null) {
    nomController.text = user['nom'] ?? '';
    prenomController.text = user['prenom'] ?? '';
    emailController.text = user['email'] ?? '';
    passwordController.text = user['password'] ?? '';
  }

  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                SizedBox(width: 10),
                Text(
                  'Mon Profil ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Champs de texte pour le nom
            TextField(
              controller: nomController,
              decoration:const  InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Champs de texte pour le prénom
            TextField(
              controller: prenomController,
              decoration: const InputDecoration(
                labelText: 'Prénom',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Champs de texte pour l'adresse email
            TextField(
              controller: emailController,
              decoration:const InputDecoration(
                labelText: 'Adresse email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Champs de texte pour le mot de passe
            TextField(
              controller: passwordController,
              obscureText: true, // Pour cacher le mot de passe
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Bouton pour sauvegarder les changements
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                ),
                onPressed: () async {
                  String nom = nomController.text;
                  String prenom = prenomController.text;
                  String email = emailController.text;
                  String password = passwordController.text;
                  int userId = user!['id']; // Récupérer l'ID de l'utilisateur

                  // // Construction du corps de la requête
                  // final requestBody = {
                  //   'nom': nom,
                  //   'prenom': prenom,
                  //   'email': email,
                  //   'password': password,
                  // };

                  // // Envoi de la requête de mise à jour
                  // final response = await http.put(
                  //   Uri.parse('http://localhost:3000/profil/$userId/update'),
                  //   headers: {"Accept": "application/json", "Content-Type": "application/json"},
                  //   body: jsonEncode(requestBody),
                  // );

                  // // Traitement de la réponse
                  // if (response.statusCode == 200) {
                  //   // La mise à jour a réussi
                  //   print('Données de l\'utilisateur mises à jour avec succès');
                  //   Fluttertoast.showToast(
                  //     msg: "Données modifiées avec succès.",
                  //     toastLength: Toast.LENGTH_SHORT,
                  //     gravity: ToastGravity.CENTER,
                  //   );
                  // } else {
                  //   // La mise à jour a échoué
                  //   print('Erreur lors de la mise à jour des données de l\'utilisateur');
                  //   Fluttertoast.showToast(
                  //     msg: "Erreur lors de la modification de données.",
                  //     toastLength: Toast.LENGTH_SHORT,
                  //     gravity: ToastGravity.CENTER,
                  //   );
                  // }
                // Appel de la fonction pour mettre à jour le profil
              await updateUserProfile(
                nom: nom,
                prenom: prenom,
                email: email,
                password: password,
                userId: userId,
              );

              // Affichage du toast après la mise à jour
              Fluttertoast.showToast(
                msg: "Données modifiées avec succès.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
              );
            },
                child: const Text('Sauvegarder les changements',      
                       style: TextStyle(color: Colors.white), // Couleur du texte blanc
                      ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}