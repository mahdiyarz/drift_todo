import 'package:drift_todo/database/my_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../widgets/new_tag.dart';
import '../widgets/new_task.dart';

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
        // actions: [_buildCompletedSwitch()],
      ),
      body: Column(children: [
        Expanded(child: _buildTaskList(context)),
        const NewTaskInput(),
        const NewTagInput(),
      ]),
    );
  }

  StreamBuilder<List<TaskWithTag>> _buildTaskList(BuildContext context) {
    final taskDao = Provider.of<TaskDao>(context, listen: false);

    return StreamBuilder(
      stream: taskDao.watchAllTasks(),
      builder: (context, AsyncSnapshot<List<TaskWithTag>> snapshot) {
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

  Column _buildTag(TagEntity tag) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tag != null) ...[
          Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Color(tag.color)),
          ),
          Text(tag.name),
        ]
      ],
    );
  }

  _buildListItem(TaskWithTag itemTask, TaskDao taskDao) {
    return Slidable(
      startActionPane: ActionPane(motion: const ScrollMotion(), children: [
        SlidableAction(
          onPressed: (context) => taskDao.deleteTask(itemTask.task),
          backgroundColor: const Color(0xFFFE4A49),
          foregroundColor: Colors.white,
          icon: Icons.delete,
          label: 'Delete',
        ),
      ]),
      child: CheckboxListTile(
        title: Text(itemTask.task.title),
        subtitle: Text(itemTask.task.dueDate?.toString() ?? 'No date'),
        secondary: _buildTag(itemTask.tag),
        value: itemTask.task.isCompleted,
        onChanged: (value) => taskDao.updateTask(
          itemTask.task.copyWith(isCompleted: value),
        ),
      ),
    );
  }

  // Row _buildCompletedSwitch() {
  //   return Row(
  //     children: [
  //       const Text('Show Compeleted'),
  //       Switch(
  //         value: showCompleted,
  //         activeColor: Colors.white,
  //         onChanged: (value) {
  //           setState(() {
  //             showCompleted = value;
  //           });
  //         },
  //       )
  //     ],
  //   );
  // }
}
