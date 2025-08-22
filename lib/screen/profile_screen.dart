import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/auth/apis.dart';
import 'package:chat_app/model/chat_app_model.dart';
import 'package:chat_app/screen/login_class.dart';
import 'package:chat_app/ui_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ChatAPPModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //key form variable to access form widget key globally
  final keyForm = GlobalKey<FormState>();
  //for pick image from file or gallery
   String? _image;

  @override
  Widget build(BuildContext context) {

    //for handling size
    final mq = MediaQuery.of(context).size;

    //gesture detector is liye lagaya ha takay keyboard ko screen se hatane k liye
    //kahi bhi empty jagah pe click kre tw hat jaye
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text("Profile Screen"),

          //scaffold k action ma (Log out) ki functionality di ha
          actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: IconButton(
                onPressed: (){
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Do you really want to log out?"),
                    backgroundColor: Colors.yellowAccent,
                    actions: [
                      TextButton(
                        onPressed: () async {

                          await APIs.updateActiveStatus(false);

                          /// on pressed click hone k bd firebase se Signout horha ,phir then se
                          await APIs.auth.signOut().then((value) async {

                            /// google account se signout horha ha or us k bd
                            await GoogleSignIn().signOut().then((value) {

                              /// jo dialog box open ha vo band horha ha is navigator pop se
                              Navigator.pop(context);

                              /// phir ye vala (navigator pop) home screen se bhi navigate kr rha ha
                              /// qk profile screen se navigate hone k bd user agr back press krega tw
                              /// home screen pe chla jata ha tw home screen se bhi navigate krne k liye
                              /// aik or navigator pop lagaya takay direct logout btn dabane se login page
                              /// pe jaye (USER)

                              Navigator.pop(context);

                              APIs.auth = FirebaseAuth.instance;

                              //phir is se login class pe ja rhe ha
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginClass(),
                                ),
                              );
                            });
                          });
                        },
                        child: Text(
                          "Ok",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
                icon: Text("Log out",
                style: TextStyle(color: Colors.red),))
          )
        ],),

        //body
        body:
        //ye (Form) widget (Text Form Field) se link ha or is k andr jo key pass ki
        //ha vo hi globally validation check krti ha
        Form(
          key: keyForm,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //for adding some space of user profile
                  SizedBox(width: mq.width, height: mq.height * .02),

                  //user profile picture
                  Stack(
                    children: [

                      //yaha condition lagayi ha k agr file(mtlb local) se image upload ki ha
                      //user ne tw vo upload kro else by default jo email k sath pic ha vo hi rehne do
                      _image != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * 0.1),
                        child: Image.file(
                          File(_image!),
                          width: mq.height * .2,
                          height: mq.height * .2,
                          fit: BoxFit.cover,
                        ),
                      )

                          : ClipRRect(
                        clipBehavior: Clip.hardEdge,
                        borderRadius: BorderRadius.circular(mq.height * 0.1),
                        child: CachedNetworkImage(
                          width: mq.height * .2,
                          height: mq.height * .2,
                          fit: BoxFit.cover,
                          imageUrl: widget.user.image,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        //material button jis k press krne bottom sheet open hogi
                        child: MaterialButton(
                          onPressed: () {
                            showBottomSheet(context);
                          },
                          shape: CircleBorder(),
                          elevation: 1,
                          color: Colors.white,
                          child: Icon(Icons.edit, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: mq.height * .01),

                  // this text widget for user (email)
                  Text(
                    widget.user.email,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  SizedBox(height: mq.height * .03),

                  // this text field for user (email)
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me.name = val ?? "",
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : "Required Field",
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: Colors.blue),
                      hintText: "eg. Haris Arif",
                      label: Text(
                        "Name",
                        style: TextStyle(color: Colors.black54),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: mq.height * .02),

                  //this text field for user (about)
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.me.about = val ?? "",
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : "Required Field",
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.info, color: Colors.blue),
                      hintText: "eg. Feeling Happy",
                      label: Text(
                        "About",
                        style: TextStyle(color: Colors.black54),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: mq.height * .03),

                  //this is update btn for user if they required to change his data
                  ElevatedButton.icon(
                    onPressed: () {
                      if (keyForm.currentState!.validate()) {
                        keyForm.currentState!.save();
                        APIs.updateUserInfo().then((value) {
                          Uihelper.showSnackBar(
                            context,
                            "Profile Updated Successfully",
                          );
                        });
                      }
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: mq.height * .04,
                    ),
                    label: Text(
                      "UPDATE",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.black, width: 1),
                      ),
                      elevation: 8,
                      minimumSize: Size(mq.width * .04, mq.height * .06),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        ),
      );
  }

  //this is func for pick image from local(gallery)
   void showBottomSheet(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: mq.height * .01,
                bottom: mq.height * .02,
              ),
              child: Text(
                "Pick Profile Picture",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: mq.height * .02),
                  child: Column(
                    children: [
                      Text("Gallery",style: TextStyle(fontWeight: FontWeight.w400),),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          shape: CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15),
                        ),
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            setState(() {
                              _image = image.path;
                              // yaha user gallery se jo pic lega vo show tw hojaegi lkn temporary
                              //hogi usko premenant dikhane k liye hum cloudinary pe upload krenge
                              //takay vo kahi pr store bhi hojae or permenant bhi rhe
                            });
                            Uihelper.showSnackBar(context, "Image Updated Successfully");
                            Navigator.pop(context);
                            //or yaha hum cloudinary pe upload kr rhe ha takay image kahi pr store ho
                            //final imageUrl = await APIs.uploadImageToCloudinary(image.path);

                            // if (imageUrl != null) {
                            //   //ab ye jo image user ne upload ki ha uska path hume firebase ma bhi show
                            //   //krvana ha takay jb user image change kre tw update bhi hojae (tw mtlb ye
                            //   //hova k cloudinary ma image upload horhi ha or us image ka path jo user
                            //   //gallery ya camera se select krta ha vo path firebase pe upload horha ha
                            //   // is func k zrye)
                            //   //or is image k path ko firebase pe upload krna zrori ha qk hamara project
                            //   //firebase se link ha
                            //   await APIs.updateProfileImage(imageUrl);
                            //
                            //   //or yaha pe image jese hi cloudinary pe upload hovi vo (chat app model) k
                            //   //image k equal hojaegi or ui ma bhi dikh jaegi
                            //   setState(() {
                            //     widget.user.image = imageUrl;
                            //   });

                             // Uihelper.showSnackBar(context, "Image Updated Successfully");
                            }

                            //Navigator.pop(context);
                          },
                        child: Image.asset(
                          "assets/images/download-removebg-preview.png",
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 20),
                Padding(
                  padding: EdgeInsets.only(bottom: mq.height * .02),
                  child: Column(
                    children: [
                      Text('Camera',style: TextStyle(fontWeight: FontWeight.w400),),
                      SizedBox(height: 10,),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          backgroundColor: Colors.blue.shade50,
                          fixedSize: Size(mq.width * .3, mq.height * .15),
                        ),
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.camera);
                          if (image != null) {
                            setState(() {
                              _image = image.path;
                              // yaha user gallery se jo pic lega vo show tw hojaegi lkn temporary
                              //hogi usko premenant dikhane k liye hum cloudinary pe upload krenge
                              //takay vo kahi pr store bhi hojae or permenant bhi rhe
                            });
                            Navigator.pop(context);

                            // Upload to Cloudinary
                            //final imageUrl = await APIs.uploadImageToCloudinary(image.path);

                            // if (imageUrl != null) {
                            //   // Update in Firestore
                            //   await APIs.updateProfileImage(imageUrl);
                            //
                            //   // Update local model
                            //   setState(() {
                            //     widget.user.image = imageUrl;
                            //   });
                            //
                            //   Uihelper.showSnackBar(context, "Image Updated Successfully");
                            // }

                            //Navigator.pop(context);
                          }
                        },
                        child: Image.asset(
                          "assets/images/cute-camera-cute-toy-camera-with"
                              "-adorable-design-r0iRdsYk_t-removebg-preview.png",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

}
