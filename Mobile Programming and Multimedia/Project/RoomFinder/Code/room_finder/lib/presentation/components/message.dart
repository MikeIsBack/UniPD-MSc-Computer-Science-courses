import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/style/color_palette.dart';

/// The class [Message] defines a sent message widget belonging to a chat page. 
/// To correctly invoke this component you need to specify the following required parameters:
/// - [message], the content of the sent message;
/// - [isSent], to highlight if the message was sent or received;
/// - [time], when the message was sent or received.
class Message extends StatelessWidget {
  final String message;
  final bool isSent;
  final String time;

  const Message({
    super.key,
    required this.message,
    required this.isSent,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 250.w),
            padding: EdgeInsets.all(10.w),
            margin: EdgeInsets.symmetric(vertical: 5.h),
            decoration: BoxDecoration(
              color: isSent ? ColorPalette.blueberry : ColorPalette.lavenderBlue,
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: isSent ? ColorPalette.aliceBlue : ColorPalette.oxfordBlue,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: ColorPalette.oxfordBlue,
              fontSize: 12.w,
            ),
          ),
        ],
      ),
    );
  }
}