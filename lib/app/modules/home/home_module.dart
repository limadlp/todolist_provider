import 'package:todo_list_provider/app/core/modules/todo_list_module.dart';

import 'home_page.dart';

class HomeModule extends TodoListModule {
  HomeModule()
      : super(
          //bindings: [],
          routers: {
            '/home': (context) => const HomePage(),
          },
        );
}
