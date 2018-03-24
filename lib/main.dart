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
      sort: (a, b) => (calculateScore(b) - calculateScore(a)).round(),
    );
  }

  Widget _buildRow(DataSnapshot snapshot) {
    return new ListTile(
      title: new Text(snapshot.value['name']),
      onTap: () {
        _viewIdea(snapshot);
      },
      trailing: new Text(calculateScore(snapshot).toStringAsFixed(2)),
    );
  }
  
  double calculateScore(DataSnapshot snapshot) {
    final difficultyMult = 1;
    final interestMult = 1;
    final costMult = 1;
    final timeMult = 1;

    final difficulty = (snapshot.value['difficulty'] * -1 + 6) * difficultyMult;
    final interest = (snapshot.value['interest']) * interestMult;
    final cost = (snapshot.value['cost'] * -1 + 6) * costMult;
    final time = (snapshot.value['time'] * -1 + 6) * timeMult;

    return (difficulty + interest + cost + time) / 4;
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
  int _difficulty = 3;
  int _interest = 3;
  int _time = 3;
  int _cost = 3;

  @override
  Widget build(BuildContext context) {
    if (snapshot != null) {
      _name = snapshot.value['name'];
      _description = snapshot.value['description'];
      _difficulty = snapshot.value['difficulty'];
      _interest = snapshot.value['interest'];
      _time = snapshot.value['time'];
      _cost = snapshot.value['cost'];
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
          new Row(
            children: <Widget>[
              buildDropdownButton(_difficulty, 'Difficulty', (val) {
                if (snapshot != null) {
                  snapshot.value['difficulty'] = val;
                } else {
                  _difficulty = val;
                }
              }),
              buildDropdownButton(_interest, 'Interest', (val) {
                if (snapshot != null) {
                  snapshot.value['interest'] = val;
                } else {
                  _interest = val;
                }
              }),
              buildDropdownButton(_time, 'Time', (val) {
                if (snapshot != null) {
                  snapshot.value['time'] = val;
                } else {
                  _time = val;
                }
              }),
              buildDropdownButton(_cost, 'Cost', (val) {
                if (snapshot != null) {
                  snapshot.value['cost'] = val;
                } else {
                  _cost = val;
                }
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDropdownButton(
      int value, String title, ValueChanged<int> onChanged) {
    return new Flexible(
      child: new ListTile(
        title: new Text(title),
        subtitle: new DropdownButton(
          items: [1, 2, 3, 4, 5]
              .map((item) => new DropdownMenuItem(
                    child: new Text(item.toString()),
                    value: item,
                  ))
              .toList(),
          onChanged: onChanged,
          value: value,
        ),
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
        'difficulty': _difficulty,
        'interest': _interest,
        'time': _time,
        'cost': _cost,
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
          title: new Text('Name'),
          subtitle: new Text(snapshot.value['name']),
        ),
        new ListTile(
          title: new Text('Description'),
          subtitle: new Text(snapshot.value['description']),
        ),
        new Row(
          children: <Widget>[
            new Flexible(
              child: new ListTile(
                title: new Text('Difficulty'),
                subtitle: new Text(snapshot.value['difficulty'].toString()),
              ),
            ),
            new Flexible(
              child: new ListTile(
                title: new Text('Interest'),
                subtitle: new Text(snapshot.value['interest'].toString()),
              ),
            ),
            new Flexible(
              child: new ListTile(
                title: new Text('Time'),
                subtitle: new Text(snapshot.value['time'].toString()),
              ),
            ),
            new Flexible(
              child: new ListTile(
                title: new Text('Cost'),
                subtitle: new Text(snapshot.value['cost'].toString()),
              ),
            ),
          ],
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
