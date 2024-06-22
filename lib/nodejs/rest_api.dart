import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pfa/nodejs/utils.dart';
Future<Map<String, dynamic>> userLogin(String email, String password, String deviceId) async {
  final Uri uri = Uri.parse('${Utils.baseUrl}/crud/login');
  final response = await http.post(
    uri,
    headers: {"Accept": "application/json"},
    body: {'email': email, 'password': password, 'deviceId': deviceId},
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to login. Status code: ${response.statusCode}. Body: ${response.body}');
  }
}


//select niveau
Future<dynamic> NiveauCards() async {
  final Uri uri = Uri.parse('${Utils.baseUrl}/crud/niveau');
  final response = await http.get(uri, headers: {"Accept": "application/json"});
  return jsonDecode(response.body);
}


Future<dynamic> addCardNiveau(String niveau,String listetd) async {
  final response = await http.post(
    Uri.parse('${Utils.baseUrl}/crud/addNiveau'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'NomNiveau': niveau,'listEtd':listetd}),
  );

  if (response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to add card');
  }
}
Future<void> updateCardNiveau( int niveauId, String newNom, String newListStd) async {
  final requestBody = {
    'newNom': newNom,
    'newListStd': newListStd,
  };

  final response = await http.put(
    Uri.parse('${Utils.baseUrl}/crud/niveau/$niveauId/update'),
    headers: {"Accept": "application/json", "Content-Type": "application/json"},
    body: jsonEncode(requestBody),
  );
  if (response.statusCode == 201) {
    return jsonDecode(response.body);
  } else if (response.statusCode == 400) {
    // Handle bad request error
    print("Update failed due to bad request: ${response.body}");
  } else {
    // Handle other status codes
    print("Update failed with status code: ${response.statusCode}");
  }


}
Future<dynamic> deleteNiveau( int niveauId) async {
  final response = await http.delete(
    Uri.parse('${Utils.baseUrl}/crud/niveau/$niveauId'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else if (response.statusCode == 400) {
    // Handle bad request error
    print("Update failed due to bad request: ${response.body}");
  } else {
    // Handle other status codes
    print("Update failed with status code: ${response.statusCode}");
  }
}

//  Future<List<String>> getAllNiveaux() async {
//     final response = await http.get(Uri.parse('${Utils.baseUrl}/crud/niveaux')); // Remplacez par l'URL de votre API pour récupérer les niveaux

//     if (response.statusCode == 200) {
//       // Si la requête réussit, convertir la réponse en liste de niveaux
//       final List<dynamic> data = json.decode(response.body);
//       return data.map<String>((item) => item['nom']).toList();
//     } else {
//       // Si la requête échoue, lancer une exception avec le message d'erreur
//       throw Exception('Échec de la récupération des niveaux: ${response.statusCode}');
//     }
//   }


Future<List<String>> fetchNiveauxFromDatabase() async {
  final response = await http.get(Uri.parse('${Utils.baseUrl}/crud/niveaux'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    
    if (data is Map && data.containsKey('niveaux')) {
      final niveaux = data['niveaux'] as List;
      return niveaux.map((niveau) => niveau['nom'].toString()).toList();
    } else {
      throw Exception('Format de données invalide pour les niveaux');
    }
  } else {
    throw Exception('Échec de la récupération des niveaux');
  }
}


Future<void> updateUserProfile({
  required String nom,
  required String prenom,
  required String email,
  required String password,
  required int userId,
}) async {
  try {
    final requestBody = {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'password': password,
    };

    final response = await http.put(
      Uri.parse('${Utils.baseUrl}/profil/$userId/update'),
      headers: {"Accept": "application/json", "Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print('Données de l\'utilisateur mises à jour avec succès');
      // Vous pouvez retourner un booléen ou une autre valeur selon vos besoins
    } else {
      print('Erreur lors de la mise à jour des données de l\'utilisateur');
      // Vous pouvez lancer une exception ou retourner un booléen indiquant l'échec
    }
  } catch (e) {
    print('Erreur lors de la mise à jour des données de l\'utilisateur: $e');
    // Vous pouvez lancer une exception ou retourner un booléen indiquant l'échec
  }
}
//changement de mot de passe apres la premiere connexion 
Future<Map<String, dynamic>> updatePassword(int userId, String newPassword) async {
  try {
    final response = await http.post(
      Uri.parse('${Utils.baseUrl}/crud/updatepassword'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      return jsonDecode(response.body);
    } else {
      print('Failed to update password: ${response.statusCode}');
      throw Exception('Failed to update password');
    }
  } catch (e) {
    print('Error in updatePassword: $e');
    throw Exception('Failed to update password');
  }
}



//modules d'un prof
Future<dynamic> ModuleCards(String userEmail) async {
  final Uri uri = Uri.parse('${Utils.baseUrl}/crud/cards/$userEmail');
  final response = await http.get(uri, headers: {"Accept": "application/json"});
  return jsonDecode(response.body);
}


Future<List<dynamic>> fetchModules(int userId) async {
  print('URL: ${Utils.baseUrl}/moduleStudent/modules/$userId'); // Ligne ajoutée
  final Uri uri = Uri.parse('${Utils.baseUrl}/moduleStudent/modules/$userId');
  final response = await http.get(Uri.parse('${Utils.baseUrl}/moduleStudent/modules/$userId'), headers: {"Accept": "application/json"});
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print('$userId');
    throw Exception('Failed to load modules: ${response.statusCode}');
  }
  
}


//hajar rapport
Future<List<Map<String, dynamic>>> fetchStudentsData(String niveau, String module ,DateTime date) async {
  final response = await http.get(
    Uri.parse('${Utils.baseUrl}/crud/stud?niveau=$niveau&module=$module&date=$date'),

  );


  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((item) => {
      'Lname': item['Lname'],
      'Fname': item['Fname'],
      'status': item['status'],
      'date':item['date'],
    }).toList();

  } else {
    throw Exception('Erreur lors de la récupération des données des étudiants ');
  }
}



// Méthode pour récupérer les niveaux associés au professeur depuis l'API
Future<List<String>> fetchNiveauxFromAPI(String profEmail) async {
  // URL de l'API pour récupérer les niveaux associés au professeur
  String apiUrl = '${Utils.baseUrl}/crud/niveauxp/$profEmail';

  try {
    // Faire la requête HTTP GET pour récupérer les niveaux depuis l'API
    http.Response response = await http.get(Uri.parse(apiUrl));

    // Vérifier si la requête a réussi
    if (response.statusCode == 200) {
      // Extraire les données de la réponse JSON
      Map<String, dynamic> data = json.decode(response.body);
print(data);
      // Vérifier si les données contiennent la clé 'niveaux'
      if (data.containsKey('niveaux')) {
        // Extraire la liste de niveaux
        List<dynamic> niveauxData = data['niveaux'];

        List<String> niveaux = niveauxData.map((item) => item as String).toList();
print(niveaux);
        // Retournez la liste des niveaux obtenus depuis l'API
        return niveaux;
      } else {
        // Si la clé 'niveaux' est manquante dans les données, lancer une exception
        throw Exception('Clé "niveaux" manquante dans la réponse JSON');
      }
    } else {
      // En cas d'erreur de la requête, lancer une exception avec le message d'erreur
      throw Exception('Échec de la requête: ${response.statusCode}');
    }
  } catch (e) {
    // En cas d'erreur lors de la récupération des données, lancer une exception avec le message d'erreur
    throw Exception('Échec de la récupération des niveaux: $e');
  }
}

Future<List<String>> fetchModulesForProf(String profEmail) async {
  // URL de l'API pour récupérer les niveaux associés au professeur
  String apiUrl = '${Utils.baseUrl}/crud/modulep/$profEmail';

  try {
    // Faire la requête HTTP GET pour récupérer les niveaux depuis l'API
    http.Response response = await http.get(Uri.parse(apiUrl));
    print("hajar");
    // Vérifier si la requête a réussi
    if (response.statusCode == 200) {
      // Extraire les données de la réponse JSON
      Map<String, dynamic> data = json.decode(response.body);
      print(data);
      // Vérifier si les données contiennent la clé 'niveaux'
      if (data.containsKey('modules')) {
        // Extraire la liste de niveaux
        List<dynamic> modulesData = data['modules'];

        // Mapper les données pour obtenir une liste de noms de niveaux
        List<String> modules = modulesData.map((item) => item as String).toList();
        print(modules);
        // Retournez la liste des niveaux obtenus depuis l'API
        return modules;
      } else {
        // Si la clé 'niveaux' est manquante dans les données, lancer une exception
        throw Exception('Clé "niveaux" manquante dans la réponse JSON');
      }
    } else {
      // En cas d'erreur de la requête, lancer une exception avec le message d'erreur
      throw Exception('Échec de la requête: ${response.statusCode}');
    }
  } catch (e) {
    // En cas d'erreur lors de la récupération des données, lancer une exception avec le message d'erreur
    throw Exception('Échec de la récupération des niveaux: $e');
  }
}

Future<bool> checkDevice(int userId, String deviceId) async {
    final Uri uri = Uri.parse('${Utils.baseUrl}/crud/check-device-association');
    final response = await http.post(
      uri,
      headers: {"Accept": "application/json"},
      body: {'userId': userId.toString(), 'deviceId': deviceId},
    );

    var decodedData = jsonDecode(response.body);
    return decodedData['isAssociated'];
  }

  Future<void> associateDevice(int userId, String deviceId) async {
    final Uri uri = Uri.parse('${Utils.baseUrl}/crud/associate-device');
    await http.post(
      uri,
      headers: {"Accept": "application/json"},
      body: {'userId': userId.toString(), 'deviceId': deviceId},
    );
  }




