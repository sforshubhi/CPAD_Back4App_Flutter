import 'package:flutter/material.dart';
import 'dart:async';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class todoScreen extends StatefulWidget {


  const todoScreen({Key? key}) : super(key: key);

  @override
  State<todoScreen> createState() => _todoScreenState();
}

class _todoScreenState extends State<todoScreen> {

  final TextEditingController todoTitleController = TextEditingController();
  final TextEditingController todoDescriptionController = TextEditingController();

  final TextEditingController todoEditTitleController = TextEditingController();
  final TextEditingController todoEditDescriptionController = TextEditingController();


  void addToDo() async {
    if (todoTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Empty title task"),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    await saveTodo(todoTitleController.text, todoDescriptionController.text);
    setState(() {
      todoTitleController.clear();
      todoDescriptionController.clear();
    });
  }

  Future<void> saveTodo(String title, String description) async {
    final todoBITS = ParseObject('ToDo_BITS')..set('title', title)..set('description', description)..set('completed', false);
    await todoBITS.save();
  }

  Future<List<ParseObject>> getTodo() async {
    QueryBuilder<ParseObject> queryTodo =
    QueryBuilder<ParseObject>(ParseObject('ToDo_BITS'));
    final ParseResponse apiResponse = await queryTodo.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }

  Future<void> editTodo(String id) async {
    var todoBITS = ParseObject('ToDo_BITS')
      ..objectId = id
      ..set('title', todoEditTitleController.text)..set('description', todoEditDescriptionController.text);
    await todoBITS.save();
  }

  Future<void> updateTodo(String id, bool completed) async {
    var todoBITS = ParseObject('ToDo_BITS')
      ..objectId = id
      ..set('completed', completed);
    await todoBITS.save();
  }

  Future<void> deleteTodo(String id) async {
    var todoBITS = ParseObject('ToDo_BITS')..objectId = id;
    await todoBITS.delete();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Column(
            children: [
              ListTile(
                title: Text('Aravind T'),
                subtitle: Text('2022mt93159@wilp.bits-pilani.ac.in'),
              )
            ],
          ),
          Container(
              padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      autocorrect: true,
                      textCapitalization: TextCapitalization.sentences,
                      controller: todoTitleController,
                      decoration: InputDecoration(
                          labelText: "Title",
                          labelStyle: TextStyle(color: Colors.indigo)),
                    ),
                  ),
                ],
              )),
          Container(
              padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      autocorrect: true,
                      textCapitalization: TextCapitalization.sentences,
                      controller: todoDescriptionController,
                      decoration: InputDecoration(
                          labelText: "Description",
                          labelStyle: TextStyle(color: Colors.indigo)),
                    ),
                  ),
                ],
              )),
          Container(
              padding: EdgeInsets.fromLTRB(17.0, 17.0, 7.0, 1.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          onPrimary: Colors.white,
                          primary: Colors.indigo,
                        ),
                        onPressed: addToDo,
                        child: Text("Add To Do")),
                  ),
                ],
              )),

          Expanded(
              child: FutureBuilder<List<ParseObject>>(
                  future: getTodo(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: Container(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator()),
                        );
                      default:
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error..."),
                          );
                        }
                        if (!snapshot.hasData) {
                          return Center(
                            child: Text("No Data..."),
                          );
                        } else {
                          return ListView.builder(
                              padding: EdgeInsets.only(top: 10.0),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                //*************************************
                                //Get Parse Object Values
                                final varTodo = snapshot.data![index];
                                final varTitle = varTodo.get<String>('title')!;
                                final varDescription = varTodo.get<String>('description')!;
                                final varCompleted = varTodo.get<bool>('completed')!;
                                final varCreatedAt = varTodo.get<DateTime>('createdAt')!;
                                //*************************************

                                  if (varCompleted == false) {
                                  return ListTile(
                                    onTap: () {
                                      setState(() {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              scrollable: true,
                                              title: const Text("Task Details"),
                                              content: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Form(
                                                  child: Column(
                                                    children: [
                                                      ListTile(
                                                        title: Text(varTitle),
                                                        subtitle: Text(varDescription),
                                                        leading: Icon(
                                                            varCompleted ? Icons.check : Icons.access_alarms),
                                                      ),
                                                      Column(
                                                        children: [
                                                          ListTile(
                                                            title: Text('Added on:'),
                                                            subtitle: Text(varCreatedAt.toString()),
                                                          )
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          ListTile(
                                                            title: Text('Status'),
                                                            subtitle: varCompleted ? Text('Completed') : Text('Pending'),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                        final snackBar = SnackBar(
                                          content: Text("Todo edited!"),
                                          duration: Duration(seconds: 2),
                                        );
                                        ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(snackBar);
                                      });
                                    },
                                    title: Text(varTitle),
                                    subtitle: Text(varDescription),
                                    leading: CircleAvatar(
                                      child: Icon(
                                          varCompleted ? Icons.check : Icons.access_time_filled),
                                      backgroundColor:
                                      varCompleted ? Colors.green : Colors.redAccent,
                                      foregroundColor: Colors.white,
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Checkbox(
                                            value: varCompleted,
                                            onChanged: (value) async {
                                              await updateTodo(
                                                  varTodo.objectId!, value!);
                                              setState(() {
                                                //Refresh UI
                                              });
                                            }),
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.indigo,
                                          ),
                                          onPressed: () async {
                                            setState(() {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      scrollable: true,
                                                      title: const Text("Edit To Do Item"),
                                                      content: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Form(
                                                          child: Column(
                                                            children: [
                                                              ListTile(
                                                              title: Text(varTitle),
                                                          subtitle: Text(varDescription),
                                                                leading: Icon(
                                                                      varCompleted ? Icons.check : Icons.access_time_filled),
                                                                ),
                                                              TextFormField(
                                                                decoration: const InputDecoration(
                                                                  labelText: 'New Title',
                                                                  icon: Icon(Icons.title),
                                                                  iconColor: Colors.indigo,
                                                                  fillColor: Colors.indigo,
                                                                    focusColor: Colors.indigo
                                                                ),
                                                                controller: todoEditTitleController,
                                                              ),
                                                              TextFormField(
                                                                decoration: const InputDecoration(
                                                                  labelText: "New Description",
                                                                  icon: Icon(Icons.description),
                                                                    iconColor: Colors.indigo,
                                                                    fillColor: Colors.indigo,
                                                                    focusColor: Colors.indigo
                                                                ),
                                                                controller: todoEditDescriptionController,
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      actions: [
                                                        ElevatedButton(
                                                          child: const Text("Done"),
                                                          onPressed: () {
                                                            editTodo(varTodo.objectId!);
                                                            todoEditTitleController.clear();
                                                            todoEditDescriptionController.clear();
                                                            setState(() {
                                                              Navigator.of(context).pop();
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              final snackBar = SnackBar(
                                                content: Text("Todo edited!"),
                                                duration: Duration(seconds: 2),
                                              );
                                              ScaffoldMessenger.of(context)
                                                ..removeCurrentSnackBar()
                                                ..showSnackBar(snackBar);
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.indigo,
                                          ),
                                          onPressed: () async {
                                            await deleteTodo(varTodo.objectId!);
                                            setState(() {
                                              final snackBar = SnackBar(
                                                content: Text("Todo deleted!"),
                                                duration: Duration(seconds: 2),
                                              );
                                              ScaffoldMessenger.of(context)
                                                ..removeCurrentSnackBar()
                                                ..showSnackBar(snackBar);
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                  );
                                  } else {
                                    return Center();
                                  }
                              });
                        }
                    }
                  }))
        ],
      ),
    );
  }
}
