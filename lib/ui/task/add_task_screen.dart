import 'package:flutter/material.dart';
import '../../style/theme.dart';
import '../../models/task_model.dart';
import '../../data/repositories/task_repository.dart';

class AddTaskScreen extends StatefulWidget {
  final int userId;
  final TaskModel? taskToEdit;

  const AddTaskScreen({Key? key, required this.userId, this.taskToEdit})
    : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _taskRepo = TaskRepository();

  String _selectedCategory = 'Work';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _descController.text = widget.taskToEdit!.description;
      _selectedCategory = widget.taskToEdit!.category;
      if (widget.taskToEdit!.dueDate.isNotEmpty) {
        _selectedDate = DateTime.parse(widget.taskToEdit!.dueDate);
      }
    }
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.accentGold,
              onPrimary: Theme.of(context).scaffoldBackgroundColor,
              surface: Theme.of(context).cardColor,
              onSurface: AppTheme.textColor(context),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedDate != null
            ? TimeOfDay.fromDateTime(_selectedDate!)
            : TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppTheme.accentGold,
                onPrimary: Theme.of(context).scaffoldBackgroundColor,
                surface: Theme.of(context).cardColor,
                onSurface: AppTheme.textColor(context),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _pickCategory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final categories = ['Work', 'Personal', 'Study', 'Finance', 'Other'];
        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(
                Icons.label_outline,
                color: AppTheme.accentGold,
              ),
              title: Text(
                categories[index],
                style: TextStyle(
                  color: AppTheme.textColor(context),
                  fontSize: 16,
                ),
              ),
              onTap: () {
                setState(() => _selectedCategory = categories[index]);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _saveTask() async {
    if (_titleController.text.isNotEmpty && _selectedDate != null) {
      if (widget.taskToEdit != null) {
        final updatedTask = TaskModel(
          id: widget.taskToEdit!.id,
          userId: widget.userId,
          title: _titleController.text,
          description: _descController.text,
          category: _selectedCategory,
          createdDate: widget.taskToEdit!.createdDate,
          dueDate: _selectedDate!.toIso8601String(),
          status: widget.taskToEdit!.status,
        );
        await _taskRepo.updateTask(updatedTask);
      } else {
        final newTask = TaskModel(
          userId: widget.userId,
          title: _titleController.text,
          description: _descController.text,
          category: _selectedCategory,
          createdDate: DateTime.now().toIso8601String(),
          dueDate: _selectedDate!.toIso8601String(),
        );
        await _taskRepo.insertTask(newTask);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill Title and Select a Deadline!'),
        ),
      );
    }
  }

  Widget _buildSelectionButton(
    String label,
    IconData icon,
    String value,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textGrey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: AppTheme.textGrey, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String dateText = _selectedDate == null
        ? 'Select Date'
        : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} ${_selectedDate!.hour.toString().padLeft(2, '0')}:${_selectedDate!.minute.toString().padLeft(2, '0')}";

    final screenTitle = widget.taskToEdit != null ? 'Edit Task' : 'New Task';
    final buttonText = widget.taskToEdit != null
        ? 'UPDATE TASK'
        : 'CREATE TASK';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          screenTitle,
          style: const TextStyle(color: AppTheme.accentGold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.accentGold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _buildSelectionButton(
                    'Category',
                    Icons.local_offer,
                    _selectedCategory,
                    _pickCategory,
                  ),
                  const SizedBox(width: 16),
                  _buildSelectionButton(
                    'Deadline',
                    Icons.calendar_today,
                    dateText,
                    _pickDate,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _titleController,
                style: TextStyle(
                  color: AppTheme.textColor(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'Task Name',
                  hintStyle: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                  fillColor: Theme.of(context).cardColor,
                  filled: true,
                  prefixIcon: const Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.accentGold,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _descController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: TextStyle(color: AppTheme.textColor(context)),
                  decoration: InputDecoration(
                    hintText: 'Add notes / description...',
                    fillColor: Theme.of(context).cardColor,
                    filled: true,
                    contentPadding: const EdgeInsets.all(20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
