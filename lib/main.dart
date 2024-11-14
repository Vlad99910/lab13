import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() => runApp(MyApp());
//main
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _controller = TextEditingController();
  Database? _database;
  List<Map<String, dynamic>> _notes = [];
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }
//create db
  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'notes.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT, date TEXT)",
        );
      },
      version: 1,
    );
    _loadNotes();
  }
//see note
  Future<void> _loadNotes() async {
    final List<Map<String, dynamic>> notes = await _database!.query('notes', orderBy: "id DESC");
    setState(() {
      _notes = notes;
    });
  }
//db add note
  Future<void> _addNote() async {
    if (_controller.text.trim().isEmpty) {
      setState(() {
        _errorText = "Поле не може бути порожнім";
      });
      return;
    }

    setState(() {
      _errorText = null;
    });

    final note = {
      'text': _controller.text,
      'date': DateTime.now().toString(),
    };
    await _database!.insert('notes', note);
    _controller.clear();
    _loadNotes();
  }

  @override
  void dispose() {
    _controller.dispose();
    _database?.close();
    super.dispose();
  }
//UI...........................
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Demo Home Page'),
      ),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: 'Нотатка',
                          errorText: _errorText,
                        ),
                      ),
                  ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _addNote,
                child: Text('Add'),
              ),
            ],
          ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return ListTile(
                  title: Text(note['text']),
                  subtitle: Text(note['date']),
                );
                },
            ),
          ),
        ],
      ),
    );
  }
}
