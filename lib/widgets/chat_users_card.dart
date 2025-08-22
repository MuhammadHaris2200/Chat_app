import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/auth/apis.dart';
import 'package:chat_app/date_time_helper.dart';
import 'package:chat_app/model/chat_app_model.dart';
import 'package:chat_app/model/message_model.dart';
import 'package:chat_app/screen/chat_screen.dart';
import 'package:chat_app/widgets/profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUsersCard extends StatefulWidget {
  final ChatAPPModel user;
  const ChatUsersCard({super.key,required this.user});
  @override
  State<ChatUsersCard> createState() => _ChatUsersCardState();
}

class _ChatUsersCardState extends State<ChatUsersCard> {

  ///message model instance
  MessageModel? _messageModel;

  @override
  Widget build(BuildContext context) {
    final mq=MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 6,vertical: 4),
      color: Colors.grey.shade50,
      child: InkWell(
        onTap: (){
          ///for navigating to chat screen
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ChatScreen(user: widget.user),));
        },
        child: StreamBuilder(
            stream: APIs.getLastMessages(widget.user),
            builder: (context, snapshot) {

              ///snapshot ka data
              final data=snapshot.data?.docs;

              ///us snapshot ka data ko list ma convert krva diya
              final list = data
                  ?.map((e) => MessageModel.fromJson(e.data())).toList()
                  ?? [];

              ///or yaha check kiya k list empty nh ha tw list ka first element show kro
              ///lkn last show hoga qk hum ne (getLastMessages) func k andr descending true
              ///query di ha
              if(list.isNotEmpty){
                _messageModel = list[0];
              }

              return ListTile(

                ///user name
                title: Text(widget.user.name),

                ///user about
                subtitle: Text(_messageModel != null
                    ? _messageModel!.msg
                    : widget.user.about,maxLines: 1,),


                ///user profile picture
                leading:
                // CircleAvatar(child: Icon(CupertinoIcons.person),),
                InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_)=> ProfileDialog(user: widget.user));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .3),
                    child: CachedNetworkImage(
                      //width: mq.height * .55,
                      //height: mq.height * .55,
                      imageUrl: widget.user.image,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => CircleAvatar(child: Icon(CupertinoIcons.person),),
                    ),
                  ),
                ),


                ///last message time
                trailing: _messageModel == null
                    ? null
                    : _messageModel!.read.isEmpty && _messageModel!.fromId != APIs.auth.currentUser!.uid
               ? Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                      color: Colors.greenAccent.shade400,
                      borderRadius: BorderRadius.circular(mq.height * .10)
                  ),
                )
                    : Text(
                  MyDateUtil.getLastMessageTime(context: context, time: _messageModel!.sent),
                  style: TextStyle(color: Colors.black54),
                ),
              );
            })
      ),
    );
  }
}
