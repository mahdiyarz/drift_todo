import 'package:drift/drift.dart';

@DataClassName('TaskEntity') //? this line change the default data class name
class TasksTbl extends Table {
  //* autoIncrement automatically sets this to be the primary key
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tagId => integer().nullable().references(TagsTbl, #id)();
  TextColumn get title => text().withLength(min: 1, max: 50)();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}

@DataClassName('TagEntity')
class TagsTbl extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get color => integer()();
}
