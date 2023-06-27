import 'package:drift/drift.dart' as dr;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/my_database.dart';

class NewTaskInput extends StatefulWidget {
  const NewTaskInput({super.key});

  @override
  State<NewTaskInput> createState() => _NewTaskInputState();
}

class _NewTaskInputState extends State<NewTaskInput> {
  DateTime? newTaskDate;
  TagEntity? selectedTag;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildTextField(context),
          _buildTagSelector(context),
          _buildDateButton(context),
        ],
      ),
    );
  }

  StreamBuilder<List<TagEntity>> _buildTagSelector(BuildContext context) {
    return StreamBuilder<List<TagEntity>>(
      stream: Provider.of<TagDao>(context, listen: false).watchAllTags(),
      builder: (context, snapshot) {
        final tags = snapshot.data ?? List.empty();

        DropdownMenuItem<TagEntity> dropdownFormTag(TagEntity tag) {
          return DropdownMenuItem(
            value: tag,
            child: Row(
              children: [
                Text(tag.name),
                const SizedBox(
                  width: 5,
                ),
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(tag.color),
                  ),
                ),
              ],
            ),
          );
        }

        final dropdownMenuItems =
            tags.map((tag) => dropdownFormTag(tag)).toList()
              ..insert(
                0,
                const DropdownMenuItem(
                  value: null,
                  child: Text('No Tag'),
                ),
              );

        return Expanded(
          child: DropdownButton(
            items: dropdownMenuItems,
            onChanged: (TagEntity? value) {
              setState(() {
                selectedTag = value;
              });
            },
            isExpanded: true,
            value: selectedTag,
          ),
        );
      },
    );
  }

  Expanded _buildTextField(BuildContext context) {
    return Expanded(
      flex: 1,
      child: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: 'Task Title'),
        onSubmitted: (value) {
          final taskDao = Provider.of<TaskDao>(context, listen: false);
          final task = TasksTblCompanion(
            title: dr.Value(value),
            dueDate: dr.Value(newTaskDate),
            tagId: dr.Value(selectedTag?.id),
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
      selectedTag = null;
      _controller.clear();
    });
  }
}
