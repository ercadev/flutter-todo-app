import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: TodoManager(),
    );
  }
}

class Finished extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("Finished Todos");
  }
}

class TodoManager extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TodoManagerState();
  }
}

class _TodoManagerState extends State<TodoManager> {
  final TextEditingController _controller = new TextEditingController();
  int _selectedIndex = 0;

  List<Todo> _todos = [];
  List<Todo> _doneTodos = [];

  void _addTodo(todo) {
    setState(() {
      _todos.add(todo);
      print(_todos);
    });
  }

  void _removeTodo(todo) {
    setState(() {
      _todos.removeAt(_todos.indexOf(todo));
      print(_todos);
    });
  }

  void _editTodo(todo) {
    setState(() {
      var todotoedit = _todos.elementAt(_todos.indexOf(todo));
      _todos.removeAt(_todos.indexOf(todo));
      _doneTodos.add(todotoedit);
    });
  }

  final List<Tab> myTabs = <Tab>[
    Tab(
      text: 'Todos',
    ),
    Tab(text: 'Finished'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: myTabs.length,
        child: Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              title: Text(
                "Todo App",
              ),
              bottom: TabBar(
                tabs: myTabs,
              ),
            ),
            body: TabBarView(children: [
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TodoAdder(_addTodo),
                    Divider(),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.all(5.0),
                      child: _todos.length > 0
                          ? new TodoList(_todos, _removeTodo, _editTodo)
                          : Center(
                              child: Text("No todos found, lets add one!"),
                            ),
                    )),
                  ]),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.all(5.0),
                      child: _doneTodos.length > 0
                          ? new FinishedTodoList(_doneTodos, _removeTodo)
                          : Center(
                              child: Text("No todos found, lets add one!"),
                            ),
                    )),
                  ])
            ]))
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}

class Todo {
  String title;
  bool done;
}

class TodoAdder extends StatelessWidget {
  final TextEditingController _controller = new TextEditingController();
  final Function addTodo;

  TodoAdder(this.addTodo);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        padding:
            EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
        child: Row(
          children: <Widget>[
            Expanded(
                child: new TextField(
              controller: _controller,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Write your todo'),
              onChanged: (String value) {},
            )),
            RaisedButton(
                color: Colors.green,
                textColor: Colors.white,
                elevation: 0.0,
                onPressed: () {
                  if (_controller.text != '') {
                    var todo = new Todo();
                    todo.title = _controller.text;
                    todo.done = false;
                    addTodo(todo);

                    _controller.clear();
                  }
                },
                child: Text("Add Task"))
          ],
        ));
  }
}

class TodoList extends StatelessWidget {
  final List<Todo> todolist;
  final Function removeTodo;
  final Function editTodo;
  TodoList(this.todolist, this.removeTodo, this.editTodo);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: todolist
          .map((todo) => Card(
                  child: Container(
                margin: EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(todo.title),
                    Row(
                      children: <Widget>[
                        IconButton(
                          color: Colors.green,
                          icon: Icon(Icons.check_circle),
                          onPressed: () {
                            editTodo(todo);
                          },
                        ),
                        IconButton(
                          color: Colors.red,
                          onPressed: () {
                            removeTodo(todo);
                          },
                          icon: Icon(Icons.cancel),
                        )
                      ],
                    )
                  ],
                ),
              )))
          .toList(),
    );
  }
}

class FinishedTodoList extends StatelessWidget {
  final List<Todo> todolist;
  final Function removeTodo;
  FinishedTodoList(this.todolist, this.removeTodo);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: todolist
          .map((todo) => Card(
                  child: Container(
                margin: EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 20.0, bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(todo.title),
                  ],
                ),
              )))
          .toList(),
    );
  }
}
