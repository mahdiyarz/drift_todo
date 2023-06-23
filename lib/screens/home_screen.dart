import 'package:drift/drift.dart' as dr;
import 'package:drift_todo/database/my_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [_buildCompletedSwitch()],
      ),
      body: Column(children: [
        Expanded(child: _buildTaskList(context)),
        const NewTaskInput(),
      ]),
    );
  }

  _buildTaskList(BuildContext context) {
    final taskDao = Provider.of<TaskDao>(context, listen: false);

    return StreamBuilder(
      stream: !showCompleted
          ? taskDao.watchAllTasks()
          : taskDao.watchCompletedTasks(),
      builder: (context, AsyncSnapshot<List<TaskEntity>> snapshot) {
        final tasks = snapshot.data ?? List.empty();

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final itemTask = tasks[index];

            return _buildListItem(itemTask, taskDao);
          },
        );
      },
    );
  }

  _buildListItem(TaskEntity itemTask, TaskDao taskDao) {
    return Slidable(
      startActionPane: ActionPane(motion: const ScrollMotion(), children: [
        SlidableAction(
          onPressed: (context) => taskDao.deleteTask(itemTask),
          backgroundColor: const Color(0xFFFE4A49),
          foregroundColor: Colors.white,
          icon: Icons.delete,
          label: 'Delete',
        ),
      ]),
      child: CheckboxListTile(
        title: Text(itemTask.title),
        subtitle: Text(itemTask.dueDate?.toString() ?? 'No date'),
        value: itemTask.isCompleted,
        onChanged: (value) => taskDao.updateTask(
          itemTask.copyWith(isCompleted: value),
        ),
      ),
    );
  }

  Row _buildCompletedSwitch() {
    return Row(
      children: [
        const Text('Show Compeleted'),
        Switch(
          value: showCompleted,
          activeColor: Colors.white,
          onChanged: (value) {
            setState(() {
              showCompleted = value;
            });
          },
        )
      ],
    );
  }
}

class NewTaskInput extends StatefulWidget {
  const NewTaskInput({super.key});

  @override
  State<NewTaskInput> createState() => _NewTaskInputState();
}

class _NewTaskInputState extends State<NewTaskInput> {
  DateTime? newTaskDate;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildTextField(context),
          _buildDateButton(context),
        ],
      ),
    );
  }

  Expanded _buildTextField(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: 'Task Title'),
        onSubmitted: (value) {
          final taskDao = Provider.of<TaskDao>(context, listen: false);
          final task = TasksTblCompanion(
            title: dr.Value(value),
            dueDate: dr.Value(newTaskDate),
          );

          taskDao.insertTask(task);
          resetValuesAfterSubmit();
        },
      ),
    );
  }

  IconButton _buildDateButton(BuildContext context) {
    return IconButton(
      onPressed: () async {
        newTaskDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2010),
          lastDate: DateTime(2050),
        );
      },
      icon: const Icon(Icons.calendar_today),
    );
  }

  void resetValuesAfterSubmit() {
    setState(() {
      newTaskDate = null;
      _controller.clear();
    });
  }
}
