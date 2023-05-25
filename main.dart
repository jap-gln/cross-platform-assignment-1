import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dattaraj\'s CRED App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  List<Map<String, dynamic>> _people = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + '/people.db';
    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE people (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER, address TEXT)');
    });
    List<Map<String, dynamic>> people = await database.query('people');
    setState(() {
      _people = people;
    });
  }

  Future<void> _insertPerson(String name, int age, String address) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + '/people.db';
    Database database = await openDatabase(path, version: 1);
    await database
        .insert('people', {'name': name, 'age': age, 'address': address});
    List<Map<String, dynamic>> people = await database.query('people');
    setState(() {
      _people = people;
    });
  }

  Future<void> _updatePerson(
      int id, String name, int age, String address) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + '/people.db';
    Database database = await openDatabase(path, version: 1);
    await database.update(
        'people', {'name': name, 'age': age, 'address': address},
        where: 'id = ?', whereArgs: [id]);
    List<Map<String, dynamic>> people = await database.query('people');
    setState(() {
      _people = people;
    });
  }

  Future<void> _deletePerson(int id) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + '/people.db';
    Database database = await openDatabase(path, version: 1);
    await database.delete('people', where: 'id = ?', whereArgs: [id]);
    List<Map<String, dynamic>> people = await database.query('people');
    setState(() {
      _people = people;
    });
  }

  void _showAddPersonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Person'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(labelText: 'Age'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter an age';
                    } else if (int.tryParse(value) == null) {
                      return 'Please enter a valid integer age';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter an address';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  String name = _nameController.text;
                  int age = int.parse(_ageController.text);
                  String address = _addressController.text;
                  await _insertPerson(name, age, address);
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditPersonDialog(
      BuildContext context, Map<String, dynamic> person) {
    _nameController.text = person['name'];
    _ageController.text = person['age'].toString();
    _addressController.text = person['address'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Person'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(labelText: 'Age'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter an age';
                    } else if (int.tryParse(value) == null) {
                      return 'Please enter a valid integer age';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter an address';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  int id = person['id'];
                  String name = _nameController.text;
                  int age = int.parse(_ageController.text);
                  String address = _addressController.text;
                  await _updatePerson(id, name, age, address);
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dattaraj\'s CRED App'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: _people.length,
          itemBuilder: (BuildContext context, int index) {
            Map<String, dynamic> person = _people[index];
            return ListTile(
              title: Text(person['name']),
              subtitle:
                  Text('${person['age']} years old, ${person['address']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showEditPersonDialog(context, person);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await _deletePerson(person['id']);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddPersonDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
