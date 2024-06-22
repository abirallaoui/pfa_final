import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pfa/nodejs/utils.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';

class QRScanner extends StatefulWidget {
  final Map<String, dynamic>? user;

  const QRScanner({Key? key, this.user}) : super(key: key);

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  bool isScanCompleted = false;
  bool isScannedSuccessfully = false;
  MobileScannerController cameraController = MobileScannerController();
  Timer? _resetTimer;

  Future<void> sendScannedData(String scannedCode, Map<String, dynamic> userInfo) async {
    final url = Uri.parse('${Utils.baseUrl}/studentQR/scanner');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'scannedCode': scannedCode,
      'userId': userInfo['id'],
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Données envoyées avec succès');
        setState(() {
          isScannedSuccessfully = true;
          _startResetTimer(); // Démarrer le minuteur de réinitialisation
        });
      } else {
        print('Erreur lors de l\'envoi des données: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur inattendue : $e');
    }
  }

  void _startResetTimer() {
    _resetTimer?.cancel(); // Annuler le minuteur précédent s'il existe
    _resetTimer = Timer(Duration(seconds: 300), _resetScanner); // Démarrer un nouveau minuteur
  }

  void _resetScanner() {
    setState(() {
      isScannedSuccessfully = false; // Réinitialiser l'état du scanner
    });
  }

  @override
  void dispose() {
    _resetTimer?.cancel(); // Annuler le minuteur lors de la suppression du widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        centerTitle: true,
        title: Text(
          "QR Scanner",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Place the QR code in designated area",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Placez le code QR dans la zone désignée - La magie du scan commence toute seule !",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  MobileScanner(
                    controller: cameraController,
                    allowDuplicates: true,
                    onDetect: (barcode, args) {
                      if (!isScannedSuccessfully) {
                        setState(() {
                          isScanCompleted = true;
                        });

                        String? rawValue = barcode.rawValue;
                        if (rawValue != null) {
                          String module = RegExp(r'Module: (\w+)').firstMatch(rawValue)?.group(1) ?? '';
                          String niveau = RegExp(r'Niveau: (\w+)').firstMatch(rawValue)?.group(1) ?? '';
                          String salle = RegExp(r'Salle: (\w+)').firstMatch(rawValue)?.group(1) ?? '';
                          String dateTimeRaw = RegExp(r'Selected Date & Time: (.+)').firstMatch(rawValue)?.group(1) ?? '';

                          if (dateTimeRaw != null) {
                            String dateTime = dateTimeRaw.split('.')[0]; // Remove milliseconds
                            print(dateTime);
                            print(widget.user);
                            if (widget.user != null) {
                              String scannedCode = '$module|$niveau|$salle|$dateTime';
                              print('salle:' + salle);
                              sendScannedData(scannedCode, widget.user!);
                              print(scannedCode);
                            } else {
                              print("Erreur : l'utilisateur est null.");
                            }
                          } else {
                            print("Erreur : dateTimeRaw est null.");
                          }
                        } else {
                          print("Contenu du code QR invalide : Aucune donnée n'a été détectée.");
                        }
                      }
                    },
                  ),
                  QRScannerOverlay(
                    overlayColor: Colors.black26,
                    borderColor: Colors.indigoAccent,
                    borderRadius: 20,
                    borderStrokeWidth: 10,
                    scanAreaWidth: 250,
                    scanAreaHeight: 250,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isScannedSuccessfully ? "Scan réussi ! Réinitialisation dans 5 minutes..." : "|Scannez correctement pour enregistrer votre présence.|",
                    style: TextStyle(
                      color: Colors.indigoAccent,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      cameraController.switchCamera();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text('tourner la camera'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}