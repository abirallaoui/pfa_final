// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pfa/nodejs/utils.dart';

import '../nodejs/rest_api.dart';


class ModulesScreen extends StatefulWidget {
  final String email;

  const ModulesScreen ({Key? key, required this.email}) : super(key: key);
  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  List _modules = [];
  String _searchQuery = '';
  List _filteredModuleNames = [];
  final _formKey = GlobalKey<FormState>();
  final _cardNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchModuleCards();
  }

  Future<void> _fetchModuleCards() async {
    final userEmail = widget.email;
    final modules = await ModuleCards(userEmail);
    setState(() {
      _modules = modules;
      _filteredModuleNames = modules;

    });
  }

  void _filterModuleNames() {
    setState(() {
      _filteredModuleNames = _modules.where((niveau) {
        return niveau['nom'].toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center( // Center the text horizontally
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Modules", // Text to display
                style: TextStyle(
                  fontSize: 20, // Adjust font size as needed
                  fontWeight: FontWeight.bold, // Make the text bold
                  color: Colors.blue[900], // Set text color
                ),
              ),
            ),
          ),

         Container(
            padding: EdgeInsets.all(16.0),
            width: 400,
            height: 70,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _filterModuleNames();
              },
              decoration: InputDecoration(
                hintText: 'Search Module',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.only(left: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: _filteredModuleNames.length,
              itemBuilder: (context, index) {
                final modules = _filteredModuleNames[index];
                return Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0,0),
                  height: 60, // set the height of the cardwidth: 200, // set the width of the card
                  decoration: BoxDecoration(// set the background color of the card
                    borderRadius: BorderRadius.circular(10), // set the border radius of the card
                  ),
                  child: Card(
                    child: ListTile(
                      title: Text(modules['nom']),


                    ),
                  ),
                );

              },
            ),
          ),
        ],
      ),

    );
  }
}