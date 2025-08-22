import 'package:chat_app/auth/apis.dart';
import 'package:chat_app/screen/home_screen.dart';
import 'package:chat_app/ui_helper.dart';
import 'package:flutter/material.dart';

class LoginClass extends StatefulWidget {
  const LoginClass({super.key});
  @override
  State<LoginClass> createState() => _LoginClassState();
}


class _LoginClassState extends State<LoginClass> {

  bool _isAnimate=false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 0),(){
      _isAnimate = true;
      setState(() {});
    });
  }
  @override
  Widget build(BuildContext context) {

    final mq = MediaQuery.of(context).size;

    // func for signIn user with google
    _handleGoogleClickBtn(){

      // for showing circular progress
      Uihelper.showCircularProgress(context);

      // this is the class for signIn user with google
      APIs().signInWithGoogle(context).then((user)async{

        // if user signIn stop the indicator
        Navigator.pop(context);

        //if block ma kaha ha k agr user exist krta ha tw uski self info bhi lo or
        //phir usko (Home Screen) pe le kr jao or agr nh krta exist tw else block
        //ma jao user create kro or phir uski self info bhi lo or us k bd (Home Screen) pe jao
        if (user != null) {
          if (await APIs.userExists()) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else {
            await APIs.userCreated();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
        }

      });
     }
    return Scaffold(
      appBar: AppBar(
          title: Text("Welcome To We Chat")),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: mq.height * 0,
            width: mq.width * .99,
            right: _isAnimate ? mq.width * .03 : -mq.width * .99,
            //right: mq.width * .10,
              duration: Duration(milliseconds: 1000),
            child: Image.asset(
              'assets/images/—Pngtree—sky blue chat conversation icon_5462750.png',
              //height: 100,
              //width: 100,
              fit: BoxFit.cover,
            )

          ),
          Positioned(
            bottom: mq.height * .07,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * .07,
            // child: buildGoogleLoginButton(),
            child: ElevatedButton.icon(
              onPressed: () async {
                _handleGoogleClickBtn();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255,219,255,178),
                side: BorderSide(color: Colors.grey),
                elevation: 7,
                shape: StadiumBorder(
                  //borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: Image.asset("assets/images/Google__G__logo.svg.webp",height: mq.height * .04,),
              label: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black,fontSize: 19),
                  children: [
                    TextSpan(text: "Login with ",),
                    TextSpan(text: "Google",style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
