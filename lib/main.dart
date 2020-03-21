import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:helloword/models/item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.green),
      home: HomePage(),
    
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>();

  HomePage() {
    items = [];
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskControl = TextEditingController();

  _HomePageState() {
    load();
  }

  void addItem() {
    setState(() {
      if (newTaskControl.text.isEmpty) {
        return;
      }
      String textItem = newTaskControl.text;
      Item item = Item(title: textItem, done: false);
      widget.items.add(item);
      newTaskControl.clear();
    });
    save();
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
    });
    save();
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');
    if (data != null) {
      Iterable decodedJson = jsonDecode(data);
      List<Item> items =
          decodedJson.map((itemJson) => Item.fromJson(itemJson)).toList();
      setState(() {
        widget.items = items;
      });
    }
  }

  Future save() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.setString('data', jsonEncode(widget.items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back),
        title: TextFormField(
          controller: newTaskControl,
          keyboardType: TextInputType.text,
          style: TextStyle(color: Colors.white, fontSize: 20),
          decoration: InputDecoration(
              labelText: 'Nova Tarefa',
              labelStyle: TextStyle(color: Colors.white)),
        ),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          ButtonBar(
            children: <Widget>[Text('bem vindo')],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext ctx, int index) {
          final item = widget.items[index];
          return Dismissible(
            child: CheckboxListTile(
              title: Text(item.title),
              key: Key(item.title),
              value: item.done,
              onChanged: (value) => {
                setState(() {
                  item.done = value;
                   save();
                })
               
              },
            ),
            key: Key(item.title),
            background: Container(
                color: Colors.grey.withOpacity(0.2),
                child: Center(
                  child: Text(
                    'Remover item',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
            onDismissed: (DismissDirection direction) {
              remove(index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: this.addItem,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
