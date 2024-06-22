import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../nodejs/rest_api.dart';

class ProfilScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  ProfilScreen({Key? key, this.user}) : super(key: key);

  @override
  _ProfilScreenState createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  TextEditingController nomController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _passwordVisible = false; // État pour suivre la visibilité du mot de passe

  @override
  void initState() {
    super.initState();
    // Remplissage des contrôleurs de texte si des données utilisateur sont disponibles
    if (widget.user != null) {
      nomController.text = widget.user?['nom'] ?? '';
      prenomController.text = widget.user?['prenom'] ?? '';
      emailController.text = widget.user?['email'] ?? '';
      passwordController.text = widget.user?['password'] ?? '';
    }
  }

  // Méthode pour basculer la visibilité du mot de passe
  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              TextField(
                controller: nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: prenomController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Adresse email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: !_passwordVisible, // Utilisez l'état pour masquer ou afficher le mot de passe
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  border:const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: _togglePasswordVisibility, // Appel de la méthode pour basculer la visibilité
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
                    int userId = widget.user!['id'];

                    // Vérifier si tous les champs sont remplis
                    if (nom.isEmpty || prenom.isEmpty || email.isEmpty || password.isEmpty) {
                      Fluttertoast.showToast(
                        msg: "Veuillez remplir tous les champs.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                      );
                      return;
                    }

                    // Appel de la fonction pour mettre à jour le profil
                    await updateUserProfile(
                      nom: nom,
                      prenom: prenom,
                      email: email,
                      password: password,
                      userId: userId,
                    );

                    // Mise à jour des données locales de l'utilisateur
                    setState(() {
                      widget.user?['nom'] = nom;
                      widget.user?['prenom'] = prenom;
                      widget.user?['email'] = email;
                      widget.user?['password'] = password;
                    });

                    // Affichage du toast après la mise à jour
                    Fluttertoast.showToast(
                      msg: "Données modifiées avec succès.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                    );
                  },
                  child: const Text(
                    'Sauvegarder les changements',
                    style: TextStyle(color: Colors.white),
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
