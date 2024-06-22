import 'package:flutter/material.dart';
import 'DynamicQRGenerator.dart';
import 'StaticDataForm.dart';

class CodeQRScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const CodeQRScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<CodeQRScreen> createState() => _CodeQRScreenState();
}

class _CodeQRScreenState extends State<CodeQRScreen> {
  late TextEditingController _controller1;
  late TextEditingController _controller2;
  late String _staticData1;
  late String _staticData2;
  late String _staticData3;
  late String _staticData4;
  late String _niveauName; // Ajout de la variable niveauName
  late String _moduleName; // Ajout de la variable moduleName
  bool _showQRGenerator = false;

  @override
  void initState() {
    super.initState();
    _controller1 = TextEditingController();
    _controller2 = TextEditingController();

    _staticData1 = '';
    _staticData2 = '';
    _staticData3 = '';
    _staticData4 = '';
    _niveauName = ''; // Initialisation de niveauName
    _moduleName = ''; // Initialisation de moduleName
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  void _handleStaticDataChange(
      String data1, String data2, String data3, String data4, String niveauName, String moduleName) {
    setState(() {
      _staticData1 = data1;
      _staticData2 = data2;
      _staticData3 = data3;
      _staticData4 = data4;
      _niveauName = niveauName; // Mettre à jour la valeur de niveauName
      _moduleName = moduleName; // Mettre à jour la valeur de moduleName
      if (_staticData1.isNotEmpty && _staticData2.isNotEmpty && _staticData3.isNotEmpty && _staticData4.isNotEmpty) {
        _showQRGenerator = true;
      } else {
        _showQRGenerator = false;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 5,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Static Data'),
              Tab(text: 'Dynamic QR'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StaticDataForm(
              onStaticDataChanged: _handleStaticDataChange,
              user: widget.user, 
            ),
            DynamicQRGenerator(
              staticData1: _staticData1,
              staticData2: _staticData2,
              staticData3: _staticData3,
              staticData4: _staticData4,
              niveauName: _niveauName, // Passer la valeur de niveauName
              moduleName: _moduleName, // Passer la valeur de moduleName
            ),
            if (!_showQRGenerator)
              const Center(
                child: Text(
                  'Veuillez remplir tous les champs pour générer le code QR.',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
