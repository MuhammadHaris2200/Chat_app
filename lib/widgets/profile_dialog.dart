import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/model/chat_app_model.dart';
import 'package:chat_app/screen/view_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

  final ChatAPPModel user;

  @override
  Widget build(BuildContext context) {

    final mq = MediaQuery.of(context).size;

    return AlertDialog(
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * .6,
        height: mq.height * .35,
        child: Stack(
          children: [
            ///user image
            Positioned(
              top: mq.height * .07,
              left: mq.width * .03,
              right: mq.width * .02,
              bottom: mq.width * .01,
              child: ClipRRect(
                clipBehavior: Clip.hardEdge,
                borderRadius: BorderRadius.circular(mq.height * .25),
                child: CachedNetworkImage(
                  width: mq.width * .6,
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  placeholder: (context, url) =>
                      CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      CircleAvatar(child: Icon(CupertinoIcons.person))
                ),
              ),
            ),

            ///user name
            ///user name + info btn row
            Positioned(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      user.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Colors.black),
                      overflow: TextOverflow.ellipsis, // naam zyada lamba ho to ...
                    ),
                  ),
                  Positioned(
                    child: MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewProfileScreen(user: user),
                          ),
                        );
                      },
                      minWidth: 0,
                      padding: EdgeInsets.zero,
                      shape: const CircleBorder(),
                      child: const Icon(Icons.more_vert, color: Colors.blue, size: 30),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
