import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_api_crud/screens/add_page.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List items = [];
  bool isLoading = true;
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List"),
      ),
      body: RefreshIndicator(
        onRefresh: fetchTodo,
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index] as Map;
            final id = item['_id'] as String;
            return ListTile(
              leading: CircleAvatar(child: Text('${index+1}')),
              title: Text(item['title']),
              subtitle: Text(item['description']),
              trailing: PopupMenuButton(
                onSelected: (value){
                  if(value == 'edit'){
                    NavigateToEditPage(item);
                  }else if(value == 'delete'){
                    DeleteById(id);
                  }
                },
                itemBuilder: (context){
                  return [
                    PopupMenuItem(child: Text('Edit'),
                    value: 'edit',
                    ),
                    PopupMenuItem(child: Text('Delete'),
                    value: 'delete',),
                  ];
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          NavigateToAddPage();
        },
        backgroundColor: Colors.grey.shade300,
        label: Text("Add Todo"),
      ),
    );
  }

  Future<void> NavigateToAddPage() async{
    final route = MaterialPageRoute(
      builder: (context) => AddPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> NavigateToEditPage(Map item) async{
    final route = MaterialPageRoute(
      builder: (context) => AddPage(todo:item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }


  Future<void> DeleteById(String id) async{
    final url = 'http://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if(response.statusCode == 200){
      setState(() {
        fetchTodo();
      });
    }else{

    }
  }

  Future<void> fetchTodo() async {
    final url = 'http://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }
    else{
      isLoading = false;
    }
  }
}
