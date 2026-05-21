import 'package:flutter/material.dart';
import '../../style/theme.dart';
import '../../models/task_model.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskModel task;

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  //  untuk memformat tanggal
  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return 'No Deadline';
    try {
      final date = DateTime.parse(isoDate);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == 'completed';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task Details',
          style: TextStyle(color: AppTheme.accentGold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.accentGold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: TextStyle(
                color: isCompleted ? AppTheme.textGrey : Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 20),


            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_offer,
                        size: 16,
                        color: AppTheme.accentGold,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        task.category,
                        style: const TextStyle(
                          color: AppTheme.accentGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.successColor.withOpacity(0.15)
                        : AppTheme.dangerColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.pending,
                        size: 16,
                        color: isCompleted
                            ? AppTheme.successColor
                            : AppTheme.dangerColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isCompleted ? 'Completed' : 'Pending',
                        style: TextStyle(
                          color: isCompleted
                              ? AppTheme.successColor
                              : AppTheme.dangerColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),


            const Text(
              'Deadline',
              style: TextStyle(color: AppTheme.textGrey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Text(
                  _formatDate(task.dueDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const Divider(
              color: AppTheme.cardColor,
              height: 48,
              thickness: 1.5,
            ),


            const Text(
              'Notes / Description',
              style: TextStyle(color: AppTheme.textGrey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                task.description.isNotEmpty
                    ? task.description
                    : 'No notes provided for this task.',
                style: TextStyle(
                  color: task.description.isNotEmpty
                      ? Colors.white
                      : AppTheme.textGrey,
                  fontSize: 16,
                  height:
                      1.6, 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
