import 'dart:developer';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'my_database.g.dart';

class TaskWithTag {
  final TaskEntity task;
  final TagEntity tag;

  TaskWithTag({
    required this.task,
    required this.tag,
  });
}

@DriftDatabase(
  tables: [TasksTbl, TagsTbl],
  daos: [TaskDao, TagDao],
)
class MyDatabase extends _$MyDatabase {
  // we tell the database where to store the data with this constructor
  MyDatabase() : super(_openConnection());

  // you should bump this number whenever you change or add a table definition.
  // Migrations are covered later in the documentation.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from == 1) {
            await migrator.addColumn(tasksTbl, tasksTbl.tagId);
            await migrator.createTable(tagsTbl);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
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

@DriftAccessor(tables: [TagsTbl])
class TagDao extends DatabaseAccessor<MyDatabase> with _$TagDaoMixin {
  final MyDatabase db;

  TagDao(this.db) : super(db);

  Stream<List<TagEntity>> watchAllTags() => select(tagsTbl).watch();
  Future<List<TagEntity>> getAllTags() {
    try {
      return select(tagsTbl).get();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future insertTag(Insertable<TagEntity> entity) {
    try {
      return into(tagsTbl).insert(entity);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

@DriftAccessor(tables: [TasksTbl, TagsTbl])
class TaskDao extends DatabaseAccessor<MyDatabase> with _$TaskDaoMixin {
  final MyDatabase db;

  TaskDao(this.db) : super(db);

  Future<List<TaskEntity>> getAllTasks() => select(tasksTbl).get();

  Stream<List<TaskWithTag>> watchAllTasks() {
    final query = (select(tasksTbl)
          ..orderBy(
            [
              (tbl) => OrderingTerm(
                    expression: tbl.dueDate,
                    mode: OrderingMode.desc,
                  ),
              (tbl) => OrderingTerm(
                    expression: tbl.title,
                    mode: OrderingMode.asc,
                  ),
            ],
          ))
        .join([leftOuterJoin(tagsTbl, tagsTbl.id.equalsExp(tasksTbl.tagId))]);

    return query.map((row) {
      return TaskWithTag(
        task: row.readTable(tasksTbl),
        tag: row.readTable(tagsTbl),
      );
    }).watch();
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
          ..where((tbl) => tbl.isCompleted.equals(false)))
        .watch();
  }

  Future insertTask(Insertable<TaskEntity> entity) =>
      into(tasksTbl).insert(entity);
  Future updateTask(Insertable<TaskEntity> entity) =>
      update(tasksTbl).replace(entity);
  Future deleteTask(Insertable<TaskEntity> entity) =>
      delete(tasksTbl).delete(entity);
}

// abstract class TasksView extends View {
//   TasksTbl get taskTbl;
//   TagsTbl get tagTbl;

//   Expression<String> get data =>
//       tagTbl.name + const Constant('(') + taskTbl.title + const Constant(')');

//   @override
//   Query as() => select([
//         taskTbl.title,
//         tagTbl.name,
//       ])
//           .from(taskTbl)
//           .join([innerJoin(taskTbl, taskTbl.tagId.equalsExp(tagTbl.id))]);
// }
