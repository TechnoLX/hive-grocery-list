import 'package:flutter/material.dart';
import 'package:flutter_video/helper.dart';

class Demo extends StatefulWidget {
  Demo({Key? key}) : super(key: key);

  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  //this is to load all grocery items into here
  //and update the screen
  List<Map<String, dynamic>> _groceryItem = [];

  @override
  void initState() {
    setState(() {
      //get all grocery item from Hive
      _groceryItem = HiveHelper.getGroceries();
    });
    super.initState();
  }

  //for text field, to add/update grocery items
  final _itemController = TextEditingController();
  final _quantityController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Hive Grocery'),
      ),
      //if no grocery items loaded, then display text
      body: _groceryItem.isEmpty
          ? Center(
              child: Text(
                'No Grocery Items added yet!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: _groceryItem.length,
              itemBuilder: (context, index) {
                //print current item follow index
                final _item = _groceryItem[index];
                return Card(
                  elevation: 5,
                  child: ListTile(
                    title: Text(_item['item']),
                    subtitle: Text(_item['date']),
                    leading: Text(_item['quantity']),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      //lets delete
                      onPressed: () {
                        HiveHelper.deleteItem(_item['key']);
                        setState(() {
                          //get latest list
                          _groceryItem = HiveHelper.getGroceries();
                        });
                      },
                    ),
                    onTap: () => _groceryModel(context, _item['key']),
                  ),
                );
              },
            ),
      //this is to add item into Hive
      floatingActionButton: FloatingActionButton(
        onPressed: () => _groceryModel(context, null),
        child: Icon(Icons.add),
      ),
    );
  }

  //lets create an alert dialog to add item
  //use this model to add and update
  void _groceryModel(BuildContext context, int? key) {
    //if key is not null, mean this modal use to update
    //if null, mean is to add new item
    if (key != null) {
      final _currentItem =
          _groceryItem.firstWhere((item) => item['key'] == key);
      _itemController.text = _currentItem['item'];
      _quantityController.text = _currentItem['quantity'];
      _dateController.text = _currentItem['date'];
    }
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: key == null ? Text('Add Items') : Text('Update Items'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              //text field
              _buildTextField(_itemController, 'Item'),
              SizedBox(
                height: 10,
              ),
              _buildTextField(_quantityController, 'Quantity'),
              SizedBox(
                height: 10,
              ),
              _buildTextField(_dateController, 'Date'),
            ],
          ),
          //let complete this
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                //if null
                //add grocery item into Hive
                if (key == null) {
                  HiveHelper.addItem({
                    'item': _itemController.text,
                    'quantity': _quantityController.text,
                    'date': _dateController.text,
                  });
                  //else, update item
                } else {
                  HiveHelper.updateItem(key, {
                    'item': _itemController.text,
                    'quantity': _quantityController.text,
                    'date': _dateController.text,
                  });
                }

                //clear all text
                _itemController.clear();
                _quantityController.clear();
                _dateController.clear();

                //get latest grocery list
                setState(() {
                  _groceryItem = HiveHelper.getGroceries();
                  Navigator.of(context).pop();
                });
              },
              child: key == null ? Text('Add New') : Text('Update'),
            )
          ],
        );
      },
    );
  }

  //build text field method
  TextField _buildTextField(TextEditingController _controller, String hint) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: hint,
        labelText: hint,
      ),
    );
  }
}


//Bingo!! add, read and delete item successfully
//now try update

//Yeah! CRUD operation in Hive has been performed successfully
//Hive NoSQL database is easy and fast compared to Shared Preference
//and SQLite

//for more details, please refer to Hive official docs
//in this video, i has demonstrated a basic use of Hive 
//and CRUD operation by build a grocery application

//in next, i will discuss about custom object in Hive
//stay tuned!