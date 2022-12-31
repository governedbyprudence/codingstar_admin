import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class quizview extends StatefulWidget {
  String course,topic;
  QueryDocumentSnapshot data;
  quizview({required this.course,required this.topic,required this.data});
  @override
  _quizviewState createState() => _quizviewState(course: course,topic: topic,data: data);
}

class _quizviewState extends State<quizview> {
  TextEditingController _controller = new TextEditingController();
  TextEditingController _question=new TextEditingController();
  TextEditingController _first=new TextEditingController();
  TextEditingController _second=new TextEditingController();
  TextEditingController _third=new TextEditingController();
  TextEditingController _fourth=new TextEditingController();
  TextEditingController _correct=new TextEditingController();

  String mess = "";
  String course,topic;
  QueryDocumentSnapshot data;
  _quizviewState({required this.course,required this.topic,required this.data});
  @override
  void initState() {
    super.initState();
    _controller.text = data.id;
    _question.text = data.get("question");
    _first.text = data.get("first");
    _second.text = data.get("second");
    _third.text = data.get("third");
    _fourth.text = data.get("fourth");
    _correct.text = data.get("correct");
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
      "question":_question.text,
      "first" : _first.text,
      "second" : _second.text,
      "third" : _third.text,
      "fourth" : _fourth.text,
      "correct" : _correct.text,
      "type" : "quiz",

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
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            SizedBox(height: 20),
            Text(mess,style: TextStyle(color: Colors.red),),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                  label: Text("Name",style: TextStyle(color: Colors.blue),),
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  hintText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
            ),
            SizedBox(height: 20,),
            TextField(
              maxLines: 2,
              controller: _question,
              decoration: InputDecoration(
                  label: Text("Question",style: TextStyle(color: Colors.blue),),
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  hintText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
            ),
            SizedBox(height: 20,),
            TextField(
              maxLines: 2,
              controller: _first,
              decoration: InputDecoration(
                  label: Text("First Option",style: TextStyle(color: Colors.blue),),
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  hintText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
            ),
            SizedBox(height: 20,),
            TextField(

              maxLines: 2,
              controller: _second,
              decoration: InputDecoration(
                  label: Text("Second Option",style: TextStyle(color: Colors.blue),),
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  hintText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
            ),
            SizedBox(height: 20,),
            TextField(
              maxLines: 2,
              controller: _third,
              decoration: InputDecoration(
                  label: Text("Third Option",style: TextStyle(color: Colors.blue),),
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  hintText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
            ),
            SizedBox(height: 20,),
            TextField(
              maxLines: 2,
              controller: _fourth,
              decoration: InputDecoration(
                  label: Text("Fourth Option",style: TextStyle(color: Colors.blue),),
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  hintText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
            ),
            SizedBox(height: 20,),
            TextField(
              maxLines: 2,
              controller: _correct,
              decoration: InputDecoration(
                  label: Text("Correct Option",style: TextStyle(color: Colors.blue),),
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  hintText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
            ),
            TextButton(onPressed: (){
              if (_controller.text.isNotEmpty
                  && _question.text.isNotEmpty
                  && _first.text.isNotEmpty
                  && _second.text.isNotEmpty
                  && _third.text.isNotEmpty
                  && _fourth.text.isNotEmpty
                  && _correct.text.isNotEmpty
              ){
                editdata();
              }
            }, child: Text("Save"))
          ],
        ),
      ),
    );
  }
}
