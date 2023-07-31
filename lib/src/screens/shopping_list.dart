import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/src/data/categories.dart';
import 'package:shopping_list_app/src/models/grocery_item.dart';
import 'package:shopping_list_app/src/screens/new_item.dart';

class ShoppingList extends StatefulWidget {
  const ShoppingList({super.key});

  @override
  State<ShoppingList> createState() {
    return _ShoppingListState();
  }
}

class _ShoppingListState extends State<ShoppingList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'shopping-list-app-6ed53-default-rtdb.asia-southeast1.firebasedatabase.app/',
        'shopping-list.json');
    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(
          () {
            _error = 'Failed to fetch data. Please try again later.';
          },
        );
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> _loadedItems = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
              (catItem) => catItem.value.title == item.value['category'],
            )
            .value;
        _loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantities'],
            category: category,
          ),
        );
      }

      setState(() {
        _groceryItems = _loadedItems;
        _isLoading = false;
      });
      // ignore: unused_catch_clause
    } on Exception catch (e) {
      setState(
        () {
          _error = 'Something went wrong. Please try again later.';
        },
      );
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
        'shopping-list-app-6ed53-default-rtdb.asia-southeast1.firebasedatabase.app/',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(
        () {
          _groceryItems.insert(index, item);
        },
      );
    }
  }

  @override
  Widget build(context) {
    Widget content = Center(
      child: Text('Add some items!'),
    );
    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: ValueKey(_groceryItems[index].id),
            onDismissed: (direction) => _removeItem(
              _groceryItems[index],
            ),
            child: ListTile(
              dense: true,
              leading: Icon(
                Icons.check_box,
              ),
              iconColor: _groceryItems[index].category.color,
              title: Text(_groceryItems[index].name),
              trailing: Text(
                _groceryItems[index].quantity.toString(),
              ),
            ),
          );
        },
      );
      if (_error != null) {
        content = Center(
          child: Text(_error!),
        );
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping List'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
