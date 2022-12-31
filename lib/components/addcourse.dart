import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codingstar_admin/components/addsubcourse.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as im ;

class addcourse extends StatefulWidget {
  const addcourse({Key? key}) : super(key: key);

  @override
  _addcourseState createState() => _addcourseState();
}

class _addcourseState extends State<addcourse> {
  TextEditingController _controller=new TextEditingController();
  TextEditingController _desccontroller=new TextEditingController();

  var temp_image;
  var file=null;
  var course_url="";
  int _sel_index=0,_sel_index_u=0;
  String course_image_id=Uuid().v4();
  bool is_uploaded=false;
  compress_image()async{
    print("in compress");
    var tempdir = await getTemporaryDirectory();
    var path = tempdir.path;
    var imagefile = im.decodeImage(File(file.path).readAsBytesSync());
    var compressed_file = File("$path/img_$course_image_id.jpg")..writeAsBytesSync(
        im.encodeJpg(imagefile!,quality: 50)
    );
    setState(() {
      file = compressed_file;
    });
    print("Compress done");
  }
  upload_image()async{
    print("in upload");
    var file_snap =await FirebaseStorage.instance.ref().child("course_$course_image_id.jpg")
        .putFile(file);
    var file_url = await file_snap.ref.getDownloadURL();
    setState(() {
      course_url=file_url;
    });
    print("course done");
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
  void uploadcourse(String coursename,String desc,String type)async{
    if (file!=null) {
      await compress_image();
      await upload_image();
    }
    await FirebaseFirestore.instance.collection(_sel_index_u==0?"courses":"upcoming")
        .doc(coursename)
        .set({"name":coursename,"image":course_url,"desc":desc,"type":type})
        .then((value) {
      print("done");
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
          Text("Enter Details of the course :",style: TextStyle(fontSize: 30),),
          SizedBox(height: 40,),
          TextFormField(
            controller: _controller,
            style: TextStyle(),
            decoration: InputDecoration(
                fillColor: Colors.grey.shade100,
                filled: true,
                hintText: "Course Name",
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
                hintText: "Course Description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                )),
          ),
          TextButton(onPressed:()=>selectPicture(context),child: Text(file==null?"Select Image":"Image selected. Click to change"),),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _sel_index==0?Colors.green:Colors.grey,
                ),
                child: TextButton(
                  onPressed: (){

                    setState(() {
                      _sel_index = 0;
                    });
                  },
                  child: Text("Free",style: TextStyle(color: Colors.black),),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: _sel_index==1?Colors.green:Colors.grey,
                ),
                child: TextButton(
                  onPressed: (){

                    setState(() {
                      _sel_index = 1;
                    });
                  },
                  child: Text("Paid",style: TextStyle(color: Colors.black),),
                ),
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _sel_index_u==0?Colors.green:Colors.grey,
                ),
                child: TextButton(
                  onPressed: (){

                    setState(() {
                      _sel_index_u = 0;
                    });
                  },
                  child: Text("Complete",style: TextStyle(color: Colors.black),),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: _sel_index_u==1?Colors.green:Colors.grey,
                ),
                child: TextButton(
                  onPressed: (){

                    setState(() {
                      _sel_index_u = 1;
                    });
                  },
                  child: Text("Upcoming",style: TextStyle(color: Colors.black),),
                ),
              )
            ],
          ),
          SizedBox(height: 20,),
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey,
            child: is_uploaded?CircularProgressIndicator():TextButton(
              onPressed: (){
                if (_controller.text.isNotEmpty && _desccontroller.text.isNotEmpty){
                  setState(() {
                    is_uploaded=true;
                  });
                  uploadcourse(_controller.text,_desccontroller.text,_sel_index==0?"free":"paid");
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

class viewcourse extends StatefulWidget {
  const viewcourse({Key? key}) : super(key: key);

  @override
  _viewcourseState createState() => _viewcourseState();
}

class _viewcourseState extends State<viewcourse> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("courses").snapshots(),
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
                    image: DecorationImage(image: NetworkImage(element.get("image",),),
                      fit: BoxFit.cover
                    ),
                      color: Colors.red[800],
                  ),
                  child: ListTile(
                    trailing: TextButton(onPressed:(){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>subcourse(data: element)));
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
            if (data.isEmpty){
              data.add(
                  Center(
                    child: Text("No Courses Added",style: TextStyle(fontSize: 20),),
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
