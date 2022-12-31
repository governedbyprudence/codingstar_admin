import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codingstar_admin/components/addtopicdata.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as im ;


class subcourse extends StatefulWidget {
  QueryDocumentSnapshot data;
  subcourse({required this.data});
  @override
  _subcourseState createState() => _subcourseState(data: data);
}

class _subcourseState extends State<subcourse> {
  List<Widget> widgets = [];
  int _index = 0 ;
  QueryDocumentSnapshot data;
  _subcourseState({required this.data}){
    widgets.add(add(data: data));
    widgets.add(view(data: data));
  }
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
        title: Text(data.id,style: TextStyle(color: Colors.black),),
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

class add extends StatefulWidget {
  QueryDocumentSnapshot data;
  add({required this.data});
  @override
  _addState createState() => _addState(data:data);
}

class _addState extends State<add> {
  TextEditingController _controller=new TextEditingController();
  TextEditingController _desccontroller=new TextEditingController();

  var temp_image;
  var file=null;
  var topic_url="";
  String topic_image_id=Uuid().v4();
  bool is_uploaded=false;
  QueryDocumentSnapshot data;
  _addState({required this.data});
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
  void uploadtopic(String topicname,String desc)async{
    if (file!=null) {
      await compress_image();
      await upload_image();
    }
    await FirebaseFirestore.instance.collection("courses")
        .doc(data.id)
        .collection("topics")
        .doc(topicname)
        .set({
      "name":topicname,
      "desc":desc,
      "image":topic_url,
    }).then((value) {
      print(" in done");
      setState(() {
        is_uploaded=false;
      });
    }).catchError((err)=>print("err"));
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
          TextFormField(
            controller: _controller,
            style: TextStyle(),
            decoration: InputDecoration(
                fillColor: Colors.grey.shade100,
                filled: true,
                hintText: "Topic Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                )),
          ),
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
          TextButton(onPressed:()=>selectPicture(context),child: Text("Select Image"),),
          SizedBox(
            height: 20,
          ),
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey,
            child: is_uploaded?CircularProgressIndicator():TextButton(
              onPressed: (){
                if (_controller.text.isNotEmpty && _desccontroller.text.isNotEmpty){
                  setState(() {
                    is_uploaded=true;
                  });
                  uploadtopic(_controller.text,_desccontroller.text);
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

class view extends StatefulWidget {
  QueryDocumentSnapshot data;
  view({required this.data});

  @override
  _viewState createState() => _viewState(data:data);
}

class _viewState extends State<view> {
  QueryDocumentSnapshot data;
  _viewState({required this.data});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("courses").doc(data.id).collection("topics").snapshots(),
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
                    image: DecorationImage(
                      image: NetworkImage(element.get("image")),
                    fit: BoxFit.cover,
                    ),
                    color: Colors.amber,
                  ),
                  child: ListTile(
                    trailing: TextButton(onPressed:(){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>topicdata(course:this.data.id,data: element)));
                    },child: Text("View",style: TextStyle(fontSize: 20,color: Colors.yellow),)),
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(element.id,style: TextStyle(fontSize: 25,color: Colors.white),),
                        Text(element.get("desc"),style: TextStyle(fontSize: 20,color: Colors.white),),

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
