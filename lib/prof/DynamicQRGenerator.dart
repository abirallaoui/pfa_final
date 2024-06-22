import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

class DynamicQRGenerator extends StatefulWidget {
  final String staticData1;
  final String staticData2;
  final String staticData3;
  final String staticData4;
  final String niveauName;
  final String moduleName;

  DynamicQRGenerator({
    required this.staticData1,
    required this.staticData2,
    required this.staticData3,
    required this.staticData4,
    required this.niveauName,
    required this.moduleName,
  });

  @override
  _DynamicQRGeneratorState createState() => _DynamicQRGeneratorState();
}

class _DynamicQRGeneratorState extends State<DynamicQRGenerator> {
  Timer? _timer;
  int _counter = 0;
  DateTime? _expiryTime;


  @override
  void initState() {
    super.initState();
        _calculateExpiryTime();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _counter++;
      });
    });
  }
 void _calculateExpiryTime() {
  // Extraire la date et l'heure de la staticData4
  final dateTimeString = widget.staticData4.split(": ")[1];

  // Créer des DateFormat personnalisés pour chaque format
  final defaultDateFormat = DateFormat("yyyy-MM-dd HH:mm:ss.SSS");
  final manualDateFormat = DateFormat("yyyy/M/d H:m");

  // Vérifier le format de la chaîne de date et d'heure
  DateTime dateTime;
  try {
    dateTime = defaultDateFormat.parse(dateTimeString);
  } catch (e) {
    dateTime = manualDateFormat.parse(dateTimeString);
  }

  // Ajouter 15 secondes à cette date et heure pour obtenir la date d'expiration
  _expiryTime = dateTime.add(Duration(minutes: 5));
}
 @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     // Vérifier si toutes les données statiques sont non vides
    if (widget.staticData1.isNotEmpty &&
        widget.staticData2.isNotEmpty &&
        widget.staticData3.isNotEmpty &&
        widget.staticData4.isNotEmpty) {
    
// Vérifier si le code QR est encore valide
      if (_expiryTime != null && DateTime.now().isBefore(_expiryTime!)) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Module: ${widget.moduleName}\nNiveau: ${widget.niveauName}\nSalle: ${widget.staticData3}\nDate et heure: ${widget.staticData4}\nDynamic Data $_counter',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 20.0),
              Text(
                'Dynamic QR Data: Dynamic Data $_counter',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 20.0),
              QrImageView(
                data:
                    'Module: ${widget.staticData1}\nNiveau: ${widget.staticData2}\nSalle: ${widget.staticData3}\nDate et heure: ${widget.staticData4}\nDynamic Data $_counter',
                version: QrVersions.auto,
                size: 200.0,
              ),
            ],
          ),
        );
      } else {
        // Afficher un message si le code QR est expiré
        return Center(
          child: Text(
            'Le code QR généré a expiré.',
            style: TextStyle(fontSize: 18.0),
          ),
        );
      }
    } else {
      // Afficher un message ou un widget alternatif si les données statiques ne sont pas disponibles
      return Center(
        child: Text(
          'Veuillez remplir tous les champs du formulaire de données statiques pour générer le code QR.',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }
  }
}