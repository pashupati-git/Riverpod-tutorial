import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  await Future.delayed(Duration(seconds: 2)); //simulating api call
  return {
    'name': 'Pashupati Chaudhary',
    'email': 'pashupatic@gmail.com',
    'age': 30,
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
class TodoNotifier extends StateNotifier<TodoState>{
  TodoNotifier(): super(TodoState(todos:[]));

  //Add a new todo
  void addTodo(String title){
    final newTodo=Todo(id: DateTime.now().toString(), title: title);

    //stateNotifier requires creating a new state object(imutable pattern)
    state=state.copyWith(
      todos:[...state.todos,newTodo],
    );
  }

  //Toggle todo completion
  void toggleTodo(String id){
    state=state.copyWith(
      todos:state.todos.map((todo){
        if(todo.id==id){
          return todo.copyWith(completed:!todo.completed);
        }
        return todo;
      }).toList(),
    );
  }

  //Remove a todo
  void removeTodo(String id){
    state=state.copyWith(
      todos:state.todos.where((todo)=>todo.id !=id).toList(),
    );
  }

  //Simulate async operation
  Future<void> loadTodos() async{
    state=state.copyWith(isLoading:true);
    await Future.delayed(Duration(seconds:1));

    state=state.copyWith(
      isLoading:false,
      todos: [
        Todo(id:'1',title:'Learn Riverpod'),
        Todo(id:'2',title:'Build an app'),
      ],
    );
  }
}
//stateNotifierProvider exposes the StateNotifier
final todoProvider=StateNotifierProvider<TodoNotifier,TodoState>((ref){
  return TodoNotifier();
});




//------------------------------main page-------------------------------------
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
