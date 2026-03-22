import 'package:flutter/material.dart';
import '../../config/theme_constants.dart';
import '../../data/icon_library.dart';
import '../../models/task.dart';

class TaskEditorModal extends StatefulWidget {
  final Task task;
  final ValueChanged<Task> onSave;

  const TaskEditorModal({
    super.key,
    required this.task,
    required this.onSave,
  });

  @override
  State<TaskEditorModal> createState() => _TaskEditorModalState();
}

class _TaskEditorModalState extends State<TaskEditorModal> {
  late String _type;
  late TextEditingController _contentController;
  late int _duration;
  late String? _icon;
  late int _width;
  late int _height;

  @override
  void initState() {
    super.initState();
    _type = widget.task.type;
    _contentController = TextEditingController(text: widget.task.content);
    _duration = widget.task.duration;
    _icon = widget.task.icon;
    _width = widget.task.width;
    _height = widget.task.height;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Task',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Task type
                const Text('Task Type', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'text', label: Text('Text')),
                    ButtonSegment(value: 'icon', label: Text('Icon')),
                    ButtonSegment(value: 'image', label: Text('Image')),
                  ],
                  selected: {_type},
                  onSelectionChanged: (v) => setState(() => _type = v.first),
                ),
                const SizedBox(height: 16),

                // Content
                const Text('Task Name', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(hintText: 'e.g. Maths'),
                ),
                const SizedBox(height: 16),

                // Duration
                const Text('Duration (minutes)', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _duration.toDouble(),
                        min: 5,
                        max: 180,
                        divisions: 35,
                        label: '$_duration min',
                        onChanged: (v) =>
                            setState(() => _duration = v.round()),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '$_duration min',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Icon picker
                const Text('Icon', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _iconButton(null, 'None'),
                    ...iconLibrary.map(
                      (entry) => _iconButton(entry.id, entry.name),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Size controls
                const Text('Tile Size', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Width: '),
                    Expanded(
                      child: Slider(
                        value: _width.toDouble(),
                        min: 120,
                        max: 400,
                        divisions: 28,
                        label: '${_width}px',
                        onChanged: (v) =>
                            setState(() => _width = v.round()),
                      ),
                    ),
                    Text('$_width'),
                  ],
                ),
                Row(
                  children: [
                    const Text('Height: '),
                    Expanded(
                      child: Slider(
                        value: _height.toDouble(),
                        min: 100,
                        max: 300,
                        divisions: 20,
                        label: '${_height}px',
                        onChanged: (v) =>
                            setState(() => _height = v.round()),
                      ),
                    ),
                    Text('$_height'),
                  ],
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        widget.onSave(widget.task.copyWith(
                          type: _type,
                          content: _contentController.text,
                          duration: _duration,
                          icon: _icon,
                          width: _width,
                          height: _height,
                        ));
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton(String? iconId, String name) {
    final isSelected = _icon == iconId;
    final iconData = iconId != null ? getIconData(iconId) : null;

    return Tooltip(
      message: name,
      child: InkWell(
        onTap: () => setState(() => _icon = iconId),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  isSelected ? AppColors.brandPrimary : AppColors.brandBorder,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? AppColors.brandPrimaryBg : Colors.white,
          ),
          child: Center(
            child: iconData != null
                ? Icon(iconData,
                    size: 24,
                    color: isSelected
                        ? AppColors.brandPrimary
                        : AppColors.brandTextMuted)
                : const Text('--',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.brandTextMuted)),
          ),
        ),
      ),
    );
  }
}
