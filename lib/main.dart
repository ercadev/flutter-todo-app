import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                            margin: EdgeInsets.only(left: 5.0, right: 5.0),
                            child: TodoList())),
                  ]),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                        child: Container(
                            margin: EdgeInsets.all(5.0),
                            child: FinishedTodoList())),
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
                  Firestore.instance
                      .collection('todos')
                      .document()
                      .setData({'title': _controller.text, 'done': false});
                  _controller.clear();
                },
                child: Text("Add Task"))
          ],
        ));
  }
}

class TodoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('todos')
          .where('done', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        return _todoList(context, snapshot.data.documents);
      },
    );
  }
}

class FinishedTodoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('todos')
          .where('done', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        return _todoList(context, snapshot.data.documents);
      },
    );
  }
}

Widget _todoItem(BuildContext context, DocumentSnapshot data) {
  final record = Record.fromSnapshot(data);
  return Card(
      child: Container(
    margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 5.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(record.title),
        Row(
          children: <Widget>[
            IconButton(
              color: Colors.green,
              icon: Icon(Icons.check_circle),
              onPressed: () {
                record.reference.updateData({'done': true});
              },
            ),
            IconButton(
              color: Colors.red,
              onPressed: () {
                record.reference.delete();
              },
              icon: Icon(Icons.cancel),
            )
          ],
        )
      ],
    ),
  ));
}

Widget _todoList(BuildContext context, List<DocumentSnapshot> snapshot) {
  return ListView(
    padding: const EdgeInsets.only(),
    children: snapshot.map((data) => _todoItem(context, data)).toList(),
  );
}

class Record {
  final String title;
  final bool done;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['title'] != null),
        assert(map['done'] != null),
        title = map['title'],
        done = map['done'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$title:$done>";
}
