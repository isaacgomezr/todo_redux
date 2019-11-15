import 'package:flutter/material.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:todo_redux/model/model.dart';
import 'package:todo_redux/redux/actions.dart';
import 'package:todo_redux/redux/reducers.dart';
import 'package:todo_redux/redux/middleware.dart';
import 'package:redux_dev_tools/redux_dev_tools.dart';
import 'package:flutter_redux_dev_tools/flutter_redux_dev_tools.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DevToolsStore<AppState> store = DevToolsStore<AppState>(
      appStateReducer, 
      initialState: AppState.initialState(),
      middleware: [appStateMiddleware],
    );

    return StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Todo redux',
        theme: ThemeData(),
        home: StoreBuilder<AppState>(
          onInit: (store) => store.dispatch(GetItemsAction()),
          builder: (BuildContext context, Store<AppState> store)=>
          MyHomePage(store),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final DevToolsStore<AppState> store;
  MyHomePage(this.store);
  
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: Text('Redux Items'),
         backgroundColor: Colors.black,
         centerTitle: true,
       ),
       body: StoreConnector<AppState, _ViewModel>(
         converter: (Store<AppState> store) => _ViewModel.create(store),
         builder: (BuildContext context, _ViewModel viewModel) => 
         Card(
           
           shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
            ),
           color: Colors.white,
           elevation: 20,
           margin: EdgeInsets.all(100),
            child: Column(
             children: <Widget>[
               Padding(
                 padding: EdgeInsets.all(10),
                 child: Text('Lista de Items',
                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, fontFamily: 'FiraCode'),
                 ),
               ),
               AddItemWidget(viewModel),
               Expanded(child: ItemListWidget(viewModel),),
               RemoveItemsButton(viewModel),
             ],
           ),
         ),
       ),
       drawer: Container(
       
       ),
       bottomNavigationBar: BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('Home'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business),
          title: Text('Business'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          title: Text('School'),
        ),
      ],
      currentIndex: 0,
      selectedItemColor: Colors.blueAccent,
    ),
    );
  }
}
//Remove Items
class RemoveItemsButton extends StatelessWidget {
  final _ViewModel model;
  RemoveItemsButton(this.model);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(15.0),
        child: FloatingActionButton(
        backgroundColor: Colors.red,
        elevation: 8.0,
        child: Icon(Icons.delete_forever),
        onPressed: () => model.onRemoveItems(),
      ),
    );
  }
}

//Item list Items
class ItemListWidget extends StatelessWidget {
  final _ViewModel model;

  ItemListWidget(this.model);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: model.items.map(
        (Item item) => ListTile(
          title: Text(item.body),
          leading: IconButton(
            color: Colors.redAccent,
            icon: Icon(Icons.delete),
            onPressed: () => model.onRemoveItem(item),
          ),
        )
      ).toList(),
    );
  }
}


//Item add item 
class AddItemWidget extends StatefulWidget {
  final _ViewModel model;

  AddItemWidget(this.model);

  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItemWidget> {
  final TextEditingController controller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
          child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Agregar un Item',
        ),
        onSubmitted: (String s){
          widget.model.onAddItem(s);
          controller.text = '';
        },
      ),
    );
  }
}

class _ViewModel{
  final List<Item> items;
  final Function(String) onAddItem;
  final Function(Item) onRemoveItem;
  final Function() onRemoveItems;

  _ViewModel({
    this.items,
    this.onAddItem,
    this.onRemoveItem,
    this.onRemoveItems,
  });

  factory _ViewModel.create(Store<AppState> store){
    _onAddItem(String body){
      store.dispatch(AddItemAction(body));
    }

    _onRemoveItem(Item item){
      store.dispatch(RemoveItemAction(item));
    }

    _onRemoveItems(){
      store.dispatch(RemoveItemsAction());
    }

    return _ViewModel(
      items: store.state.items,
      onAddItem: _onAddItem,
      onRemoveItem: _onRemoveItem,
      onRemoveItems: _onRemoveItems,
    );
  }
}

