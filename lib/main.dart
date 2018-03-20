import 'package:flutter/material.dart';

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
  final _ideas = <String>['idea1', 'idea2', 'idea3', 'idea4'];

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
    return new ListView.builder(
      itemBuilder: (context, i) {
        if (i.isOdd) return new Divider();
        final index = i ~/ 2;
        return new ProjectIdeaRow(text: _ideas[index]);
      },
      itemCount: _ideas.length * 2,
    );
  }

  void _newIdea() {
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      return new EditIdea();
    }));
  }
}

class ProjectIdeaRow extends StatelessWidget {
  ProjectIdeaRow({this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return new ListTile(title: new Text(text));
  }
}

class EditIdea extends StatefulWidget {
  @override
  createState() => new EditIdeaState();
}

class EditIdeaState extends State<EditIdea> {
  final formKey = new GlobalKey<FormState>();
  String _username;

  @override
  Widget build(BuildContext context) {
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
            validator: (val) => val.isEmpty ? 'Name can\'t be empty.' : null,
            onSaved: (val) => _username = val,
          ),
        ],
      ),
    );
  }

  void _saveIdea() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();

      // TODO(eddie): Save to database.
    }
  }
}
