import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'my_database.g.dart';

@DriftDatabase(tables: [TasksTbl], daos: [TaskDao])
class MyDatabase extends _$MyDatabase {
  // we tell the database where to store the data with this constructor
  MyDatabase() : super(_openConnection());

  // you should bump this number whenever you change or add a table definition.
  // Migrations are covered later in the documentation.
  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file, logStatements: true);
  });
}

@DriftAccessor(tables: [TasksTbl])
class TaskDao extends DatabaseAccessor<MyDatabase> with _$TaskDaoMixin {
  final MyDatabase db;

  TaskDao(this.db) : super(db);

  Future<List<TaskEntity>> getAllTasks() => select(tasksTbl).get();
  Stream<List<TaskEntity>> watchAllTasks() {
    return (select(tasksTbl)
          ..orderBy([
            (tbl) =>
                OrderingTerm(expression: tbl.dueDate, mode: OrderingMode.desc),
            (tbl) =>
                OrderingTerm(expression: tbl.title, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  Stream<List<TaskEntity>> watchCompletedTasks() {
    return (select(tasksTbl)
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.dueDate,
                  mode: OrderingMode.desc,
                ),
            (tbl) => OrderingTerm(
                  expression: tbl.title,
                  mode: OrderingMode.asc,
                ),
          ])
          ..where((tbl) => tbl.isCompleted.equals(true)))
        .watch();
  }

  Future insertTask(Insertable<TaskEntity> entity) =>
      into(tasksTbl).insert(entity);
  Future updateTask(Insertable<TaskEntity> entity) =>
      update(tasksTbl).replace(entity);
  Future deleteTask(Insertable<TaskEntity> entity) =>
      delete(tasksTbl).delete(entity);
}
