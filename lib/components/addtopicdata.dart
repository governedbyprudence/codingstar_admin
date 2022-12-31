import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codingstar_admin/components/quiz.dart';
import 'package:codingstar_admin/components/text.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as im ;

class topicdata extends StatefulWidget {
  String course="";
  QueryDocumentSnapshot data;
  topicdata({required this.course,required this.data});
  @override
  _topicdataState createState() => _topicdataState(course:course,data : data);
}

class _topicdataState extends State<topicdata> {
  QueryDocumentSnapshot data;
  String course="";
  _topicdataState({required this.course,required this.data});
  int _index = 0;
  List<Widget> widgets = [];
  @override
  void initState() {
    super.initState();
    widgets.add(addtopic(course:course,data: data));
    widgets.add(viewtopic(course: course, data: data));
  print(course);
  }
  void _onitemtap(int index)
  {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text(data.id, style: TextStyle(color: Colors.black),),
      ),
      body: widgets[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add"),
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: "View"),
        ],
        selectedItemColor: Colors.blue,
        onTap: _onitemtap,
      ),
    );
  }
}


class addtopic extends StatefulWidget
{
  QueryDocumentSnapshot data;
  String course;
  addtopic({required this.course,required this.data});
  @override
  _addtopicState createState() => _addtopicState(course:course,data: data);
}

class _addtopicState extends State<addtopic> {
  TextEditingController _controller=new TextEditingController();
  TextEditingController _desccontroller=new TextEditingController();
  TextEditingController _question=new TextEditingController();
  TextEditingController _first=new TextEditingController();
  TextEditingController _second=new TextEditingController();
  TextEditingController _third=new TextEditingController();
  TextEditingController _fourth=new TextEditingController();
  TextEditingController _correct=new TextEditingController();
  var temp_image;
  var file=null;
  var topic_url="";
  Widget choice=Text("");
  String topic_image_id=Uuid().v4();
  bool is_uploaded=false;
  int _sel_index = 0;
  String course;
  QueryDocumentSnapshot data;
  _addtopicState({required this.course,required this.data});
  @override
  initState(){
    setState(() {
      choice=textwidgets();
    });
  }
  compress_image()async{
    print("in compress");
    var tempdir = await getTemporaryDirectory();
    var path = tempdir.path;
    var imagefile = im.decodeImage(File(file.path).readAsBytesSync());
    var compressed_file = File("$path/img_$topic_image_id.jpg")..writeAsBytesSync(
        im.encodeJpg(imagefile!,quality: 50)
    );
    setState(() {
      file = compressed_file;
    });
    print("Compress done");
  }
  upload_image()async{
    print("in upload");
    var file_snap =await FirebaseStorage.instance.ref().child("topic_$topic_image_id.jpg")
        .putFile(file);
    var file_url = await file_snap.ref.getDownloadURL();
    setState(() {
      topic_url=file_url;
    });
    print("topic done");
  }
  handle_gallery()async{
    Navigator.pop(context);
    var temp_file = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      file=temp_file;
      temp_image=FileImage(File(file.path));
    });
  }
  selectPicture(context) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Choose from"),
            children: [
              SimpleDialogOption(
                  onPressed: () {
                    handle_gallery();
                  },
                  child: Text("Gallery")
              ),
            ],
          );
        }
    );
  }
  void uploadtopic()async{
    if (file!=null) {
      await compress_image();
      await upload_image();
    }
    if (_sel_index == 0 && _controller.text.isNotEmpty && _desccontroller.text.isNotEmpty){
      await FirebaseFirestore.instance.collection("courses")
          .doc(course)
          .collection("topics")
          .doc(data.id)
          .collection("elements")
          .doc(_controller.text)
          .set({
        "name":_controller.text,
        "desc":_desccontroller.text,
        "type":"text",
        "image":topic_url,
      }).then((value) {
        print(" in done");
        setState(() {
          is_uploaded=false;
        });
      }).catchError((err)=>print("err"));
    }
    else if(_sel_index == 1
        && _controller.text.isNotEmpty
        && _question.text.isNotEmpty
        && _first.text.isNotEmpty
        && _second.text.isNotEmpty
        &&_third.text.isNotEmpty
        &&_fourth.text.isNotEmpty
        &&_correct.text.isNotEmpty){
      await FirebaseFirestore.instance.collection("courses")
          .doc(course)
          .collection("topics")
          .doc(data.id)
          .collection("elements")
          .doc(_controller.text)
          .set({
          "question":_question.text,
        "first":_first.text,
        "second":_second.text,
        "third":_third.text,
        "fourth":_fourth.text,
        "correct":_correct.text,
        "type":"quiz",
        "image":topic_url,
      }).then((value) {
        print(" in done");
        setState(() {
          is_uploaded=false;
        });
      }).catchError((err)=>print("err"));

    }
  }
  Widget textwidgets(){
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        TextField(
          controller: _desccontroller,
          style: TextStyle(),
          minLines: 5,
          maxLines: 5,
          decoration: InputDecoration(

              fillColor: Colors.grey.shade100,
              filled: true,
              hintText: "Topic Description",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              )),
        ),
      ],
    );
  }
  Widget quizwidgets(){
    return Column(
      children: [
        SizedBox(height: 20,),
        TextField(
          controller: _question,
          decoration: InputDecoration(
              label: Text("Question",style: TextStyle(color: Colors.red),),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              )
          ),
        ),
        SizedBox(height: 20,),
        TextField(
          controller: _first,
          decoration: InputDecoration(
              label: Text("First option",style: TextStyle(color: Colors.red),),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              )
          ),
        ),
        SizedBox(height: 20,),
        TextField(
          controller: _second,
          decoration: InputDecoration(
              label: Text("Second option",style: TextStyle(color: Colors.red),),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              )
          ),
        ),
        SizedBox(height: 20,),
        TextField(
          controller: _third,
          decoration: InputDecoration(
              label: Text("Third option",style: TextStyle(color: Colors.red),),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              )
          ),
        ),
        SizedBox(height: 20,),
        TextField(
          controller: _fourth,
          decoration: InputDecoration(
              label: Text("Fourth option",style: TextStyle(color: Colors.red),),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              )
          ),
        ),
        SizedBox(height: 20,),
        TextField(
          controller: _correct,
          decoration: InputDecoration(
              label: Text("Correct option",style: TextStyle(color: Colors.red),),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              )
          ),
        )

      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: ListView(
        children: [
          SizedBox(height: 20,),
          Text("Enter Details of the Topics :",style: TextStyle(fontSize: 30),),
          SizedBox(height: 40,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _sel_index == 0?Colors.green:Colors.grey,
                ),
                child: TextButton(
                  onPressed: (){
                    setState(() {
                      _sel_index = 0;
                      choice = textwidgets();
                    });
                  },
                  child: Text("Text",style: TextStyle(fontSize: 20,color: Colors.black),),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _sel_index == 1?Colors.green:Colors.grey,
                ),
                child: TextButton(
                  onPressed: (){
                    setState(() {
                      _sel_index = 1;
                      choice=quizwidgets();
                    });
                  },
                  child: Text("Quiz",style: TextStyle(fontSize: 20,color: Colors.black),),
                ),
              ),
            ],
          ),
          SizedBox(height: 20,),
          TextButton(onPressed:()=>selectPicture(context),child: Text("Select Image"),),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: _controller,
            style: TextStyle(),
            decoration: InputDecoration(
                label: Text("Name",style: TextStyle(color: Colors.red),),
                fillColor: Colors.grey.shade100,
                filled: true,
                hintText: "Topic Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                )),
          ),
          choice,
          SizedBox(
            height: 20,
          ),
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey,
            child: is_uploaded?CircularProgressIndicator():TextButton(
              onPressed: (){
                if (_controller.text.isNotEmpty){
                  setState(() {
                    is_uploaded=true;
                  });
                  uploadtopic();
                }
              },
              child: Text("Add",style: TextStyle(color: Colors.black),),
            ),
          )
        ],
      ),
    );
  }
}

class viewtopic extends StatefulWidget {
  String course;
  QueryDocumentSnapshot data;
  viewtopic({required this.course,required this.data});
  @override
  _viewtopicState createState() => _viewtopicState(course : course,data:data);
}

class _viewtopicState extends State<viewtopic> {
  String course;
  QueryDocumentSnapshot data;
  _viewtopicState({required this.course,required this.data});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("courses").doc(course).collection("topics").doc(data.id).collection("elements").snapshots(),
        builder: (context,AsyncSnapshot<QuerySnapshot> snapshot){
          Widget w=Text("None");
          if (snapshot.hasData){
            List<Widget> data=[];
            snapshot.data?.docs.forEach((element) {
              data.add(Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 140,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.amber,
                  ),
                  child: ListTile(
                    trailing: TextButton(onPressed:(){
                      print(element.get("type"));
                      if (element.get("type")=="text"){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>textview(course: course, topic: this.data.id, data: element)));

                      }
                      else if(element.get("type") == "quiz") {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>quizview(course: course, topic: this.data.id, data: element)));
                      }
                      //Navigator.push(context, MaterialPageRoute(builder: (context)=>topicdata(course:this.data.id,data: element)));
                    },child: Text("View",style: TextStyle(fontSize: 20,color: Colors.pink),)),
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(element.id,style: TextStyle(fontSize: 25),),
                      ],
                    ),
                  ),
                ),
              ));
            });
            if(data.isEmpty){
              data.add(
                  Center(
                    child: Text("No topics Added",style: TextStyle(fontSize: 20),),
                  )
              );
            }
            w=ListView(children: data,);
          }
          return w;
        },
      ),
    );
  }
}
