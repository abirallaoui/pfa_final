import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../nodejs/rest_api.dart';
import 'package:pfa/student/DashboardStudent.dart';  // Assurez-vous que ce chemin d'importation est correct

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

  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      nomController.text = widget.user?['nom'] ?? '';
      prenomController.text = widget.user?['prenom'] ?? '';
      emailController.text = widget.user?['email'] ?? '';
      passwordController.text = widget.user?['password'] ?? '';
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Profil'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardStudent(user: widget.user),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mon Profil ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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

                        if (nom.isEmpty || prenom.isEmpty || email.isEmpty || password.isEmpty) {
                          Fluttertoast.showToast(
                            msg: "Veuillez remplir tous les champs.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                          );
                          return;
                        }

                        await updateUserProfile(
                          nom: nom,
                          prenom: prenom,
                          email: email,
                          password: password,
                          userId: userId,
                        );

                        setState(() {
                          widget.user?['nom'] = nom;
                          widget.user?['prenom'] = prenom;
                          widget.user?['email'] = email;
                          widget.user?['password'] = password;
                        });

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
        ),
      ),
    );
  }
}