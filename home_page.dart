import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:todo_list/helpers/dataBase.helper.dart';
import 'package:todo_list/models/task.dart';
import 'package:todo_list/views/task_dialog.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> _taskList = [];
  TaskHelper _helper = TaskHelper();
  bool _loading = true;
  int _checks = 0;
  double _percentChecks = 0;
  String _printPercent = '';

  @override
  void initState() {
    super.initState();
    _helper.getAll().then((list) {
      setState(() {
        _taskList = list;
        _loading = false;
      });
    });
  }
  void bubbleSort(List<Task> list) {
    if (list == null || list.length == 0) return;

    int n = list.length;
    int i, step;
    for (step = 0; step < n; step++) {
      for ( i = 0; i < n - step - 1; i++) {
        if (list[i].priorit < list[i + 1].priorit) {
          swap(list, i);
        }
      }
    }
  }

  void swap(List<Task> list, int i) {
    Task temp = list[i];
    list[i] = list[i+1];
    list[i+1] = temp;
  }

  @override
  Widget build(BuildContext context) {
    bubbleSort(_taskList);
    for(int i = 0; i < _taskList.length; i ++)      print(_taskList[i].toMap());

    if(_taskList.length < 1) {
      _percentChecks = 0;
      _printPercent = '0.00';
    }else {

    _percentChecks = (_checks / _taskList.length);
    _printPercent = (_percentChecks * 100).toStringAsFixed(2);
    }
   
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Tarefas'),
      actions: <Widget>[ 
        new CircularPercentIndicator(
                radius: 40.0,
                lineWidth: 1.0,
                animation: true,
                percent: _percentChecks,
                center: new Text(
                  "$_printPercent%",
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
                ),
                footer: new Text(
                  "Tarefas concluídas",
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Colors.purple,
              ),
      ],
      ),
      
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.add), onPressed: _addNewTask),
      body: _buildTaskList(),
    );
  }

  Widget _buildTaskList() {
    
    if (_taskList.isEmpty) {
      return Center(
        child: _loading ? CircularProgressIndicator() : Text("Sem tarefas!"),
      );
    } else {
      return ListView.separated(
        separatorBuilder: (context,index) => Divider(color: Colors.black,),
        itemCount: _taskList.length,
        itemBuilder: _buildTaskItemSlidable, 
        
      );
      
    }
  }

  Widget _buildTaskItem(BuildContext context, int index) {
    final task = _taskList[index];

    return CheckboxListTile(
      value: task.isDone,
      title: Text(task.title),
      subtitle: (Text(task.description + '\n' 'Prioridade: ' + task.priorit.toString(), style: TextStyle(fontSize: 10))),
      onChanged: (bool isChecked) {
        setState(() {
          task.isDone = isChecked;
          if(isChecked)
            _checks = _checks + 1;
            else
             _checks = _checks - 1;
            print('CHECKS = ' + _checks.toString());
        });

        _helper.update(task);
      },
    );
  }

  Widget _buildTaskItemSlidable(BuildContext context, int index) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: _buildTaskItem(context, index),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Editar',
          color: Colors.blue,
          icon: Icons.edit,
          onTap: () {
            _addNewTask(editedTask: _taskList[index], index: index);
          },
        ),
        IconSlideAction(
          caption: 'Excluir',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            _deleteTask(deletedTask: _taskList[index], index: index);
          },
        ),
      ],
    );
  }

  Future _addNewTask({Task editedTask, int index}) async {
    final task = await showDialog<Task>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TaskDialog(task: editedTask);
      },
    );

    if (task != null) {
      setState(() {
        if (index == null) {
          _taskList.add(task);
          _helper.save(task);
        } else {
          _taskList[index] = task;
          _helper.update(task);
        }
      });
    }
  }

  void _deleteTask({Task deletedTask, int index}) {
    setState(() {
      _taskList.removeAt(index);
    });

    _helper.delete(deletedTask.id);

    Flushbar(
      title: "Exclusão de tarefas",
      message: "Tarefa \"${deletedTask.title}\" removida.",
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      duration: Duration(seconds: 3),
      mainButton: FlatButton(
        child: Text(
          "Desfazer",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          setState(() {
            _taskList.insert(index, deletedTask);
            _helper.update(deletedTask);
          });
        },
      ),
    )..show(context);
  }
}
