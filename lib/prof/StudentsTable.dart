import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class StudentsTableScreen extends StatefulWidget {
  final List<Map<String, dynamic>> studentsData;
  final DateTime dateTime;
  final String niveau;
  final String module;

  StudentsTableScreen({
    Key? key,
    required this.studentsData,
    required this.dateTime,
    required this.niveau,
    required this.module,
  }) : super(key: key);

  @override
  _StudentsTableScreenState createState() => _StudentsTableScreenState();
}

class _StudentsTableScreenState extends State<StudentsTableScreen> {
  Uint8List? _dateTimeImage;
  Uint8List? _moduleNiveauImage;
  Uint8List? _yourLeftImage;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final dateTimeImageData = await rootBundle.load('assets/ensalogo.png');
      _dateTimeImage = Uint8List.view(dateTimeImageData.buffer);

      final moduleNiveauImageData = await rootBundle.load('assets/univ.png');
      _moduleNiveauImage = Uint8List.view(moduleNiveauImageData.buffer);

      final yourLeftImageData = await rootBundle.load('assets/logo.jpg');
      _yourLeftImage = Uint8List.view(yourLeftImageData.buffer);
    } catch (e) {
      print('Failed to load images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(widget.dateTime);
    String formattedTime = DateFormat('hh:mm a').format(widget.dateTime);

    return Scaffold(
      appBar: AppBar(
        title: Text('Liste de présence'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              _generatePdf(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(70.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder<void>(
                future: _loadImages(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_moduleNiveauImage != null)
                          Column(
                            children: [
                              Image.memory(
                                _moduleNiveauImage!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: 8),
                              Text('Niveau: ${widget.niveau}', style: TextStyle(fontSize: 16)),
                              Text('Date: $formattedDate', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        if (_dateTimeImage != null)
                          Column(
                            children: [
                              Image.memory(
                                _dateTimeImage!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: 8),
                              Text('Module: ${widget.module}', style: TextStyle(fontSize: 16)),
                              Text('Heure: $formattedTime', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                      ],
                    );
                  }
                },
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'Liste de présence',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.blue),
                        headingTextStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        columns: [
                          DataColumn(
                            label: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Text('Nom',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Text('Prenom',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Text('Statut',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                        rows: widget.studentsData.map((student) {
                          return DataRow(
                            cells: [
                              DataCell(Text(student['Lname'])),
                              DataCell(Text(student['Fname'])),
                              DataCell(
                                Text(
                                  student['status'],
                                  style: TextStyle(
                                    color: student['status'] == 'absent(e)'
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  pw.Widget buildPageContent(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Première ligne avec les images et les informations
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Image à gauche avec niveau et date
            if (_moduleNiveauImage != null)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Image(
                    pw.MemoryImage(_moduleNiveauImage!),
                    width: 50, // Ajuster la largeur selon vos besoins
                    height: 50, // Ajuster la hauteur selon vos besoins
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text('Niveau: ${widget.niveau}',
                      style: pw.TextStyle(fontSize: 16)),
                  pw.Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(widget.dateTime)}',
                    style: pw.TextStyle(fontSize: 16),
                  ),
                  pw.Text(
                    'Liste de présence',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            // Image à droite avec module et heure
            if (_dateTimeImage != null)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Image(
                    pw.MemoryImage(_dateTimeImage!),
                    width: 50, // Ajuster la largeur selon vos besoins
                    height: 50, // Ajuster la hauteur selon vos besoins
                  ),
                  pw.SizedBox(height: 17),
                  pw.Text('Module: ${widget.module}',
                      style: pw.TextStyle(fontSize: 16)),
                  pw.Text(
                      'Heure: ${DateFormat('hh:mm a').format(widget.dateTime)}',
                      style: pw.TextStyle(fontSize: 16)),
                ],
              ),
          ],
        ),
        pw.SizedBox(height: 16),
        // Tableau des étudiants
        pw.Table.fromTextArray(
          context: context,
          headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          cellAlignment: pw.Alignment.centerLeft,
          headerDecoration: pw.BoxDecoration(color: PdfColors.blue),
          headers: ['Nom', 'Prenom', 'Statut'],
          data: widget.studentsData.map((student) {
            return [
              student['Lname'],
              student['Fname'],
              pw.Text(
                student['status']!,
                style: pw.TextStyle(
                  color: student['status'] == 'absent(e)'
                      ? PdfColors.red
                      : PdfColors.green,
                ),
              ),
            ];
          }).toList(),
        ),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.center,
      child: _yourLeftImage != null
          ? pw.Image(
        pw.MemoryImage(_yourLeftImage!),
        width: 100,
        height: 100,
      )
          : pw.Container(),
    );
  }

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              buildPageContent(context),
              pw.SizedBox(height: 16),
              buildFooter(context),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
