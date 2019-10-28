import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:todo_list/helpers/dataBase.helper.dart';
import '../models/task.dart';

class TodoListRepository{

  static final TodoListRepository _instance = TodoListRepository.internal();
  factory TodoListRepository() => _instance;
  TodoListRepository.internal();
  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await TaskHelper().initDb();
      return _db;
    }
  }

  Future<int> getCount() async {
    Database database = await db;
    return Sqflite.firstIntValue(
        await database.rawQuery("SELECT COUNT(*) FROM task"));
  }

  Future close() async {
    Database database = await db;
    database.close();
  }

  Future<Task> save(Task task) async {
    Database database = await db;
    task.id = await database.insert('task', task.toMap());
    return task;
  }

  Future<Task> getById(int id) async {
    Database database = await db;
    List<Map> maps = await database.query('task',
        columns: ['id', 'title', 'description', 'isDone'],
        where: 'id = ?',
        whereArgs: [id]);

    if (maps.length > 0) {
      return Task.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> delete(int id) async {
    Database database = await db;
    return await database.delete('task', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    Database database = await db;
    return await database.rawDelete("DELETE * from task");
  }

  Future<int> update(Task task) async {
    Database database = await db;
    return await database
        .update('task', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<List<Task>> getAll() async {
    Database database = await db;
    List listMap = await database.rawQuery("SELECT * FROM task");
    List<Task> stuffList = listMap.map((x) => Task.fromMap(x)).toList();
    return stuffList;
  }
}