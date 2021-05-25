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
        primaryColor: blue,
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
                  // enabledBorder: UnderlineInputBorder(
                  //   borderSide: BorderSide(color: Colors.red),
                  // ),
                  // focusedBorder: UnderlineInputBorder(
                  //   borderSide: BorderSide(color: blue, width: 12.0),
                  // ),
                ),
                onSaved: (val) => setState(() => _task.name = val),
                validator: (val) =>
                    (val!.length == 0 ? 'This feild is required' : null),
              ),
              TextFormField(
                controller: _ctrlDesc,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                ),
                onSaved: (val) => setState(() => _task.desc = val),
                // validator: (val) => (val!.length < 10
                //     ? 'Atleast 10 characters required'
                //     : null),
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
                      color: blue,
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
    List<Task> x = await _dbHelper.fetchContacts();
    setState(() {
      _tasks = x;
    });
  }

  _onSubmit() async {
    var form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      if (_task.id == null)
        await _dbHelper.insertContact(_task);
      else
        await _dbHelper.updateContact(_task);
      _resetForm();
      _refreshTaskList();
    }
  }

  _resetForm() {
    setState(() {
      _formKey.currentState!.reset();
      _ctrlName.clear();
      _ctrlDesc.clear();
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
        child: Container(
          child: Card(
            child: Image(
              image: AssetImage('assets/images/todo.png'),
              height: 145,
            ),
            elevation: 0,
          ),
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
                      color: blue,
                      size: 40.0,
                    ),
                    title: Text(
                      _tasks[index].name!.toUpperCase(),
                      style: TextStyle(
                        color: blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(_tasks[index].desc!),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete_sweep,
                        color: blue,
                      ),
                      onPressed: () async {
                        await _dbHelper.deleteContact(_tasks[index].id!);
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
                    height: 5.0,
                  ),
                ],
              );
            },
            itemCount: _tasks.length,
          ),
        ),
      );
}
