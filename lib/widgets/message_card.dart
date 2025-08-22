import 'package:chat_app/auth/apis.dart';
import 'package:chat_app/date_time_helper.dart';
import 'package:chat_app/model/message_model.dart';
import 'package:chat_app/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///for showing single message details
class MessageCard extends StatefulWidget {
  final MessageModel messageModel;
  const MessageCard({super.key, required this.messageModel});

  @override
  State<MessageCard> createState() => _MState();
}

class _MState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    ///yaha hum ne condition lagayi ha k agr App k ander jo user login ha uski Id or jis ne message
    ///kiya ha vo dono Id same ho tw (_greenMessage) dikhao varna (_blueMessage)

    bool isMe = APIs.user.uid == widget.messageModel.fromId;

    return InkWell(
      onLongPress: () {
        showBottomSheet(context, isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  ///sender or another user
  Widget _blueMessage() {
    final mq = MediaQuery.of(context).size;

    ///iss update read messages func ko hum ne (_blue message) k andr is liye likha ha qk hum sirf
    ///receiver ka update status dekhna chahte ha k us ne msg seen kiya k nh or agr vo seen krlega
    ///tw blue tick show hoga
    if (widget.messageModel.read.isEmpty) {
      APIs.updateReadMessages(widget.messageModel);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ///message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(
              vertical: mq.height * .02,
              horizontal: mq.width * .04,
            ),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 221, 245, 255),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
                topLeft: Radius.circular(30),
              ),
              border: Border.all(color: Colors.lightBlue, width: 2),
            ),
            child: Text(
              widget.messageModel.msg,
              style: TextStyle(fontSize: 15, letterSpacing: 0.5),
            ),
          ),
        ),

        ///message sent time
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            MyDateUtil.getFormattedTime(
              context: context,
              time: widget.messageModel.sent,
            ),
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  ///our or user message
  Widget _greenMessage() {
    final mq = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            ///for adding some space
            SizedBox(width: mq.width * .04),

            ///double tick icon
            ///yaha hum ne ye condition lagayi ha k agr hum ne koi msg kiya ha or receiver
            ///ne seen nh kiya tw us vaqt tk double tick show nh krvao or agr seen krliya ha tw
            ///show krva do
            ///or tick show krvane k liye hum ne agay func banaya ha
            //if (widget.messageModel.read.isNotEmpty)
            widget.messageModel.read.isNotEmpty
                ? Icon(Icons.done_all_rounded, color: Colors.blue.shade400)
                : Icon(Icons.done, color: Colors.grey),

            ///for showing some space
            SizedBox(width: 2),

            ///message sent time
            ///yaha hum ne msgs ka current time dikhane k liye message model class ki (sent) field
            ///ko (MyDateUtil) class k (getFormattedTime) ma call krdiya
            Text(
              MyDateUtil.getFormattedTime(
                context: context,
                time: widget.messageModel.sent,
              ),
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),

        ///message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(
              vertical: mq.height * .02,
              horizontal: mq.width * .04,
            ),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 218, 255, 176),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                topLeft: Radius.circular(30),
              ),
              border: Border.all(color: Colors.lightGreen, width: 2),
            ),
            child: Text(
              widget.messageModel.msg,
              style: TextStyle(fontSize: 15, letterSpacing: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  ///bottom sheet
  void showBottomSheet(BuildContext context, bool isMe) {
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
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                vertical: mq.height * .015,
                horizontal: mq.width * .4,
              ),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            ///Copy Text option
            widget.messageModel.type == Type.text
                ? _OptionItem(
                    icon: Icon(
                      Icons.copy_all_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: "Copy Text",
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(text: widget.messageModel.msg)).then((value) {
                          ///for hiding bottom sheet
                          Navigator.pop(context);
                          ///for show snack bar msg after copied text
                          Uihelper.showSnackBar(context, "Text Copied!");
                        },);
                    },
                  )
                : _OptionItem(
                    icon: Icon(
                      Icons.download_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: "Copy Image",
                    onTap: () {},
                  ),

            ///Divider or separator
            if (isMe)
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),

            ///Edit message
            if (isMe)
              _OptionItem(
                icon: Icon(Icons.delete_forever, color: Colors.red, size: 26),
                name: "Delete Message",
                onTap: () async {

                  await APIs.deleteMessage(widget.messageModel).then((value) {
                    ///for hiding bottom sheet
                    Navigator.pop(context);
                  },);
                },
              ),

            ///Delete message
            ///ye condition isliye lagayi ha k jo message model se data arha ha agr uski type text ho
            ///na tb hi edit krne ka option dena or sirf hum apne hi msg edit kr skhe us k liye (isMe likha)
            if (widget.messageModel.type == Type.text && isMe)
              _OptionItem(
                icon: Icon(Icons.edit, color: Colors.blue, size: 26),
                name: "Edit Message",
                onTap: () {
                  _showMessageUpdateDialog();

                  ///for hiding bottom sheet
                  // Navigator.pop(context);
                },
              ),

            ///Divider or separator
            Divider(
              color: Colors.black54,
              endIndent: mq.width * .04,
              indent: mq.width * .04,
            ),

            ///Sent option
            _OptionItem(
              icon: Icon(Icons.remove_red_eye, color: Colors.red),
              name:
                  "Sent At:  ${MyDateUtil.getMessageTime(
                      context: context, time: widget.messageModel.sent)}",
              onTap: () {},
            ),

            ///Read option
            _OptionItem(
              icon: Icon(Icons.remove_red_eye, color: Colors.blue),
              name: widget.messageModel.read.isEmpty
                  ? "Read At:  Not seen yet!"
                  : "Read At:  ${MyDateUtil.getMessageTime(
                  context: context, time: widget.messageModel.read)}",
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  ///updated Message func
  void _showMessageUpdateDialog() {
    String updatedMsg = widget.messageModel.msg;

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
              Icon(Icons.message, color: Colors.blue, size: 34),
              SizedBox(width: 10,),
              Text("Update Message",
                style: TextStyle(fontWeight: FontWeight.w500),),
            ],
          ),

          ///content
          content: TextFormField(
            initialValue: updatedMsg,
            maxLines: null,
            onChanged: (value) => updatedMsg = value,
            decoration: InputDecoration(
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
            ///update btn
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
                APIs.updateMessage(widget.messageModel, updatedMsg);
                Navigator.pop(context);
              },
              child: Text(
                "Update",
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }


}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem({
    required this.icon,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
          left: mq.width * .05,
          top: mq.height * .015,
          bottom: mq.height * .015,
        ),
        child: Row(
          children: [
            icon,
            Flexible(
              child: Text(
                "   $name",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
