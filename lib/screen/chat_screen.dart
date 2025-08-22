import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/auth/apis.dart';
import 'package:chat_app/date_time_helper.dart';
import 'package:chat_app/model/chat_app_model.dart';
import 'package:chat_app/model/message_model.dart';
import 'package:chat_app/screen/view_profile_screen.dart';
import 'package:chat_app/ui_helper.dart';
import 'package:chat_app/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatScreen extends StatefulWidget {
  final ChatAPPModel user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ///for storing all messages
  List<MessageModel> _list = [];

  ///controller
  TextEditingController _textEditingController = TextEditingController();

  bool _showEmoji = false;

  @override
  void initState() {
    super.initState();

    // Status bar & nav bar color set karna
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
      ),
    );
  }

  ///Iska kaam ListView ko control karna, scroll karwana ya position lena.
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    ///media query for getting device screen size
    final mq = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.grey.shade100, // Same as your background
        statusBarIconBrightness:
            Brightness.dark, // icons like time/battery = dark color
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: WillPopScope(
            ///ye isliye lagaya ha takay jb user back btn press kre tw emoji key board hat jaye na k
            ///screen se bahar chla jae
            onWillPop: () {
              if (_showEmoji) {
                setState(() {
                  _showEmoji = !_showEmoji;
                });
                return Future.value(false);
              } else {
                return Future.value(true);
              }
            },
            child: Scaffold(
              backgroundColor: Color.fromARGB(255, 234, 248, 255),
              appBar: AppBar(
                automaticallyImplyLeading: false,
                //toolbarHeight: 50,
                flexibleSpace: _appBar(context),
                backgroundColor: Color(0xFFFFFFFF), // Set again to match
                elevation: 0, // Flat look
              ),

              ///in body where we call (_chat Input func)
              body: Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: APIs.getAllMessages(widget.user),
                      builder: (context, snapshot) {
                        ///if data is loading
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return SizedBox();

                          ///if some or all data is loaded then show it
                          case ConnectionState.active:
                          case ConnectionState.done:

                            ///firebase se ane vala sara data (myData) variable ma store krva diya
                            final myData = snapshot.data?.docs;

                            ///ye aik list ha name(myList) jo firebase se ane vale data ko map ki shkl
                            ///ma bana rhi ha phir (ChatAppModel) class ki help se us data ko jo firebase
                            ///se aya ha from json func ma convert kr k us data ko dart list ka object bana
                            ///rhi ha or agr data null ho tw empty list return krva di
                            _list =
                                myData
                                    ?.map(
                                      (e) => MessageModel.fromJson(e.data()),
                                    )
                                    .toList() ??
                                [];

                            ///smooth Scrolling func
                            ///or yaha hum ne ye scrolling func isliye lagaya ha takay jb dosra user bhi
                            ///message bheje tw list scroll ho automatically as like whats app
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_scrollController.hasClients) {
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              }
                            });

                            ///phir yaha (list view builder) use kiya ha jo data ko build kr k screen pe show krega
                            ///or hum ne is k sath (Message card class) ko return krvaya ha jis ma data model k
                            ///zrye arha ha
                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                controller: _scrollController,

                                ///yaha item count pe ma ne kaha k agr search vala icon open ha tw (_searchList)
                                /// vale items lo or agr off ha tw (_myList) vale items lo
                                itemCount: _list.length,
                                padding: EdgeInsets.only(top: 2),
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  ///yaha hum ne (MessageCard) ko return krvaya ha or parameter ma kaha ha k
                                  ///us (MessageCard) class k andr (_list) k items show kro
                                  return MessageCard(
                                    messageModel: _list[index],
                                  );
                                },
                              );
                            } else {
                              return Center(
                                child: Text(
                                  "Say Hi! 👋",
                                  style: TextStyle(fontSize: 20),
                                ),
                              );
                            }
                        }
                      },
                    ),
                  ),
                  _chatInput(),

                  ///emoji picker functionality
                  // if(_showEmoji)
                  //  SizedBox(
                  //        height: mq.height * .35,
                  //        child: EmojiPicker(
                  //        textEditingController: _textEditingController,
                  //        config: Config(
                  //        emojiViewConfig: EmojiViewConfig(
                  //        emojiSizeMax: 32 *
                  //        (Platform.isIOS ?  1.20 :  1.0),
                  //        ),
                  //        ),
                  //        ),
                  //  )
                  if (_showEmoji)
                    SizedBox(
                      height: mq.height * .35,
                      child: EmojiPicker(
                        textEditingController: _textEditingController,
                        config: Config(
                          emojiViewConfig: EmojiViewConfig(
                            backgroundColor:
                                Colors.white, // Emoji area ka background
                            emojiSizeMax: 32 * (Platform.isIOS ? 1.20 : 1.0),
                          ),
                          searchViewConfig: SearchViewConfig(
                            backgroundColor:
                                Colors.white, // Search bar ka background
                            hintText: 'Search Emoji...',
                            //hintText: TextStyle(color: Colors.white70),
                          ),
                          categoryViewConfig: CategoryViewConfig(
                            backgroundColor:
                                Colors.white, // Category bar ka background
                            iconColor: Colors.grey,
                            iconColorSelected: Colors.blue,
                          ),
                        ),
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

  ///custom app bar
  Widget _appBar(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ViewProfileScreen(user: widget.user),));
      },
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;

          ///us snapshot ka data ko list ma convert krva diya
          final list =
              data?.map((e) => ChatAPPModel.fromJson(e.data())).toList() ?? [];

          return Row(
            children: [
              ///for back button
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back),
              ),

              ///to show user profile picture
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .3),
                child: CachedNetworkImage(
                  width: mq.height * .05,
                  height: mq.height * .05,
                  imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),

              ///for adding some space
              SizedBox(width: 10),

              ///for (user name) and (last active)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.isNotEmpty ? list[0].name : widget.user.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    list.isNotEmpty
                        ? list[0].isOnline
                              ? "online"
                              : MyDateUtil.getLastActiveTime(
                        context: context, lastActive: list[0].lastActive)
                        : MyDateUtil.getLastActiveTime(
                        context: context, lastActive: widget.user.lastActive),
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  ///bottom chat input field
  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              color: Colors.white,
              child: Row(
                children: [
                  ///emoji button
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });
                    },
                    icon: Icon(
                      Icons.emoji_emotions,
                      color: Colors.blue,
                      size: 26,
                    ),
                  ),

                  ///text field for type msg
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        if (_showEmoji) {
                          setState(() {
                            _showEmoji = !_showEmoji;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Message...",
                        hintStyle: TextStyle(color: Colors.blue),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  ///image button for pick image from gallery
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.image, color: Colors.blue, size: 26),
                  ),

                  ///pick image from camera
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                  ),
                  SizedBox(width: 5),
                ],
              ),
            ),
          ),

          ///button for send msg
          MaterialButton(
            minWidth: 0,
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: CircleBorder(),
            color: Colors.green,
            onPressed: () {
              if (_textEditingController.text.isNotEmpty) {
                if(_list.isNotEmpty){
                  ///on first message add user to my_user collection of chat user
                  APIs.sendFirstMessage(
                      widget.user,
                      _textEditingController.text,
                      Type.text);
                }else{
                  ///simply send message
                  APIs.sendMessage(
                    widget.user,
                    _textEditingController.text,
                    Type.text,
                  );
                }
                _textEditingController.clear();

                ///scrolling func we also called at send btn
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });
              }
            },
            child: Icon(Icons.send, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}
