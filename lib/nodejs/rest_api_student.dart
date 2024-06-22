import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pfa/admin/models/student.dart';
import 'package:pfa/nodejs/utils.dart';

class RestApi {
  static Future<List<Student>> fetchStudents() async {
    final response = await http.get(Uri.parse('${Utils.baseUrl}/student/students'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Student.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load students');
    }
  }

  static Future<List<Student>> fetchStudentsFromAPI() async {
    final response = await http.get(Uri.parse('${Utils.baseUrl}/student/students'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Student.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load students');}}  





  static Future<Student> fetchstudent(int id) async {
    final response = await http.get(Uri.parse('${Utils.baseUrl}/student/student/$id'));
    if (response.statusCode == 200) {
      return Student.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load student');
    }
  }


  
  static Future<void> addStudent(String nom, String prenom, String email, String password,String niveau) async {
      final response = await http.post(
        Uri.parse('${Utils.baseUrl}/student/addStudent'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode({'nom': nom, 'prenom': prenom, 'email': email, 'password': password, 'niveau': niveau}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to add student');
      }
    }





  static Future<void> UpdateStudent(int id, String newNom, String newPrenom, String newEmail, String newNiveau) async {
    // Construire l'URL de l'API pour la mise à jour de l'étudiant avec son identifiant
    final String apiUrl = 'http://localhost:3000/student/updateStudent/$id'; // Remplacez example.com/api/student/ par l'URL de votre API
    
    try {
      // Effectuer une requête PUT vers l'API avec les données de l'étudiant à mettre à jour
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'nom': newNom,
          'prenom': newPrenom,
          'email': newEmail,
          'niveau': newNiveau,

        }),
      );

      if (response.statusCode == 200) {
        // Si la requête est réussie, la mise à jour a été effectuée avec succès
        print('Mise à jour de l\'étudiant réussie');
      } else {
        // Si la requête échoue, afficher le code d'erreur
        throw Exception('Échec de la mise à jour de l\'étudiant: ${response.statusCode}');
      }
    } catch (e) {
      // En cas d'erreur lors de la requête, afficher l'erreur
      throw Exception('Erreur lors de la mise à jour de l\'étudiant: $e');
    }
  }



  static Future<void> deleteStudent(int id) async {
      final response = await http.delete(Uri.parse('${Utils.baseUrl}/student/deleteStudent/$id'));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete student');
      }
  }



//   static Future<void> addStudentsToDatabase(List<Student> students) async {
//   var url = Uri.parse('http://localhost:3000/student/addStudent');

//   try {
//     var response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(students.map((student) => student.toJson()).toList()),
//     );

//     if (response.statusCode == 200) {
//       // Les étudiants ont été ajoutés avec succès
//       ScaffoldMessenger.of(context as BuildContext).showSnackBar(
//         SnackBar(content: Text('Étudiants ajoutés avec succès')),
//       );
//     } else {
//       // Une erreur s'est produite
//       ScaffoldMessenger.of(context as BuildContext).showSnackBar(
//         SnackBar(content: Text('Erreur lors de l\'ajout des étudiants')),
//       );
//     }
//   } catch (e) {
//     // Une exception s'est produite
//     ScaffoldMessenger.of(context as BuildContext).showSnackBar(
//       SnackBar(content: Text('Une erreur est survenue : $e')),
//     );
//   }
// }

// static Future<void> addStudentsToDatabase(List<Student> students) async {
//   final List<Map<String, dynamic>> studentsData = students.map((student) => {
//     'id': student.id,
//     'nom': student.nom,
//     'prenom': student.prenom,
//     'email': student.email,
//     'password': student.password,
//     'niveau': student.niveau,
//   }).toList();

//   final response = await http.post(
//     Uri.parse('http://localhost:3000/student/etudiants'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//     },
//     body: jsonEncode(studentsData),
//   );

//   if (response.statusCode == 200) {
//     print('Students added successfully.');
//     Fluttertoast.showToast(
//         msg: 'Students added successfully.',
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//       );
//   } else {
//     Fluttertoast.showToast(
//         msg: 'Failed to add students to the database.',
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,);
//     throw Exception('Failed to add students to the database.');
    
//   }
// }

  static Future<void> addStudentsToDatabase(List<Student> students) async {
    final List<Map<String, dynamic>> studentsData = students.map((student) => {
      'id': student.id,
      'nom': student.nom,
      'prenom': student.prenom,
      'email': student.email,
      'password': student.password,
      'niveau': student.niveau,
    }).toList();

    final response = await http.post(
      Uri.parse('http://localhost:3000/student/etudiants'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(studentsData),
    );

    if (response.statusCode == 200) {
      print('Students added successfully.');
      Fluttertoast.showToast(
        msg: 'Students added successfully.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } else if (response.statusCode == 400) {
      // Parse the response body to extract invalid students
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final String errorMessage = responseBody['message'];
      final List<dynamic> invalidStudents = responseBody['invalidStudents'];
      final String invalidStudentNames = invalidStudents
          .map((student) => '${student['nom']} ${student['prenom']}')
          .join(', ');

      Fluttertoast.showToast(
        msg: '$errorMessage: $invalidStudentNames',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to add students to the database.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      throw Exception('Failed to add students to the database.');
    }
  }
}



