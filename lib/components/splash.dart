import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:codingstar_admin/components/home.dart';
import 'package:codingstar_admin/components/login.dart';
import 'package:codingstar_admin/components/register.dart';
import 'package:codingstar_admin/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class spashscreen extends StatefulWidget {
  const spashscreen({Key? key}) : super(key: key);

  @override
  _spashscreenState createState() => _spashscreenState();
}

class _spashscreenState extends State<spashscreen> {
  late bool isauth;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (FirebaseAuth.instance.currentUser != null) {
      setState(() {
        isauth = true;
        print(isauth);
      });
    }
      else{
        setState(() {
         isauth= false;
         print(isauth);
        });
    }
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(splash: Container(child: SizedBox(child: Text("Admin Panel",style: TextStyle(fontSize: 40),),),), nextScreen: isauth?home():MyLogin(),duration: 3000,);
  }
}
