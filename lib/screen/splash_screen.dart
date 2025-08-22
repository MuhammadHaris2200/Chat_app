import 'package:chat_app/auth/apis.dart';
import 'package:chat_app/screen/login_class.dart';
import 'package:chat_app/screen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 2000),(){
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(systemNavigationBarColor: Colors.white,statusBarColor: Colors.white),
      );
      if(APIs.auth.currentUser!=null){
        //print("\nUser:${APIs.auth.currentUser}");
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => HomeScreen(),));
      }else{
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => LoginClass(),));
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final mq=MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome To We Chat"),
      ),
      body: Stack(
        children: [
          Positioned(
              width: mq.width * .5,
              top: mq.height * .15,
              right: mq.width * .25,
              child: Image.asset("assets/images/image_14293272.png")),
          Positioned(
            bottom: mq.height * .15,
              left: mq.width * .27,
              child: RichText(text: TextSpan(children: [
                TextSpan(text: "M",style: TextStyle(fontSize: 20,color: Colors.teal,letterSpacing: .5,
                    fontWeight: FontWeight.bold)),
                TextSpan(text: "a",style: TextStyle(fontSize: 16,color: Colors.teal,letterSpacing: .5)),
                TextSpan(text: "d",style: TextStyle(fontSize: 16,color: Colors.teal,letterSpacing: .5)),
                TextSpan(text: "e ",style: TextStyle(fontSize: 16,color: Colors.teal,letterSpacing: .5)),
                TextSpan(text: "B",style: TextStyle(fontSize: 20,color: Colors.brown,letterSpacing: .5,
                    fontWeight: FontWeight.bold)),
                TextSpan(text: "y ",style: TextStyle(fontSize: 16,color: Colors.brown,letterSpacing: .5)),
                TextSpan(text: "H",style: TextStyle(fontSize: 20,color: Colors.black,letterSpacing: .5,
                    fontWeight: FontWeight.bold)),
                TextSpan(text: "A",style: TextStyle(fontSize: 16,color: Colors.black,letterSpacing: .5)),
                TextSpan(text: "R",style: TextStyle(fontSize: 16,color: Colors.black,letterSpacing: .5)),
                TextSpan(text: "I",style: TextStyle(fontSize: 16,color: Colors.black,letterSpacing: .5)),
                TextSpan(text: "S ",style: TextStyle(fontSize: 16,color: Colors.black,letterSpacing: .5)),
                TextSpan(text: "A",style: TextStyle(fontSize: 20,color: Colors.pink,letterSpacing: .5,
                    fontWeight: FontWeight.bold)),
                TextSpan(text: "R",style: TextStyle(fontSize: 16,color: Colors.pink,letterSpacing: .5)),
                TextSpan(text: "I",style: TextStyle(fontSize: 16,color: Colors.pink,letterSpacing: .5)),
                TextSpan(text: "F",style: TextStyle(fontSize: 16,color: Colors.pink,letterSpacing: .5)),
              ]))
          )
        ],
      ),
    );
  }
}
