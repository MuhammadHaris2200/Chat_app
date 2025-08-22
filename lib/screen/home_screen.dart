import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/auth/apis.dart';
import 'package:chat_app/model/chat_app_model.dart';
import 'package:chat_app/screen/login_class.dart';
import 'package:chat_app/screen/profile_screen.dart';
import 'package:chat_app/ui_helper.dart';
import 'package:chat_app/widgets/chat_users_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //ye aik list ha jis ki type ChatAppModel ha jo data ko model k from json
  //func se le rhi ha or usko neeche listview builder ki help se one by one
  //screen pe show kr rhi ha or is list ko hum ne (Chat User Card) class ko
  //call krte vaqt pass kiya ha takay jo bhi user add hote jaye vo screen pe
  //list ki shkl ma show ho (In short for new users)
  List<ChatAPPModel> _myList = [];

  //ye vo list ha jb user (Home Screen) ma (Search Bar) pe click krega tw jo
  //users agr available honge tw vo  is list ma show jaenge jese whats app ma
  // hote ha searching pe (In short those users store which are in serch item)
  final List<ChatAPPModel> _searchList = [];

  //this bool tells us that searching is on or off
  bool _isSearching = false;

  //is init state ka mtlb ha k jese hi official user jo app use kr rha ha
  //vo apne account se login kre uski self information ko store krlo
  @override
  void initState() {
    super.initState();
    _loadSelfInfo();

    ///for setting user status to active
    APIs.updateActiveStatus(true);

    ///Ye code app ke open/close hone par user ka "online"/"offline"
    /// status Firebase me update kar raha hai.
    SystemChannels.lifecycle.setMessageHandler((message){
      if(APIs.auth.currentUser != null){

        if(message.toString().contains("resume")) {
          APIs.updateActiveStatus(true);
        }
        if(message.toString().contains("pause")) {
          APIs.updateActiveStatus(false);
        }

      }
      return Future.value(message);
    });
  }

  void _loadSelfInfo() async {
    await APIs.getSelfInfo();
    setState(() {}); /// Refresh UI jab data load ho jaye
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(

          //ye title ma, ma ne kaha ha k agr (_isSearching) true hojata ha tw aik
          //text field show krva do varna else func hi rehne do.
          //tw (_isSearching) search icon k click pe (true) hojaega or (text Field)
          //show hojaegi
          title: _isSearching
              ? TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Search..."
            ),
            autofocus: true,
            style: TextStyle(fontSize: 17,letterSpacing: 0.5),
            onChanged: (value){

              //it clear old values of list
              _searchList.clear();

              //ye aik loop chl rha ha k (_myList) ka har element (i) k andr show krdo
              //or us vaqt tk loop chlate rho jb tk saray element add nh hojate _myList
              //k (i) ma
              for(var i in _myList){
                if(i.name.toLowerCase().contains(value.toLowerCase()) ||
                    (i.email.toLowerCase().contains(value.toLowerCase()))){
                  _searchList.add(i);
                };
                setState(() {
                  _searchList;
                });
              }
            },
          )
              :Text("We Chat"),

          leading: Icon(CupertinoIcons.home),
          actions: [
            // search user btn
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                });
              },
              icon: Icon(
                  _isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search),
            ),

            // more features btn
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(user: APIs.me),
                  ),
                );
              },
              icon: Icon(Icons.more_vert),
            ),
          ],
        ),

        // FAB btn to add new users
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 30,right: 10),
          child: FloatingActionButton(
            onPressed: () async {
              _addChatUserDialog();
            },
            shape: CircleBorder(),
            child: Icon(Icons.add_comment_rounded),
          ),
        ),

        /// stream builder use to fetch real time data from firebase
        body: StreamBuilder(
          stream: APIs.getMyUsersId(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return SizedBox();

            ///if some or all data is loaded then show it
              case ConnectionState.active:
              case ConnectionState.done:
           return StreamBuilder(
              stream: APIs.getAllUsers(
                snapshot.data?.docs.map((e) => e.id).toList() ?? []
              ),
              builder: (context, snapshot) {
                ///if data is loading
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return SizedBox();

                ///if some or all data is loaded then show it
                  case ConnectionState.active:
                  case ConnectionState.done:

                  /// firebase se ane vala sara data (myData) variable ma store krva diya
                    final myData = snapshot.data?.docs;

                    /// ye aik list ha name(myList) jo firebase se ane vale data ko map ki shkl
                    /// ma bana rhi ha phir (ChatAppModel) class ki help se us data ko jo firebase
                    /// se aya ha from json func ma convert kr k us data ko dart list ka object bana rhi ha
                    /// or agr data null ho tw empty list return krva di
                    _myList = myData?.map((e) => ChatAPPModel.fromJson(e.data())).toList() ?? [];


                    ///ye condition isliye ha takay agr user koi esa name search krta ha jo list ma mojood hi
                    ///na ho tw (no results found) ka prompt show hoga
                    // if(_searchList.isEmpty){
                    //   return Center(
                    //     child: Text(
                    //       'No Results Found',
                    //       style: TextStyle(fontSize: 18,color: Colors.black54),
                    //     ),
                    //   );
                    // }

                    //phir yaha (list view builder) use kiya ha jo data ko build kr k screen pe show krega
                    //or hum ne is k sath (Chat user card class) ko return krvaya ha jis ma data model k
                    //zrye arha ha
                    if(_myList.isNotEmpty){
                      return ListView.builder(
                        //yaha item count pe ma ne kaha k agr search vala icon open ha tw (_searchList)
                        // vale items lo or agr off ha tw (_myList) vale items lo
                        itemCount: _isSearching
                            ?_searchList.length
                            :_myList.length,
                        padding: EdgeInsets.only(top: 2),
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {

                          //yaha return ma bhi ye hi kaha ha k agr search icon open ha (or vo true hoga tb
                          // hi open hoga) tw (_searchList) k index lo or agr off ha tw (_myList) ka index lo
                          return ChatUsersCard(user: _isSearching ?_searchList[index] :_myList[index]);
                        },
                      );
                    }
                    if(_searchList.isEmpty){
                      return Center(
                        child: Text(
                          'No Results Found',
                          style: TextStyle(fontSize: 18,color: Colors.black54),
                        ),
                      );
                    }
                    else{
                      return Center(
                        child: Text("No Connections Founds",
                          style: TextStyle(fontSize: 20),),
                      );
                    }
                }
              },
            );
          }
        },
        ),
        ),
    );
  }

  ///for adding new chat user
  void _addChatUserDialog() {
    String email = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          ///title
          title: Row(
            children: [
              Icon(Icons.person_add,color: Colors.blue, size: 30),
              SizedBox(width: 10,),
              Text("Add User",
                style: TextStyle(fontWeight: FontWeight.w500),),
            ],
          ),

          ///content
          content: TextFormField(
            maxLines: null,
            onChanged: (value) => email = value,
            decoration: InputDecoration(
              hintText: "Email Id",
              labelText: "Email Id",
              prefixIcon: Icon(Icons.email,color: Colors.blue,),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),

          ///actions
          actions: [
            ///cancel btn
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
            ///add btn
            MaterialButton(
              onPressed: () async{
                ///for hiding sheet
                Navigator.pop(context);

                if(email.isNotEmpty) {
                 await APIs.addChatUser(email).then((value) {
                  if(!value){
                    Uihelper.showSnackBar(context, "User does not Exist!");}
                 }
                 );
                }
              },
              child: Text(
                "Add",
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }
}
