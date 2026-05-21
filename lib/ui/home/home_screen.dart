import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../main.dart';
import '../../style/theme.dart';
import '../../models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import '../task/add_task_screen.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final String username;
  const HomeScreen({Key? key, required this.userId, required this.username})
    : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _taskRepo = TaskRepository();
  List<TaskModel> _tasks = [];
  int _selectedIndex = 0;
  String _selectedCategoryFilter = 'All';
  final List<String> _categories = [
    'All',
    'Work',
    'Personal',
    'Study',
    'Finance',
    'Other',
  ];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _refreshTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshTasks() async {
    final tasks = await _taskRepo.getTasksByUser(widget.userId);
    setState(() => _tasks = tasks);
  }

  void _toggleStatus(TaskModel task) async {
    final newStatus = task.status == 'pending' ? 'completed' : 'pending';
    await _taskRepo.updateTaskStatus(task.id!, newStatus);
    _refreshTasks();
  }

  void _deleteTask(int id) async {
    await _taskRepo.deleteTask(id);
    _refreshTasks();
  }

  void _startSearch() {
    setState(() => _isSearching = true);
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  String _formatDateTime(String isoDate) {
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
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '${months[date.month - 1]} ${date.day}, ${date.year} $hour:$minute';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  String _getDaysLeft(String dueDateStr, bool isCompleted) {
    if (isCompleted) return 'Done';
    if (dueDateStr.isEmpty) return 'No deadline';
    try {
      DateTime due = DateTime.parse(dueDateStr);
      DateTime now = DateTime.now();
      DateTime dueDay = DateTime(due.year, due.month, due.day);
      DateTime today = DateTime(now.year, now.month, now.day);
      int diff = dueDay.difference(today).inDays;
      if (diff < 0) return 'Overdue';
      if (diff == 0) return 'Today';
      if (diff == 1) return '1 day left';
      return '$diff days left';
    } catch (e) {
      return '';
    }
  }

  List<TaskModel> _getFilteredAndSortedTasks() {
    List<TaskModel> filteredList = _tasks;

    // Filter unruk category
    if (_selectedCategoryFilter != 'All') {
      filteredList = filteredList
          .where((task) => task.category == _selectedCategoryFilter)
          .toList();
    }

    // Filter untuk search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredList = filteredList.where((task) {
        return task.title.toLowerCase().contains(query) ||
            task.description.toLowerCase().contains(query);
      }).toList();
    }

    filteredList.sort((a, b) {
      try {
        return DateTime.parse(a.dueDate).compareTo(DateTime.parse(b.dueDate));
      } catch (e) {
        return 0;
      }
    });
    return filteredList;
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 80,
            color: AppTheme.textGrey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: AppTheme.textGrey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Click "+" to create a new task.',
            style: TextStyle(color: AppTheme.textGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showTaskDetailDialog(TaskModel task) {
    final isCompleted = task.status == 'completed';
    final headerColor = isCompleted
        ? AppTheme.successColor
        : const Color(0xFFFF8A65);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    top: 8,
                    left: 8,
                    right: 8,
                    bottom: 24,
                  ),
                  decoration: BoxDecoration(
                    color: headerColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteTask(task.id!);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddTaskScreen(
                                        userId: widget.userId,
                                        taskToEdit: task,
                                      ),
                                    ),
                                  ).then((value) {
                                    if (value == true) _refreshTasks();
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        task.category.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        task.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _formatDateTime(task.dueDate),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildDialogBox(
                            'Status',
                            isCompleted ? Icons.check_circle : Icons.pending,
                            isCompleted ? 'Completed' : 'Pending',
                            isCompleted
                                ? AppTheme.successColor
                                : AppTheme.dangerColor,
                          ),
                          _buildDialogBox(
                            'Category',
                            Icons.local_offer,
                            task.category,
                            AppTheme.primaryAccent(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        task.description.isEmpty
                            ? 'No notes'
                            : task.description,
                        style: TextStyle(
                          color: AppTheme.textColor(context),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogBox(
    String title,
    IconData icon,
    String value,
    Color iconColor,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textGrey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.textGrey.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  color: AppTheme.textColor(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskTab() {
    final displayTasks = _getFilteredAndSortedTasks();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategoryFilter == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) =>
                      setState(() => _selectedCategoryFilter = cat),
                  selectedColor: AppTheme.primaryAccent(context),
                  backgroundColor: Theme.of(context).cardColor,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppTheme.bgColor
                        : AppTheme.textColor(context),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isSearching && _searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              '${displayTasks.length} result${displayTasks.length == 1 ? '' : 's'} for "$_searchQuery"',
              style: TextStyle(
                color: AppTheme.textGrey.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ),
        Expanded(
          child: displayTasks.isEmpty
              ? _buildEmptyState(
                  _searchQuery.isNotEmpty
                      ? 'No tasks match your search.'
                      : 'No tasks found.',
                )
              : _buildTaskList(displayTasks),
        ),
      ],
    );
  }

  List<TaskModel> _getTasksForDay(DateTime day) {
    return _tasks.where((task) {
      try {
        return isSameDay(DateTime.parse(task.dueDate), day);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  Widget _buildCalendarTab() {
    final tasksForSelectedDay = _getTasksForDay(_selectedDay!);

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) => setState(() => _calendarFormat = format),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: AppTheme.primaryAccent(context),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: AppTheme.textGrey.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: AppTheme.dangerColor,
              shape: BoxShape.circle,
            ),
            defaultTextStyle: TextStyle(color: AppTheme.textColor(context)),
            weekendTextStyle: const TextStyle(color: AppTheme.dangerColor),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              color: AppTheme.primaryAccent(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: AppTheme.primaryAccent(context),
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: AppTheme.primaryAccent(context),
            ),
          ),
          eventLoader: _getTasksForDay,
        ),
        const Divider(color: AppTheme.textGrey, height: 20),
        Expanded(
          child: tasksForSelectedDay.isEmpty
              ? _buildEmptyState('Plan your day clearly!')
              : _buildTaskList(tasksForSelectedDay),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    int totalTasks = _tasks.length;
    int completedTasks = _tasks.where((t) => t.status == 'completed').length;
    int pendingTasks = totalTasks - completedTasks;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryAccent(context),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).cardColor,
              child: Icon(
                Icons.person,
                size: 60,
                color: AppTheme.primaryAccent(context),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.username,
            style: TextStyle(
              color: AppTheme.textColor(context),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildStatCard(
                'Total',
                totalTasks.toString(),
                Icons.task_alt,
                Colors.blueAccent,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Done',
                completedTasks.toString(),
                Icons.check_circle,
                AppTheme.successColor,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Pending',
                pendingTasks.toString(),
                Icons.pending,
                AppTheme.dangerColor,
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Settings & Preferences',
              style: TextStyle(
                color: AppTheme.textGrey,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).cardColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.dark_mode,
                    color: AppTheme.primaryAccent(context),
                  ),
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(
                      color: AppTheme.textColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Switch(
                    value: themeNotifier.value == ThemeMode.dark,
                    onChanged: (val) {
                      themeNotifier.value = val
                          ? ThemeMode.dark
                          : ThemeMode.light;
                    },
                    activeColor: AppTheme.primaryAccent(context),
                  ),
                ),
                Divider(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  height: 1,
                ),
                ListTile(
                  leading: Icon(
                    Icons.notifications_active,
                    color: AppTheme.primaryAccent(context),
                  ),
                  title: Text(
                    'Task Reminders',
                    style: TextStyle(
                      color: AppTheme.textColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Switch(
                    value: true,
                    onChanged: (val) {},
                    activeColor: AppTheme.primaryAccent(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerColor.withOpacity(0.1),
                foregroundColor: AppTheme.dangerColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: AppTheme.dangerColor,
                    width: 1.5,
                  ),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text(
                'LOGOUT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                color: AppTheme.textColor(context),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textGrey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<TaskModel> list) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final task = list[index];
        final isCompleted = task.status == 'completed';
        final daysLeftStr = _getDaysLeft(task.dueDate, isCompleted);

        Color badgeColor = AppTheme.textGrey;
        if (!isCompleted) {
          if (daysLeftStr == 'Overdue')
            badgeColor = AppTheme.dangerColor;
          else if (daysLeftStr == 'Today')
            badgeColor = AppTheme.accentGold;
          else if (daysLeftStr.contains('left'))
            badgeColor = Colors.blueAccent;
        }

        return Card(
          color: Theme.of(context).cardColor,
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showTaskDetailDialog(task),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: IconButton(
                  icon: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isCompleted
                        ? AppTheme.successColor
                        : AppTheme.dangerColor,
                    size: 30,
                  ),
                  onPressed: () => _toggleStatus(task),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    color: isCompleted
                        ? AppTheme.textGrey
                        : AppTheme.textColor(context),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 14,
                            color: AppTheme.textGrey.withOpacity(0.7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDateTime(task.dueDate),
                            style: TextStyle(
                              color: AppTheme.textGrey.withOpacity(0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.category,
                              style: TextStyle(
                                color: AppTheme.primaryAccent(context),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.timer, size: 12, color: badgeColor),
                                const SizedBox(width: 4),
                                Text(
                                  daysLeftStr,
                                  style: TextStyle(
                                    color: badgeColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSearching
          ? AppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: AppTheme.primaryAccent(context),
                ),
                onPressed: _stopSearch,
              ),
              title: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: TextStyle(
                  color: AppTheme.textColor(context),
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  hintStyle: TextStyle(
                    color: AppTheme.textGrey.withOpacity(0.7),
                    fontSize: 18,
                  ),
                  border: InputBorder.none,
                ),
              ),
              actions: [
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: AppTheme.primaryAccent(context),
                    ),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  ),
              ],
            )
          : AppBar(
              title: const Text('MyTasks'),
              actions: [
                if (_selectedIndex == 0)
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: AppTheme.primaryAccent(context),
                    ),
                    onPressed: _startSearch,
                  ),
              ],
            ),

      body: [
        _buildTaskTab(),
        _buildCalendarTab(),
        _buildProfileTab(),
      ][_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: AppTheme.primaryAccent(context),
        unselectedItemColor: AppTheme.textGrey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (_isSearching) _stopSearch();
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Tasks'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: _selectedIndex != 2
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddTaskScreen(userId: widget.userId),
                  ),
                );
                if (result == true) _refreshTasks();
              },
              child: const Icon(Icons.add, size: 28),
            )
          : null,
    );
  }
}
