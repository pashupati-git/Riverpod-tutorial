import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/gap.dart';

//----------------------------------------------------------------------------------
//1.provider-simple immutable value that doesn't change
//usecase:configuration values,constantts,or simple calculated value
final appThemeProvider = Provider<ThemeData>((ref) {
  return ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light);
});

//------------------------------------------------------------------------------
//2.state provider-simple mutable state (like useState in react)
//use case: Simple values that need to be changed.
final counterProvider = StateProvider<int>((ref) {
  return 0; //initial value
});

//-------------------------------------------------------------------------------
//3.future provider---------------------------------------------------------
//=
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

//6. change notifier provider------------------------------------------------
class CartNotifier extends ChangeNotifier {
  final List<String> _items = [];
  List<String> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;

  void addItem(String item) {
    _items.add(item);
    notifyListeners(); //Must manually call notifyListeners() to update UI
  }

  void removeItem(String item) {
    _items.remove(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

final cartProvider = ChangeNotifierProvider<CartNotifier>((ref) {
  return CartNotifier();
});

//7. family modifier------------------------------------------------------------
//create providers with parameters
final userByIdProvider = FutureProvider.family<String, int>((
  ref,
  userId,
) async {
  await Future.delayed(Duration(seconds: 1));
  return 'User data for ID: $userId';
});

//8. auto dispose modifier------------------------------------------------------
final searchQueryProvider = StateProvider.autoDispose<String>((ref) {
  return '';
});

final searchResultsProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) async {
  final query = ref.watch(searchQueryProvider);
  //Simulating search Api call
  await Future.delayed(Duration(milliseconds: 500));
  if (query.isEmpty) return [];
  return ['Result 1 for $query', 'Result 2 for $query', 'Result 3 for $query'];
});

//9. combining modifiers-Family + AutoDispose---------------------------------
final productByIdProvider = FutureProvider.autoDispose.family<String, int>((
  ref,
  productId,
) async {
  await Future.delayed(Duration(seconds: 1));
  return 'Product details for ID: $productId';
});

//10. computed providers - Derive state from others providers
//usecase: Calculate values based on other providers
final completedTodosProvider = Provider<List<Todo>>((ref) {
  final todoState = ref.watch(todoProvider);
  return todoState.todos.where((todo) => todo.completed).toList();
});

final todoStatsProvider = Provider<Map<String, int>>((ref) {
  final todoState = ref.watch(todoProvider);
  final completed = todoState.todos.where((t) => t.completed).length;
  final pending = todoState.todos.length - completed;

  return {
    'total': todoState.todos.length,
    'completed': completed,
    'pending': pending,
  };
});

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
            TodoListTab(),
            CartTab(),
          ],
        ),
      ),
    );
  }
}

//==========================Tab 1 (State Provider)  ================================================
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

//===========tab 2 : Async Data (FutureProvider and StreamProvider)==================
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
                'Timer:$data seconds',
                style: TextStyle(fontSize: 24),
              );
            },
            error: (err, qwerty) => Text('Error: $err'),
            loading: () => Text('Waiting for timer...'),
          ),
        ],
      ),
    );
  }
}

//===================================tab 3=====================//
class TodoListTab extends ConsumerStatefulWidget {
  const TodoListTab({super.key});

  @override
  ConsumerState<TodoListTab> createState() => _TodoListTabState();
}

class _TodoListTabState extends ConsumerState<TodoListTab> {
  final _controller = TextEditingController();

  @override
  void initState() {
    Future.microtask(() => ref.read(todoProvider.notifier).loadTodos());
  }

  @override
  Widget build(BuildContext context) {
    final todoState = ref.watch(todoProvider);
    final stats = ref.watch(todoStatsProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter Todo title',
                      ),
                    ),
                  ),
                  Gap.gapw10,
                  ElevatedButton(
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        ref
                            .read(todoProvider.notifier)
                            .addTodo(_controller.text);
                        _controller.clear();
                      }
                    },
                    child: Text('Add Todo'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Total:${stats['total']}'),
                      Text('Completed:${stats['completed']}'),
                      Text('Pending:${stats['pending']}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (todoState.isLoading)
          CircularProgressIndicator()
        else
          Expanded(
            child: ListView.builder(
              itemCount: todoState.todos.length,
              itemBuilder: (context, index) {
                final todo = todoState.todos[index];
                return ListTile(
                  leading: Checkbox(
                    value: todo.completed,
                    onChanged: (_) {
                      ref.read(todoProvider.notifier).toggleTodo(todo.id);
                    },
                  ),
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      decoration: todo.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      ref.read(todoProvider.notifier).removeTodo(todo.id);
                    },
                    icon: Icon(Icons.delete),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

//======================TAb 4:Cart(Change Notifier Provider)==================
class CartTab extends ConsumerWidget {
  const CartTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Items in cart:${cart.itemCount}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: cart.itemCount > 0
                    ? () => ref.read(cartProvider).clear()
                    : null,
                child: Text('Clear Cart'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return ListTile(
                title: Text(item),
                trailing: IconButton(
                  onPressed: () {
                    ref.read(cartProvider).removeItem(item);
                  },
                  icon: Icon(Icons.remove_circle),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              final item = 'Item ${cart.itemCount + 1}';
              ref.read(cartProvider).addItem(item);
            },
            child: Text('Add Item to Cart'),
          ),
        ),
      ],
    );
  }
}
