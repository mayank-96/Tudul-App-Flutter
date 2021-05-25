import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tudul/models/task.dart';

class DatabaseHelper {
  static const _databaseName = 'TodoDatabase.db';
  static const _databaseVersion = 1;

  //singleton class
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory dataDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(dataDirectory.path, _databaseName);
    print(dbPath);
    return await openDatabase(dbPath,
        version: _databaseVersion, onCreate: _onCreateDB);
  }

  Future _onCreateDB(Database db, int version) async {
    //create tables
    await db.execute('''
      CREATE TABLE ${Task.tblTask}(
        ${Task.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Task.colName} TEXT NOT NULL,
        ${Task.colDesc} TEXT NOT NULL
      )
      ''');
  }

  //contact - insert
  Future<int> insertContact(Task task) async {
    Database? db = await database;
    return await db!.insert(Task.tblTask, task.toMap());
  }

//contact - update
  Future<int> updateContact(Task task) async {
    Database? db = await database;
    return await db!.update(Task.tblTask, task.toMap(),
        where: '${Task.colId}=?', whereArgs: [task.id]);
  }

//contact - delete
  Future<int> deleteContact(int id) async {
    Database? db = await database;
    return await db!
        .delete(Task.tblTask, where: '${Task.colId}=?', whereArgs: [id]);
  }

//contact - retrieve all
  Future<List<Task>> fetchContacts() async {
    Database? db = await database;
    List<Map> task = await db!.query(Task.tblTask);
    return task.length == 0 ? [] : task.map((x) => Task.fromMap(x)).toList();
  }
}
