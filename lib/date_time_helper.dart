import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyDateUtil {
  static String getFormattedTime({required BuildContext context, required String time,}) {

    ///ye jo date variable banaya ha us k andr jo milli second epoch use kiya ha vo int
    ///ma time deta ha usko string ma use krne k liye parse use kiya ha
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));

    ///ab ye jo time aega vo bht baray format ma hoga usko jo current time chl rha ha
    ///us k jitna krne k liye ye use krenge
    return TimeOfDay.fromDateTime(date).format(context);
  }

  ///get last message time in chat user card
  static getLastMessageTime({
    required BuildContext context,
    required String time,
    bool showYear = false,
  }) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return TimeOfDay.fromDateTime(sent).format(context);
    }
    return showYear
        ? "${sent.day} ${_getMonth(sent)} ${sent.year}"
        : "${sent.day} ${_getMonth(sent)}";
  }


  ///get month name from month no. or index
  static String _getMonth(DateTime date) {
    switch (date.month) {
      case 1:
        return "Jan";
      case 2:
        return "Feb";
      case 3:
        return "Mar";
      case 4:
        return "Apr";
      case 5:
        return "May";
      case 6:
        return "Jun";
      case 7:
        return "Jul";
      case 8:
        return "Aug";
      case 9:
        return "Sep";
      case 10:
        return "Oct";
      case 11:
        return "Nov";
      case 12:
        return "Dec";
      default:
        return "NA";
    }
  }


  ///get formatted last active time of user in chat screen
  static String getLastActiveTime(
      {required BuildContext context, required String lastActive}) {
    final int i = int.tryParse(lastActive) ?? -1;

    //if time is not available then return below statement
    if (i == -1) return 'Last seen not available';

    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    DateTime now = DateTime.now();

    String formattedTime = TimeOfDay.fromDateTime(time).format(context);
    if (time.day == now.day &&
        time.month == now.month &&
        time.year == time.year) {
      return 'Last seen today at $formattedTime';
    }

    if ((now.difference(time).inHours / 24).round() == 1) {
      return 'Last seen yesterday at $formattedTime';
    }

    String month = _getMonth(time);

    return 'Last seen on ${time.day} $month on $formattedTime';
  }


/// for getting formatted time for sent & read
  static String getMessageTime({required String time, required BuildContext context}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    final String formattedTime = DateFormat('h:mm a').format(sent);

    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return formattedTime;
    }

    final String formattedDate = now.year == sent.year
        ? '${sent.day} ${_getMonth(sent)}'
        : '${sent.day} ${_getMonth(sent)} ${sent.year}';

    return '$formattedTime - $formattedDate';
  }

}
