import 'package:flutter/material.dart';
import 'package:todo_list/models/task.dart';

class TaskDialog extends StatefulWidget {
  final Task task;

  TaskDialog({this.task});

  @override
  _TaskDialogState createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prioritControler = TextEditingController();

  Task _currentTask = Task();

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _currentTask = Task.fromMap(widget.task.toMap());
    }

    _titleController.text = _currentTask.title;
    _descriptionController.text = _currentTask.description;
    _prioritControler.text = _currentTask.priorit.toString() == null? _currentTask.priorit.toString(): '1';
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.clear();
    _descriptionController.clear();
  }

  bool validatePriorit(String value){
    var numValue = int.tryParse(value);
  if(numValue >= 0 && numValue <= 5) {
    return true;
  } else return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Nova tarefa' : 'Editar tarefas'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Título'),
              autofocus: true,
              ),
          TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: InputDecoration(labelText: 'Descrição')),
          TextFormField(
              controller: _prioritControler,
              decoration: InputDecoration(labelText: 'Nível de prioridade(1-5)'),
              keyboardType: TextInputType.number,
              maxLength: 1,              
              )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('Salvar'),
          onPressed: () {
            if(_titleController.text.isEmpty == false)
              if(_descriptionController.text.isEmpty == false)
                if(_prioritControler.text.isEmpty == false)
                {
                  if(int.tryParse(_prioritControler.text) <= 5 && int.tryParse(_prioritControler.text) > 0)
                  {
                      _currentTask.title = _titleController.value.text;
                      _currentTask.description = _descriptionController.text;
                      _currentTask.priorit = int.parse(_prioritControler.text);
                      Navigator.of(context).pop(_currentTask);
                      return;
                  }
                }
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: new Text("CAMPOS INVÁLIDOS!"),
                        content: new Text("Digite os campos corretamente para prosseguir!"),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text("Close"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    }
                  );
          },
        ),
      ],
    );
  }
}
