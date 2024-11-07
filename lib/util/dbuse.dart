import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/list_etudiants.dart';
import '../models/scol_list.dart';  // Import the model for the class

class dbuse {
  final int version = 1;
  Database? db;

  static final dbuse _dbHelper = dbuse._internal();

  dbuse._internal();
  factory dbuse() {
    return _dbHelper;
  }

  Future<Database> openDb() async {
    if (db == null) {
      db = await openDatabase(
        join(await getDatabasesPath(), 'scol.db'),
        onCreate: (database, version) async {
          await database.execute(
              'CREATE TABLE classes(codClass INTEGER PRIMARY KEY, nomClass TEXT, nbreEtud INTEGER)');
          await database.execute(
              'CREATE TABLE etudiants(id INTEGER PRIMARY KEY, codClass INTEGER, nom TEXT, prenom TEXT, datNais TEXT, FOREIGN KEY(codClass) REFERENCES classes(codClass))');
        },
        version: version,
      );
    }
    return db!;
  }

  Future<List<ScolList>> getClasses() async {
    await openDb(); // Ensure DB is open
    final List<Map<String, dynamic>> maps = await db!.query('classes');
    return List.generate(maps.length, (i) {
      return ScolList(
        maps[i]['codClass'],
        maps[i]['nomClass'],
        maps[i]['nbreEtud'],
      );
    });
  }

  Future<int> insertClass(ScolList list) async {
    await openDb(); // Ensure DB is open
    int codClass = await db!.insert(
      'classes',
      list.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return codClass;
  }

  Future<int> insertEtudiants(ListEtudiants etud) async {
    await openDb(); // Ensure DB is open
    int id = await db!.insert(
      'etudiants',
      etud.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<void> deleteList(ScolList list) async {
    final db = await openDb();
    await db.delete(
      'classes',
      where: 'codClass = ?',
      whereArgs: [list.codClass],
    );
  }

  Future<List<ListEtudiants>> getEtudiants(int codClass) async {
    final db = await openDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'etudiants',
      where: 'codClass = ?',
      whereArgs: [codClass],
    );

    return List.generate(maps.length, (i) {
      return ListEtudiants(
        maps[i]['id'],
        maps[i]['codClass'],
        maps[i]['nom'],
        maps[i]['prenom'], // Ensure 'prenom' field exists in DB
        maps[i]['datNais'], // Ensure 'datNais' field exists in DB
      );
    });
  }


  // **New deleteStudent method**
  Future<int> deleteStudent(ListEtudiants student) async {
    await openDb(); // Ensure DB is open
    int result = await db!.delete(
      'etudiants',
      where: 'id = ?',
      whereArgs: [student.id],
    );
    return result; // Return result of the deletion
  }
}
