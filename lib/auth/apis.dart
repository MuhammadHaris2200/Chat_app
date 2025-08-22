import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chat_app/model/chat_app_model.dart';
import 'package:chat_app/model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../ui_helper.dart';

class APIs {
  ///authentication from firebase
  static FirebaseAuth auth = FirebaseAuth.instance;

  ///to return current user
  static User get user => auth.currentUser!;

  ///for access data from firestore firebase
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  ///for storing self information in this variable (me)
  static late ChatAPPModel me;

  ///func for google sign In
  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      await InternetAddress.lookup("google.com");
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await auth.signInWithCredential(credential);
    } catch (e) {
      Uihelper.showSnackBar(context, "Something went wrong (Check Internet!)");
      return null;
    }
  }

  ///for checking if user exists or not
  static Future<bool> userExists() async {
    return (await firestore.collection("User").doc(auth.currentUser!.uid).get())
        .exists;
  }

  ///if user not created
  static Future<void> userCreated() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatAPPModel(
      id: auth.currentUser!.uid,
      about: "Hey, there I'm using we chat!",
      name: auth.currentUser!.displayName.toString(),
      email: auth.currentUser!.email.toString(),
      image: auth.currentUser!.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: "",
    );
    return await firestore
        .collection("User")
        .doc(auth.currentUser!.uid)
        .set(chatUser.toJson());
  }

  ///for getting id of only known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection("User")
        .doc(user.uid)
        .collection("my_users")
        .snapshots();
  }


  ///for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(List<String> userIds){
    return
      firestore
          .collection("User")
          .where("id",whereIn: userIds)
          .snapshots();
  }

  ///Current user info (mtlb jo current user ha means me)
  static Future<void> getSelfInfo() async {
    final user = await firestore
        .collection("User")
        .doc(auth.currentUser!.uid)
        .get();

    if (user.exists) {
      me = ChatAPPModel.fromJson(user.data()!);
      log("My Data ${user.data()}");
    } else {
      await userCreated();
      await getSelfInfo();
    }
  }

  ///is func k zrye hum dusre user ki contacts list ma add hojate ha
  ///mtlb jis ne pehle msg kiya vo dusre suer ki chat list ma add hojata ha
  ///or phir dono users k darmiyan chatting sendMessage func k zrye start hoti ha
  ///jisko then k bd call kiya ha
  static Future<void> sendFirstMessage(ChatAPPModel chatUser, String msg, Type type) async {
    await firestore
        .collection("User")
        .doc(chatUser.id)
        .collection("my_users")
        .doc(user.uid)
        .set({})
        .then((value) => sendMessage(chatUser, msg, type),);
  }

  ///update user info func in firebase firestore
  static Future<void> updateUserInfo() async {
    await firestore.collection("User").doc(auth.currentUser!.uid).update({
      "name": me.name,
      "about": me.about,
    });
  }

  ///ye func firebase firestore k andr document ki (image field)
  ///k path ko change krta ha jo cloudinary se ata ha
  static Future<void> updateProfileImage(String url) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(auth.currentUser!.uid)
        .update({'image': url});
  }

  ///func for store image on cloudinary
  static Future<String?> uploadImageToCloudinary(String imagePath) async {
    // Cloudinary ke account ka name
    final cloudName = 'dpvg9jrhc';

    // Upload preset jo tum Cloudinary dashboard se set karte ho
    final uploadPreset = 'Cloudinary_setup';

    // Cloudinary ke image upload API ka URL
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    // Multipart request create ki (image aur fields bhejne ke liye)
    var request = http.MultipartRequest('POST', url);

    // Upload preset field set ki (required hoti hai)
    request.fields['upload_preset'] = uploadPreset;

    // Image file ko request ke files mein add kiya
    var imageFile = await http.MultipartFile.fromPath('file', imagePath);
    request.files.add(imageFile);

    // Request send ki
    var response = await request.send();

    // Check kr rhe ha agr response 200 (success) hai
    if (response.statusCode == 200) {
      // Response body ko read karo
      var responseData = await http.Response.fromStream(response);

      // JSON decode karo taake URL nikal sako
      var data = jsonDecode(responseData.body);

      // Secure URL return karo (image ka URL)
      return data['secure_url'];
    } else {
      // Agar upload fail ho gaya toh error print karo
      return null;
    }
  }

  ///for adding new chat user
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection("User")
        .where("email", isEqualTo: email)
        .get();

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      ///agr user exist krta ha tw
      firestore
          .collection("User")
          .doc(user.uid)
          .collection("my_users")
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      ///agr user exist nh krta
      return false;
    }
  }

  ///********** Chat Screen Related Apis*********

  /// chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)
  ///(ye firestore ka structure ha jaha sb se pehle aik collection hogi 'chats' name ki,
  ///phir hogi conversation_id do users ki phir us k andr messages name ki collection hogi or
  ///us messages collection k andr do users k messages store honge)

  ///useful for getting conversation id
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? "${user.uid}_$id"
      : "${id}_${user.uid}";

  ///is func k zrye hum do users k messages ko fetch kr skhenge firestore database se.
  ///is function ka call pe hum ne parameters ma kaha ha k jb ye func call ho tw (ChatAppModel)
  ///type ka object bhejenge or return krenge do users k B/W hone vali chats ki (conversationId),
  ///getConversationId function se
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
    ChatAPPModel user,
  ) {
    return firestore
        .collection("chats/${getConversationId(user.id)}/message/")
        .snapshots();
  }

  ///send message
  static Future<void> sendMessage(ChatAPPModel chatUser, String msg, Type type) async {
    ///message sending time (aslo used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    ///message model ka instance banaya or bataya k kon message send kr rha ha or kon receive
    final MessageModel message = MessageModel(
      toId: chatUser.id,
      msg: msg,
      read: '',
      type: Type.text,
      fromId: user.uid,
      sent: time,
    );

    ///firestore ka reference banaya ha jis se dono users ki id se aik unique chat id
    ///generate hogi
    final ref = firestore.collection(
      "chats/${getConversationId(chatUser.id)}/message/",
    );

    ///phir message collection k document ma un messages ko jo do users k B/W hovi unko
    ///time k zrye aik unique id bana kr save krvaya qk time har vaqt unique hota ha or
    ///phir message model ko toJson bana kr firestore ma save krva diya
    await ref.doc(time).set(message.toJson());
  }

  ///update read status of messages
  ///ye func hum isliye bana rhe ha takay jb current user dosre user ko msg sent krta ha
  ///or jb dosra user msg seen kre tw blue tick show hojae qk humen dosre user ka read status
  ///chahiye na k apna or is liye hi hum ne (from id) use ki ha jiska mtlb ha k hamari id se jo
  ///msg gya ha vo update mtlb seen hogya ha?
  static Future<void> updateReadMessages(MessageModel messageModel) async {
    await firestore
        .collection("chats/${getConversationId(messageModel.fromId)}/message/")
        .doc(messageModel.sent)
        .update({"read": DateTime.now().millisecondsSinceEpoch.toString()});
  }

  ///get last message of chats b/w two users
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
    ChatAPPModel user,
  ) {
    return firestore
        .collection("chats/${getConversationId(user.id)}/message/")
        .orderBy("sent", descending: true)
        ///query parameter ha jis ma hum ne bataya k
        /// samne vale user ki chat ka last msg show ho
        .limit(1)
        .snapshots();
  }

  ///ye func real time stream se current login in user ka data la kr dega or is ko isliye banaya ha
  ///takay hum user ki online offline vali functionality dikha skhe stream k zrye
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
    ChatAPPModel user,
  ) {
    return firestore
        .collection("User")
        .where("id", isEqualTo: user.id)
        .snapshots();
  }

  ///ye func user ki online offline status ko update krta ha jis ma agr user online ha tw vo bhi
  /// bata dega or agr jb last time online hova tha vo bhi bata dega
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection("User").doc(user.uid).update({
      "isOnline": isOnline,
      "lastActive": DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  ///update message
  static Future<void> updateMessage(
    MessageModel messageModel,
    String updatedMsg,
  ) async {
    await firestore
        .collection('chats/${getConversationId(messageModel.toId)}/message/')
        .doc(messageModel.sent)
        .update({'msg': updatedMsg});
  }

  ///for delete msg
  static Future<void> deleteMessage(MessageModel messageModel) async {
    await firestore
        .collection("chats/${getConversationId(messageModel.toId)}/message/")
        .doc(messageModel.sent)
        .delete();
  }
}

///agr images ko delete krni ho tw uski bhi functionality is deleteMessage func ma hi lagaenge
///lkn abhi cloudinary baqi ha
