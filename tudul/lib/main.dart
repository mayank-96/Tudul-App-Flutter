import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tudul/models/task.dart';
import 'package:tudul/utils/colors.dart';
import 'package:tudul/utils/database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tudul',
      theme: ThemeData(
        primaryColor: darkblue,
        fontFamily: GoogleFonts.ubuntu().fontFamily,
      ),
      home: MyHomePage(title: 'TUDUL'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Task _task = Task();
  List<Task> _tasks = [];
  DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();
  final _ctrlName = TextEditingController();
  final _ctrlDesc = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _dbHelper = DatabaseHelper.instance;
    });
    _refreshTaskList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusManager.instance.primaryFocus?.unfocus,
      child: Scaffold(
        backgroundColor: lightblue,
        appBar: AppBar(
          leading: Image(
            image: AssetImage('assets/images/logo.png'),
          ),
          title: Text(
            widget.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _form(),
              _check(),
            ],
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  _form() => Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _ctrlName,
                decoration: InputDecoration(
                  labelText: 'Enter Task',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: mediumblue),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: darkblue, width: 2.0),
                  ),
                ),
                onSaved: (val) => setState(() => _task.name = val),
                validator: (val) =>
                    (val!.length == 0 ? 'This feild is required' : null),
              ),
              TextFormField(
                controller: _ctrlDesc,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: mediumblue),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: darkblue, width: 2.0),
                  ),
                ),
                onSaved: (val) => setState(() => _task.desc = val),
              ),
              InkWell(
                onTap: _onSubmit,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Container(
                    margin: EdgeInsets.all(10.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 25),
                      child: Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: darkblue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );

  _refreshTaskList() async {
    List<Task> x = await _dbHelper.fetchTasks();
    setState(() {
      _tasks = x;
    });
    _resetForm();
  }

  _onSubmit() async {
    var form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      if (_task.id == null)
        await _dbHelper.insertTask(_task);
      else
        await _dbHelper.updateTask(_task);

      _refreshTaskList();
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    }
  }

  _resetForm() {
    setState(() {
      _formKey.currentState!.reset();
      _ctrlName.clear();
      _ctrlDesc.clear();
      _task.id = null;
    });
  }

  _check() {
    if (_tasks.length == 0) {
      return _empty();
    } else {
      return _list();
    }
  }

  _empty() => Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          children: [
            Container(
                // child: Card(
                //   child: Image(
                //     image: AssetImage('assets/images/todo.png'),
                //     height: 145,
                //   ),
                //   elevation: 0,
                // ),
                ),
            // Text("No tasks!!"),
          ],
        ),
      );

  _list() => Expanded(
        child: Card(
          margin: EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(
                      Icons.task,
                      color: darkblue,
                      size: 40.0,
                    ),
                    title: Text(
                      _tasks[index].name!.toUpperCase(),
                      style: TextStyle(
                        color: darkblue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(_tasks[index].desc!),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete_sweep,
                        color: darkblue,
                      ),
                      onPressed: () async {
                        await _dbHelper.deleteTask(_tasks[index].id!);
                        _resetForm();
                        _refreshTaskList();
                      },
                    ),
                    onTap: () {
                      setState(() {
                        _task = _tasks[index];
                        _ctrlName.text = _tasks[index].name!;
                        _ctrlDesc.text = _tasks[index].desc!;
                      });
                    },
                  ),
                  Divider(
                    height: 10.0,
                  ),
                ],
              );
            },
            itemCount: _tasks.length,
          ),
        ),
      );
}
