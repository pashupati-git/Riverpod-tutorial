import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/gap.dart';

//1.provider--------------------------------------------------------------
final appThemeProvider = Provider<ThemeData>((ref) {
  return ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light);
});

//2.state provider---------------------------------------------------------
final counterProvider = StateProvider<int>((ref) {
  return 0; //initial value
});

//3.future provider----------------------------------------------------------
final userDataProvider = FutureProvider((ref) async {
  // FutureProvider automatically handles loading/error/data states
  // It executes the async function and caches the result
  await Future.delayed(Duration(seconds: 5)); //simulating api call
  return {
    'name': 'Pashupati Chaudharyyyyyyyy',
    'email': 'pashupatic@gmail.com',
    'age': 300,
  };
});

//4.Stream provider----------------------------------------------------------
final timerProvider = StreamProvider((ref) {
  return Stream.periodic(
    Duration(seconds: 1),
    (count) => count, //Emits 0,1,2,3.....every second
  );
});

//5.State notifier provider--------------------------------------------------
class TodoState {
  final List<Todo> todos;
  final bool isLoading;
  final String? error;

  TodoState({required this.todos, this.isLoading = false, this.error});

  TodoState copyWith({List<Todo>? todos, bool? isLoading, String? error}) {
    return TodoState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class Todo {
  final String id;
  final String title;
  final bool completed;
  Todo({required this.id, required this.title, this.completed = false});
  Todo copyWith({String? title, bool? completed}) {
    return Todo(
      id: id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }
}

//StateNotifier-Contains buisness logic for state manipulation
class TodoNotifier extends StateNotifier<TodoState> {
  TodoNotifier() : super(TodoState(todos: []));

  //Add a new todo
  void addTodo(String title) {
    final newTodo = Todo(id: DateTime.now().toString(), title: title);

    //stateNotifier requires creating a new state object(imutable pattern)
    state = state.copyWith(todos: [...state.todos, newTodo]);
  }

  //Toggle todo completion
  void toggleTodo(String id) {
    state = state.copyWith(
      todos: state.todos.map((todo) {
        if (todo.id == id) {
          return todo.copyWith(completed: !todo.completed);
        }
        return todo;
      }).toList(),
    );
  }

  //Remove a todo
  void removeTodo(String id) {
    state = state.copyWith(
      todos: state.todos.where((todo) => todo.id != id).toList(),
    );
  }

  //Simulate async operation
  Future<void> loadTodos() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(Duration(seconds: 1));

    state = state.copyWith(
      isLoading: false,
      todos: [
        Todo(id: '1', title: 'Learn Riverpod'),
        Todo(id: '2', title: 'Build an app'),
      ],
    );
  }
}

//stateNotifierProvider exposes the StateNotifier
final todoProvider = StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  return TodoNotifier();
});

//6. change notifier provider

//7. family modifier

//8. auto dispose modifier

//9. combining modifiers-Family + AutoDispose

//10. computed providers - Derive state from others providers

// ===========================================================================
//------------------------------main page-------------------------------------
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Riverpod 2.0 Examples'),
          centerTitle: true,
          bottom: TabBar(
            //isScrollable: true,
            tabs: [
              Tab(text: 'Simple State'),
              Tab(text: 'Async Data'),
              Tab(text: 'Todo List'),
              Tab(text: 'Cart'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SimpleStateTab(),
            AsyncDataTab(),
            // TodoListTab(),
            // CartTab(),
          ],
        ),
      ),
    );
  }
}

//==========================Tab 1 ================================================
class SimpleStateTab extends ConsumerWidget {
  const SimpleStateTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'StateProvider Examples',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text('Counter:$counter', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  ref.read(counterProvider.notifier).state++;
                },
                child: Text('Increment'),
              ),
              Gap.gapw10,
              ElevatedButton(
                onPressed: () {
                  ref.read(counterProvider.notifier).state--;
                },
                child: Text('Decrement'),
              ),
              Gap.gapw10,
              ElevatedButton(
                onPressed: () {
                  ref.read(counterProvider.notifier).state = 0;
                },
                child: Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AsyncDataTab extends ConsumerWidget {
  const AsyncDataTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Futureprovider provides AasyncValue<T> with loading/error/data states
    final userData = ref.watch(userDataProvider);
    final timer = ref.watch(timerProvider);
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FutureProvider Example',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          userData.when(
            data: (data) => Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name:${data['name']}'),
                    Text('Email:${data['email']}'),
                    Text('Age:${data['age']}'),
                  ],
                ),
              ),
            ),
            error: (err, stack) => Text('Error:${err}'),
            loading: () => CircularProgressIndicator(),
          ),
          SizedBox(height: 30),
          Text(
            'StreamProvider Example',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          timer.when(
            data: (data) {
              return Text(
                  'Timer:$data seconds', style: TextStyle(fontSize: 24));
            },
              error: (err,qwerty) => Text('Error: $err'),
              loading: () => Text('Waiting for timer...'),
              ),
        ],
      ),
    );
  }
}
