import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tp5flutter/util/dbuse.dart'; // Classe d'interaction avec la base de données
import 'models/list_etudiants.dart';
import 'models/scol_list.dart'; // Modèle pour les classes
import 'package:tp5flutter/ui/scol_list_dialog.dart'; // Importation du dialog
import 'package:tp5flutter/ui/students_screen.dart'; // Écran des étudiants

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Classes List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ShList(), // L'écran principal qui affiche la liste des classes
    );
  }
}

class ShList extends StatefulWidget {
  @override
  _ShListState createState() => _ShListState();
}

class _ShListState extends State<ShList> {
  List<ScolList> scolList = []; // Liste des classes
  final dbuse helper = dbuse(); // Instance de la classe d'accès à la base de données
  late ScolListDialog dialog; // Déclaration de l'instance du dialog

  @override
  void initState() {
    super.initState();
    dialog = ScolListDialog(); // Initialisation du dialog
    showData(); // Afficher les données au démarrage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classes List'), // Titre de la page
      ),
      body: scolList.isEmpty
          ? Center(child: CircularProgressIndicator()) // Loader si la liste est vide
          : ListView.builder(
        itemCount: scolList.length, // Nombre d'éléments dans la liste
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(scolList[index].nomClass),
            onDismissed: (direction) {
              String strName = scolList[index].nomClass;
              helper.deleteList(scolList[index]); // Suppression de la classe
              setState(() {
                scolList.removeAt(index); // Mise à jour de la liste
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "$strName deleted",
                    style: TextStyle(color: Colors.white), // Texte en vert
                  ),
                  backgroundColor: Colors.green, // Couleur de fond
                ),
              );
            },
            background: Container(color: Colors.red), // Fond rouge lors de la suppression
            child: ListTile(
              title: Text(scolList[index].nomClass), // Nom de la classe
              leading: CircleAvatar(
                child: Text(scolList[index].codClass.toString()), // Code de la classe
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit), // Icône de modification
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        dialog.buildDialog(context, scolList[index], false), // Édition
                  ).then((_) => showData()); // Actualiser les données après fermeture
                },
              ),
              onTap: () {
                // Naviguer vers l'écran des étudiants
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentsScreen(scolList[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) =>
                dialog.buildDialog(context, ScolList(0, '', 0), true), // Ajout d'une nouvelle classe
          ).then((_) => showData()); // Actualiser les données après fermeture
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }

  Future<void> showData() async {
    await helper.openDb();

    // Vérifier si la liste des classes est vide avant d'insérer des données
    scolList = await helper.getClasses();
    if (scolList.isEmpty) {
      ScolList list1 = ScolList(11, "DSI31", 30);
      int ClassId1 = await helper.insertClass(list1);
      ScolList list2 = ScolList(12, "DSI32", 26);
      int ClassId2 = await helper.insertClass(list2);
      ScolList list3 = ScolList(13, "DSI33", 28);
      int ClassId3 = await helper.insertClass(list3);

      String dateStart = '22-04-2021';
      DateFormat inputFormat = DateFormat('dd-MM-yyyy');
      DateTime input = inputFormat.parse(dateStart);
      String datee = DateFormat('dd-MM-yyyy').format(input);

      ListEtudiants etud = ListEtudiants(1, ClassId1, "Ali", "Ben Mohamed", datee);
      int etudId1 = await helper.insertEtudiants(etud);
      print('classe Id: ' + ClassId1.toString() + ', étudiant Id: ' + etudId1.toString());

      etud = ListEtudiants(2, ClassId2, "Salah", "Ben Salah", datee);
      await helper.insertEtudiants(etud);

      etud = ListEtudiants(3, ClassId2, "Slim", "Ben Slim", datee);
      await helper.insertEtudiants(etud);

      etud = ListEtudiants(4, ClassId3, "Foulen", "Ben Foulen", datee);
      await helper.insertEtudiants(etud);
    }

    // Récupérer les classes et rafraîchir l'UI
    scolList = await helper.getClasses();
    setState(() {});
  }
}
