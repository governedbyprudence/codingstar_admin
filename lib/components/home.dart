import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'addcourse.dart';

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  _homeState createState() => _homeState();
}

class _homeState extends State<home> {
  List<Widget> widgets = [addcourse(),viewcourse()] ;
  int _index = 0 ;
  void _onitemtap(int index){
    setState(() {
      _index=index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
      ),
      drawer: Drawer(
        
        child: ListView(
          children: [
            ListTile(title: Text("Options",style: TextStyle(fontSize: 20),))
            ,
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(width: 1),bottom: BorderSide(width: 1)),
            ),
            child: ListTile(
              leading: TextButton(onPressed: (){
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, "login");
              }, child:Text("Logout",style: TextStyle(color: Colors.black,fontSize: 15),)),
            ),
          )
          ],
        ),
      ),
      body:widgets[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.add),label: "Add"),
          BottomNavigationBarItem(icon: Icon(Icons.bolt),label: "View"),
        ],
        selectedItemColor: Colors.blue,
        onTap: _onitemtap,
      ),
    );
  }
}
