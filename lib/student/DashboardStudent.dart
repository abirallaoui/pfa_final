import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pfa/nodejs/rest_api.dart';
import 'dart:convert';
import 'package:pfa/student/qr_scan_page.dart';
import 'package:pfa/student/profil_student.dart';
import 'package:pfa/screens/login/login_widget.dart';
import 'package:pfa/nodejs/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardStudent extends StatefulWidget {
  final Map<String, dynamic>? user;

  const DashboardStudent({Key? key, this.user}) : super(key: key);

  @override
  State<DashboardStudent> createState() => DashboardStudentState();
}

class DashboardStudentState extends State<DashboardStudent> {
  String _searchQuery = '';
  List<Module> _modules = [];
  String _userLevel = ''; // Ajout de la variable pour stocker le niveau de l'utilisateur

  @override
  void initState() {
    super.initState();
    fetchStudentInfo(); // Appel de la fonction pour récupérer les informations de l'étudiant
    f();
  }

  Future<void> f() async {
    try {
      final userId = widget.user!['id'];
      final modules = await fetchModules(userId);

      setState(() {
        _modules = modules.map((moduleJson) => Module.fromJson(moduleJson)).toList();
      });
    } catch (error) {
      print("Error fetching modules: $error");
      // Gérer l'erreur, par exemple afficher un message à l'utilisateur
    }
  }

  Future<void> fetchStudentInfo() async {
    try {
      final userId = widget.user!['id'];
      final response = await http.get(Uri.parse('${Utils.baseUrl}/moduleStudent/info/$userId')); // Remplacez your_api_url_here par l'URL de votre API pour récupérer les informations de l'étudiant
      final data = jsonDecode(response.body);
      final userLevel = data['niveau']; // Supposons que le niveau de l'utilisateur est stocké dans la clé 'level'
      setState(() {
        _userLevel = userLevel; // Mise à jour de l'état avec le niveau de l'utilisateur récupéré
      });
    } catch (error) {
      print("Error fetching student info: $error");
      // Gérer l'erreur, par exemple afficher un message à l'utilisateur
    }
  }
  Future<String> getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceId = 'unknown';

  try {
    if (kIsWeb) {
      WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
      deviceId = webInfo.userAgent ?? 'unknown';
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? 'unknown';
    }
  } catch (e) {
    print('Erreur lors de la récupération de l\'ID de l\'appareil: $e');
  }

  return deviceId;
}
Future<void> doLogout() async {
  print('doLogout called');
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userid');
    final userRole = widget.user!['role'];
    String deviceId = await getDeviceId(); // Assurez-vous d'implémenter cette fonction pour obtenir l'ID unique de l'appareil

    print("UserRole: $userRole");
    print("UserId: $userId");
    print("DeviceId: $deviceId");
    
    if (userId != null) {
      final Uri uri = Uri.parse('${Utils.baseUrl}/crud/logout');
      final response = await http.post(
        uri,
        headers: {"Accept": "application/json"},
        body: {
          'userId': userId.toString(),
          'deviceId': deviceId,
        },
      );
      print("Logout API response: ${response.body}");
      
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          print('Logout successful');
          // Effacez les données de session
          await prefs.clear();
          // Affichez un message de succès
          Fluttertoast.showToast(
            msg: 'Déconnexion réussie',
            textColor: Colors.green,
          );
          // Redirigez vers la page de connexion
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginWidget()));
        } else {
          throw Exception(responseData['message']);
        }
      } else {
        throw Exception('Failed to logout with status code: ${response.statusCode}');
      }
    } else {
      print('User ID is null');
    }
  } catch (e) {
    print('Erreur lors de la déconnexion: $e');
    Fluttertoast.showToast(
      msg: 'Erreur lors de la déconnexion: $e',
      textColor: Colors.red,
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_userLevel, style: TextStyle(color: Colors.white)),
        elevation: 0,
        backgroundColor: Colors.indigoAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              // Logique de recherche
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Container(
              padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 15),
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher des modules',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.indigoAccent,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query.toLowerCase();
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _modules.length,
              itemBuilder: (context, index) {
                final module = _modules[index];
                if (_searchQuery.isEmpty || module.name.toLowerCase().contains(_searchQuery)) {
                  return Card(
                    child: InkWell(
                      onTap: () {
                        // Afficher les détails du module
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.info,
                          animType: AnimType.bottomSlide,
                          title: "Informations : ",
                          desc: "Nom :${module.name} \n Nom du Professeur :${module.nom_prof} \n Description : ${module.description}   ",
                          btnOkText: 'Fermer',
                          width: 600,
                          btnOkOnPress: () {},
                        ).show();
                      },
                      child: ListTile(
                        leading: Icon(
                          module.icon,
                          color: Colors.indigoAccent,
                          size: 50,
                        ),
                        title: Text(
                          module.name,
                          style: TextStyle(color: Colors.indigoAccent),
                        ),
                      ),
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.indigoAccent),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.qr_code, color: Colors.indigoAccent),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRScanner(user: widget.user ?? {})),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.logout, color: Colors.indigoAccent),
              onPressed: () async {
                print('Logout button pressed');
                await doLogout();
                Fluttertoast.showToast(
                  msg: 'Vous pourrez vous reconnecter après 5 minutes',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 5,
                  backgroundColor: Colors.orange,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginWidget()),
                );
              },
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/logo.jpg'),
                    radius: 40,
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.user != null ? '${widget.user!['nom']} ${widget.user!['prenom']}' : '',
                    style: const TextStyle(
                      fontSize: 20,
                      letterSpacing: 3,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.indigoAccent),
              title: Text('Menu'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.qr_code, color: Colors.indigoAccent),
              title: Text('Scanner'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRScanner(user: widget.user ?? {})),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.indigoAccent),
              title: Text('Profil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilScreen(user: widget.user ?? {})),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.indigoAccent),
              title: Text('Logout'),
              onTap: () async {
                print('Logout menu item pressed');
                await doLogout();
                Fluttertoast.showToast(
                  msg: 'Vous pourrez vous reconnecter après 5 minutes',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 5,
                  backgroundColor: Colors.orange,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginWidget()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Module {
  final String name;
  final String description;
  final String nom_prof;
  final IconData icon;

  Module(this.name, this.description, this.nom_prof, this.icon);

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      json['nom'],
      json['description'],
      json['nom_prof'],
      Icons.book, // Vous pouvez remplacer cela par l'icône réelle récupérée de l'API
    );
  }
}
