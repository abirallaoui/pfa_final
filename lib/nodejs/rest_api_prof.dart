import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pfa/nodejs/utils.dart';
import 'package:pfa/admin/models/professor.dart';

class RestApi {
  static Future<List<Professor>> fetchProfessors() async {
    final response = await http.get(Uri.parse('${Utils.baseUrl}/crud/professors'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Professor.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load professors');
    }
  }

  static Future<Professor> fetchProfessor(int id) async {
    final response = await http.get(Uri.parse('${Utils.baseUrl}/crud/professor/$id'));
    if (response.statusCode == 200) {
      return Professor.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load professor');
    }
  }

  static Future<void> addProfessor(String nom, String prenom, String email, String password) async {
    final response = await http.post(
      Uri.parse('${Utils.baseUrl}/crud/addProfessor'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode({'nom': nom, 'prenom': prenom, 'email': email, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add professor');
    }
  }

  static Future<void> deleteProfessor(int id) async {
    final response = await http.delete(Uri.parse('${Utils.baseUrl}/crud/deleteProfessor/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete professor');
    }
  }

  static Future<void> updateProfessor(int id, String nom, String prenom, String email, String password) async {
    final response = await http.put(
      Uri.parse('${Utils.baseUrl}/crud/updateProfessor/$id'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode({'nom': nom, 'prenom': prenom, 'email': email, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update professor');
    }
  }
}