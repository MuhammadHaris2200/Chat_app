import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/model/chat_app_model.dart';
import 'package:flutter/material.dart';

import '../date_time_helper.dart';

//view profile screen -- to view profile of user
class ViewProfileScreen extends StatefulWidget {
  final ChatAPPModel user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {

    final mq = MediaQuery.of(context).size;

    return Scaffold(
      ///app bar
        appBar: AppBar(title: Text(widget.user.name)),

        ///user about
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: mq.height * .02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Joined On: ',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 15),
              ),
              Text(MyDateUtil.getLastMessageTime(
                  context: context, time: widget.user.createdAt,showYear: true),
              style: TextStyle(color: Colors.black54,fontSize: 16),)
            ],
          ),
        ),

        ///body
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                /// for adding some space
                SizedBox(width: mq.width, height: mq.height * .03),

                ClipRRect(
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

                /// for adding some space
                SizedBox(height: mq.height * .03),

                /// user email label
                Text(widget.user.email,
                    style:
                    const TextStyle(color: Colors.black87, fontSize: 18)),

                /// for adding some space
                SizedBox(height: mq.height * .02),

                ///user about
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'About: ',
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 15),
                      softWrap: true,
                    ),
                    Flexible(
                      child: Text(widget.user.about,
                          style: const TextStyle(
                              color: Colors.black45, fontSize: 16),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
