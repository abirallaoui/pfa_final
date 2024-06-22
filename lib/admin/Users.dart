import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {
  final Map<String, dynamic>? user;

  UserScreen({Key? key, this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Accéder au nom de l'utilisateur
    String? userName = user?['nom'];
    /* pour aficher le nom
     child: Text(
                "Nom de l\'utilisateur : ${userName ?? "Nom inconnu"},", // Text to display
                style: TextStyle(
                  fontSize: 20, // Adjust font size as needed
                  fontWeight: FontWeight.bold, // Make the text bold
                  color: Colors.blue[900], // Set text color
                ),
              ),
    */
    return  Scaffold(
      body:
      Column(
        children: [
          Center( // Center the text horizontally
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Dashboard", // Text to display
                style: TextStyle(
                  fontSize: 20, // Adjust font size as needed
                  fontWeight: FontWeight.bold, // Make the text bold
                  color: Colors.blue[900], // Set text color
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4, // Three cards in each row
              crossAxisSpacing: 10, // Spacing between cards horizontally
              mainAxisSpacing: 10, // Spacing between cards vertically
              padding: EdgeInsets.all(16),
              children: [
                _buildCard("Users"),
                _buildCard("Professeur"),
                _buildCard("Etudiants(e)"),

              ],
            ),
          ),
        ],
      ),

    );


  }

  Widget _buildCard(String title) {
    return Container(
      height: 60, // Adjust the height as needed
      width: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // Set the border radius of the card
      ),
      child: Card(
        child: ListTile(
          leading: Icon(Icons.show_chart),
          title: Text(
            title,
            textAlign: TextAlign.center,
            // Align the text to the center
          ),
          onTap: () {
            // Handle onTap event for each card
            print('Tapped on $title');
            // You can navigate or perform other actions based on the tapped card
          },
        ),
      ),
    );
  }}