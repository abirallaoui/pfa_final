// import 'dart:ui';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pfa/nodejs/rest_api_prof.dart';
import 'package:pfa/nodejs/utils.dart';
import 'package:pfa/prof/DashboardProf.dart';
import 'package:pfa/screens/login/ChangePassword.dart';
import 'package:pfa/student/DashboardStudent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../admin/DashboardAdmin.dart';
import '../../nodejs/rest_api.dart';
import 'login_model.dart';
export 'login_model.dart';
import 'package:http/http.dart' as http;

import 'package:local_auth/local_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;


class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget>
    with TickerProviderStateMixin {
  late LoginModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late SharedPreferences _sharedPreferences;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();


  LoginModel createModel(BuildContext context,
      LoginModel Function() modelCreator) {
    return modelCreator();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginModel());
    _model.emailAddressController = TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordController = TextEditingController();
    _model.passwordFocusNode ??= FocusNode();
    _model.passwordVisibility = false;
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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


Future _authenticateWithBiometrics() async {
  if (kIsWeb) {
    return true;
  }
  try {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
    print('Can check biometrics: $canCheckBiometrics');
    print('Available biometrics: $availableBiometrics');
    
    if (!canCheckBiometrics) {
      Fluttertoast.showToast(msg: 'L\'authentification biométrique n\'est pas disponible sur cet appareil', textColor: Colors.orange);
      return true;
    }
    
    return await _localAuth.authenticate(
      localizedReason: 'Veuillez vous authentifier pour vous connecter',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: true,
      ),
    );
  } catch (e) {
    print('Erreur lors de l\'authentification biométrique: $e');
    if (e is PlatformException && e.code == 'no_fragment_activity') {
      Fluttertoast.showToast(msg: 'Erreur de configuration de l\'application. Veuillez contacter le support.', textColor: Colors.red);
    } else {
      Fluttertoast.showToast(msg: 'Erreur lors de l\'authentification biométrique', textColor: Colors.orange);
    }
    return true; // Pour ne pas bloquer l'utilisateur
  }
}
Future<void> associateDevice(int userId, String deviceId) async {
    final Uri uri = Uri.parse('${Utils.baseUrl}/crud/associate-device');
    await http.post(
      uri,
      headers: {"Accept": "application/json"},
      body: {'userId': userId.toString(), 'deviceId': deviceId},
    );
  }
  



Future<void> doLogin(String email, String password) async {
  try {
    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: 'Tous les champs sont obligatoires', textColor: Colors.red);
      return;
    }

    String deviceId = await getDeviceId(); // Assurez-vous d'implémenter cette fonction pour obtenir l'ID unique de l'appareil

    var res = await userLogin(email.trim(), password.trim(), deviceId);

    if (res['success']) {
      _proceedWithLogin(res);
    } else {
      Fluttertoast.showToast(msg: res['message'], textColor: Colors.red);
    }
  } catch (e) {
    print('Erreur générale dans doLogin: $e');
    Fluttertoast.showToast(msg: 'Erreur lors de la connexion: $e', textColor: Colors.red);
  }
}
  Future<bool> checkDeviceAssociation(int userId, String deviceId) async {
    // Implémentez l'appel API pour vérifier l'association
    // Retournez true si l'appareil est associé, false sinon
    // Exemple simple :
    return await checkDevice(userId, deviceId);
  }

  Future<void> associateDeviceWithAccount(int userId, String deviceId) async {
    // Implémentez l'appel API pour associer l'appareil
    await associateDevice(userId, deviceId);
  }

  void _proceedWithLogin(Map<String, dynamic> res) async {
  _sharedPreferences = await SharedPreferences.getInstance();
  String userEmail = res['user'][0]['email'];
  String userName = res['user'][0]['nom'];
  int userId = res['user'][0]['id'];
  bool firstLogin = res['user'][0]['first_login'] == 1;

  _sharedPreferences.setInt('userid', userId);
  _sharedPreferences.setString('usermail', userEmail);
  _sharedPreferences.setString('username', userName);
  _sharedPreferences.setBool('first_login', firstLogin);

  if (firstLogin) {
    // Navigate to ChangePassword screen
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ChangePassword(user: res['user'][0])));
  } else {
    // Existing navigation logic
    if (res['user'][0]['role'] == "admin") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardAdmin(user: res['user'][0])));
    } else if (res['user'][0]['role'] == "prof") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardProf(user: res['user'][0])));
    } else if (res['user'][0]['role'] == "student") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardStudent(user: res['user'][0])));
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.transparent, // Couleur de fond transparente
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue, // Bleu
                Colors.black, // Noir
              ],
              stops: [0.0, 1.0],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 700),
                padding:const EdgeInsets.all(16),
                child: Card(
                  color: Colors.lightBlue.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/logo.jpg', // Chemin vers votre image
                          width: 150, // Ajustez la largeur selon vos besoins
                          height: 150, // Ajustez la hauteur selon vos besoins
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Connexion',
                          textAlign: TextAlign.center,
                          style:  TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20), // Espace entre le logo et le formulaire
                        TextFormField(
                          controller: _model.emailAddressController,
                          focusNode: _model.emailAddressFocusNode,
                          autofocus: true,
                          autofillHints: [AutofillHints.email],
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle:  TextStyle(
                              fontFamily: 'Tahoma',
                              color: Colors.blueGrey.shade500,
                              letterSpacing: 0,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white30,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueGrey.shade500,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueGrey.shade500,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueGrey.shade500,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white30,
                          ),
                          style: const TextStyle(
                            fontFamily: 'Readex Pro',
                            letterSpacing: 0,
                          ),
                          minLines: null,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _model.passwordController,
                          focusNode: _model.passwordFocusNode,
                          autofocus: true,
                          autofillHints: [ AutofillHints.password],
                          obscureText: !_model.passwordVisibility,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle:  TextStyle(
                              color: Colors.blueGrey.shade500,
                              fontFamily: 'Tahoma',
                              letterSpacing: 0,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white30,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueGrey.shade500,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueGrey.shade500,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueGrey.shade500,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white30,
                            suffixIcon: InkWell(
                              onTap: () => setState(() =>
                                  _model.passwordVisibility =
                                      !_model.passwordVisibility),
                              focusNode: FocusNode(skipTraversal: true),
                              child: Icon(
                                _model.passwordVisibility
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.blueGrey.shade500,
                                size: 24,
                              ),
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Readex Pro',
                            letterSpacing: 0,
                          ),
                          minLines: null,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            await doLogin(
                              _model.emailAddressController.text,
                              _model.passwordController.text
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 108, 169, 200),
                            padding: EdgeInsets.zero,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Container(
                            width: double.infinity,
                            height: 44,
                            alignment: Alignment.center,
                            child:const Text(
                              'Se connecter',
                              style:  TextStyle(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  }
