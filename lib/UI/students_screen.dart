import 'package:flutter/material.dart';
import '../models/list_etudiants.dart';
import '../models/scol_list.dart';
import '../util/dbuse.dart';
import '../UI/list_student_dialog.dart'; // Import the dialog

class StudentsScreen extends StatefulWidget {
  final ScolList scolList;
  StudentsScreen(this.scolList);

  @override
  _StudentsScreenState createState() => _StudentsScreenState(this.scolList);
}

class _StudentsScreenState extends State<StudentsScreen> {
  final ScolList scolList;
  late dbuse helper;
  List<ListEtudiants> students = [];

  _StudentsScreenState(this.scolList);

  @override
  void initState() {
    super.initState();
    helper = dbuse(); // Initialize helper in initState
    showData(this.scolList.codClass); // Fetch the students for the class
  }

  @override
  Widget build(BuildContext context) {
    // Create an instance of ListStudentDialog
    ListStudentDialog dialog = ListStudentDialog();

    return Scaffold(
      appBar: AppBar(
        title: Text(scolList.nomClass),
      ),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(students[index].nom),
            background: Container(
              color: Colors.red,
              padding: EdgeInsets.only(left: 16),
              alignment: Alignment.centerLeft,
              child: Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              // Delete the student when dismissed
              String strName = students[index].nom;
              helper.deleteStudent(students[index]).then((_) {
                setState(() {
                  students.removeAt(index); // Remove the student from the list
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$strName deleted")),
                );
              });
            },
            child: ListTile(
              title: Text(students[index].nom),
              subtitle: Text(
                'Prenom: ${students[index].prenom} - Date Nais: ${students[index].datNais}',
              ),
              onTap: () {},
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  // Show the dialog for editing the selected student
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // Pass the selected student for editing
                      return dialog.buildAlert(
                        context,
                        students[index],
                        false,
                      );
                    },
                  ).then((value) {
                    // Refresh the list after editing a student
                    showData(scolList.codClass);
                  });
                },
              ),
            ),
          );
        },
      ),
      // Add a FloatingActionButton to add new students
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show the dialog for adding a new student
          showDialog(
            context: context,
            builder: (BuildContext context) => dialog.buildAlert(
              context,
              ListEtudiants(0, scolList.codClass, '', '', ''), // Create new empty student
              true, // Indicate that it's a new student
            ),
          ).then((value) {
            // Refresh the list after adding a student
            showData(scolList.codClass);
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }

  // Method to fetch data and update the students list
  Future<void> showData(int idList) async {
    await helper.openDb();
    students = await helper.getEtudiants(idList);
    setState(() {
      students = students;
    });
  }
}
