import 'package:todo_list_provider/app/repositories/tasks/task_repository.dart';

import './tasks_service.dart';

class TasksServiceImpl implements TasksService {
  final TaskRepository _tasksRepository;
  TasksServiceImpl({required TaskRepository taskRepository})
      : _tasksRepository = taskRepository;

  @override
  Future<void> save(DateTime date, String description) =>
      _tasksRepository.save(date, description);
}
