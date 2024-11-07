import 'package:flutter/material.dart';
import '../models/list_etudiants.dart';
import '../util/dbuse.dart';

class ListStudentDialog {
  final txtNom = TextEditingController();
  final txtPrenom = TextEditingController();
  final txtdatNais = TextEditingController();

  Widget buildAlert(BuildContext context, ListEtudiants student, bool isNew) {
    dbuse helper = dbuse();
    helper.openDb();

    if (!isNew) {
      txtNom.text = student.nom;
      txtPrenom.text = student.prenom;
      txtdatNais.text = student.datNais;
    }

    return AlertDialog(
      title: Text(isNew ? 'New student' : 'Edit student'),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Text field for student's name
            TextField(
              controller: txtNom,
              decoration: InputDecoration(hintText: 'Student Name'),
            ),
            // Text field for student's first name
            TextField(
              controller: txtPrenom,
              decoration: InputDecoration(hintText: 'First name'),
            ),
            // Text field for student's date of birth
            TextField(
              controller: txtdatNais,
              decoration: InputDecoration(hintText: 'Date naissance'),
            ),
            SizedBox(height: 20),
            // ElevatedButton to replace deprecated RaisedButton
            ElevatedButton(
              child: Text('Save Student'),
              onPressed: () {
                // Save or update student information
                student.nom = txtNom.text;
                student.prenom = txtPrenom.text;
                student.datNais = txtdatNais.text;
                helper.insertEtudiants(student);
                Navigator.pop(context); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
