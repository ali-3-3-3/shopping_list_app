import 'package:flutter/material.dart';
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
  final List<GroceryItem> _groceryItems = [];

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

  void _removeItem(GroceryItem item) {
    _groceryItems.remove(item);
  }

  @override
  Widget build(context) {
    Widget content = Center(
      child: Text('Add some items!'),
    );

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
