import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class textview extends StatefulWidget {
  String course,topic;
  QueryDocumentSnapshot data;
  textview({required this.course,required this.topic,required this.data});
  @override
  _textviewState createState() => _textviewState(course:course,topic:topic,data : data);
}

class _textviewState extends State<textview> {
  TextEditingController _controller = new TextEditingController();
  TextEditingController _desccontroller = new TextEditingController();
  String mess = "";
  String course,topic;
  QueryDocumentSnapshot data;
  _textviewState({required this.course,required this.topic,required this.data});
  @override
  void initState() {
    super.initState();
    _controller.text = data.get("name");
    _desccontroller.text = data.get("desc");
  }
  void editdata(){
    FirebaseFirestore.instance
        .collection("courses")
        .doc(course)
        .collection("topics")
        .doc(topic)
        .collection("elements")
        .doc(data.id)
        .set({
      "name":_controller.text,
      "desc":_desccontroller.text,
      "type" : "text",
    }).then((value){
      setState(() {
        mess = "Set successfully";
      });
    }).catchError((err){
      setState(() {
        mess = "Error occured";
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data.id),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: [
            SizedBox(height: 40),
            Text(mess,style: TextStyle(color: Colors.red),),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
        fillColor: Colors.grey.shade100,
            filled: true,
            hintText: "",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            )),
            ),
            SizedBox(height: 40,),
            TextField(
              maxLines: 6,
              controller: _desccontroller,
              decoration: InputDecoration(
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  hintText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
            ),
            TextButton(onPressed: (){
              if (_controller.text.isNotEmpty && _desccontroller.text.isNotEmpty){
                editdata();
              }
            }, child: Text("Save"))
          ],
        ),
      ),
    );
  }
}
