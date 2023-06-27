import 'package:drift/drift.dart' as dr;
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:provider/provider.dart';

import '../database/my_database.dart';

class NewTagInput extends StatefulWidget {
  const NewTagInput({super.key});

  @override
  State<NewTagInput> createState() => _NewTagInputState();
}

class _NewTagInputState extends State<NewTagInput> {
  static const Color defaultColor = Colors.red;

  Color pickedTagColor = defaultColor;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          _buildTextField(context),
          _buildColorPickerButton(context),
        ],
      ),
    );
  }

  Widget _buildColorPickerButton(BuildContext context) {
    return Flexible(
      flex: 1,
      child: GestureDetector(
        child: Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: pickedTagColor,
          ),
        ),
        onTap: () => _showColorPickerDialog(context),
      ),
    );
  }

  Flexible _buildTextField(BuildContext context) {
    return Flexible(
      child: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: 'Tag Name'),
        onSubmitted: (value) {
          final tagDao = Provider.of<TagDao>(context, listen: false);
          final tag = TagsTblCompanion(
            name: dr.Value(value),
            color: dr.Value(pickedTagColor.value),
          );

          tagDao.insertTag(tag);
          resetValuesAfterSubmit();
        },
      ),
    );
  }

  void resetValuesAfterSubmit() {
    setState(() {
      pickedTagColor = defaultColor;
      _controller.clear();
    });
  }

  Future _showColorPickerDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: MaterialColorPicker(
          allowShades: false,
          selectedColor: defaultColor,
          onMainColorChange: (colorSwatch) {
            setState(() {
              pickedTagColor = colorSwatch as Color;
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
