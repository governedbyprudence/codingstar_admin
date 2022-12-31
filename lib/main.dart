import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codingstar_admin/components/home.dart';
import 'package:codingstar_admin/components/register.dart';
import 'package:codingstar_admin/components/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'components/login.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    initialRoute: "splash",
    debugShowCheckedModeBanner: false,
    routes: {
    "splash":(context)=>spashscreen(),
      "first":(context)=>first(),
    "login":(context)=>MyLogin(),
    "register":(context)=>MyRegister(),
      "home":(context)=>home(),
    },
  ));
}

class first extends StatefulWidget {
  const first({Key? key}) : super(key: key);

  @override
  _firstState createState() => _firstState();
}

class _firstState extends State<first> {
  void test(){
    FirebaseFirestore.instance.collection("temp").get().then((value) => print(value.docs.first.get("data"))).catchError((err)=>print("errrrrr"));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextButton(
        onPressed: test,
        child: Text("HLL"),
      ),
    );
  }
}

