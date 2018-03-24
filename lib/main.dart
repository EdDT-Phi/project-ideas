import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

final DatabaseReference reference =
    FirebaseDatabase.instance.reference().child('ideas');

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Project Ideas',
      home: new ProjectIdeas(),
    );
  }
}

class ProjectIdeas extends StatefulWidget {
  @override
  createState() => new ProjectIdeasState();
}

class ProjectIdeasState extends State<ProjectIdeas> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Project Ideas'),
      ),
      body: _projectsList(),
      floatingActionButton: new FloatingActionButton(
          onPressed: _newIdea, child: new Icon(Icons.add)),
    );
  }

  Widget _projectsList() {
    return new FirebaseAnimatedList(
      query: reference,
      itemBuilder:
          (_, DataSnapshot snapshot, Animation<double> animation, int n) {
        return _buildRow(snapshot);
      },
    );
  }

  Widget _buildRow(DataSnapshot snapshot) {
    return new ListTile(
        title: new Text(snapshot.value['name']),
        onTap: () {
          _viewIdea(snapshot);
        });
  }

  void _newIdea() {
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      return new EditIdea();
    }));
  }

  void _viewIdea(DataSnapshot snapshot) {
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      return new ViewIdea(snapshot: snapshot);
    }));
  }
}

class EditIdea extends StatefulWidget {
  EditIdea({this.snapshot});
  final DataSnapshot snapshot;

  @override
  createState() => new EditIdeaState(snapshot: snapshot);
}

class EditIdeaState extends State<EditIdea> {
  EditIdeaState({this.snapshot});
  final formKey = new GlobalKey<FormState>();
  DataSnapshot snapshot;
  String _name = '';
  String _description = '';
  double _difficulty = 3.0;

  final numbers =
      [1, 2, 3, 4, 5].map((item) => new DropdownMenuItem(
            child: new Text(item.toString()),
            value: item,
          )).toList();

  @override
  Widget build(BuildContext context) {
    if (snapshot != null) {
      _name = snapshot.value['name'];
      _description = snapshot.value['description'];
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Project Ideas'),
      ),
      body: buildForm(),
      floatingActionButton: new FloatingActionButton(
          onPressed: _saveIdea, child: new Icon(Icons.save)),
    );
  }

  Form buildForm() {
    return new Form(
      key: formKey,
      child: new Column(
        children: <Widget>[
          new TextFormField(
            decoration: new InputDecoration(labelText: 'Idea Name'),
            initialValue: _name,
            validator: (val) => val.isEmpty ? 'Name can\'t be empty.' : null,
            onSaved: (val) => _name = val,
          ),
          new TextFormField(
            decoration: new InputDecoration(labelText: 'Description'),
            initialValue: _description,
            validator: (val) =>
                val.isEmpty ? 'Description can\'t be empty.' : null,
            onSaved: (val) => _description = val,
          ),
          new DropdownButton(
            items: numbers,
            onChanged: (val) => _difficulty = val,
            value: _difficulty,
          ),
        ],
      ),
    );
  }

  void _saveIdea() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();

      DatabaseReference newIdea;
      if (snapshot == null) {
        newIdea = reference.push();
      } else {
        newIdea = reference.child(snapshot.key);
      }

      newIdea.set({
        'name': _name,
        'description': _description,
      });

      newIdea.once().then((snapshot) {
        Navigator
            .of(context)
            .pushReplacement(new MaterialPageRoute(builder: (context) {
          return new ViewIdea(snapshot: snapshot);
        }));
      });
    }
  }
}

class ViewIdea extends StatelessWidget {
  ViewIdea({this.snapshot});
  final DataSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Project Ideas'),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.delete),
              onPressed: () {
                _deleteIdea(context);
              })
        ],
      ),
      body: _buildView(),
      floatingActionButton: new FloatingActionButton(
          onPressed: () {
            _editIdea(context);
          },
          child: new Icon(Icons.edit)),
    );
  }

  Widget _buildView() {
    return new Column(
      children: <Widget>[
        new ListTile(
          title: new Text(snapshot.value['name']),
        ),
        new ListTile(
          title: new Text(snapshot.value['description']),
        ),
      ],
    );
  }

  void _editIdea(BuildContext context) {
    Navigator
        .of(context)
        .pushReplacement(new MaterialPageRoute(builder: (context) {
      return new EditIdea(snapshot: snapshot);
    }));
  }

  void _deleteIdea(BuildContext context) {
    DatabaseReference idea = reference.child(snapshot.key);
    idea.remove();
    Navigator.of(context).pop();
  }
}
