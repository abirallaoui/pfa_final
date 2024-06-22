import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pfa/prof/rapportPdf.dart';

import '../admin/DashboardAdmin.dart';
import '../nodejs/rest_api.dart';
import 'RapportSemestre.dart';
import 'StudentsTable.dart';


class RapportsScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  RapportsScreen({Key? key, this.user}) : super(key: key);



  @override
  _RapportsScreenState createState() => _RapportsScreenState();
}

class _RapportsScreenState extends State<RapportsScreen> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {

    super.dispose();
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
              Tab(text: 'Rapport Pdf'),
              Tab(text: 'Rapport de semestre'),
            ],
          ),
        ),
        body: TabBarView(

          children: [
            RapportPdfScreen(user:widget.user),
            RapportSemestre(user:widget.user),
          ],
        ),

      ),
    );
  }
}