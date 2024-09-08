import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:room_finder/presentation/components/account_photo.dart';
import 'package:room_finder/presentation/components/buttons/circle_buttons.dart';
import 'package:room_finder/presentation/components/input_text_fields.dart';
import 'package:room_finder/presentation/components/message.dart';
import 'package:room_finder/presentation/components/screens_templates.dart';
import 'package:room_finder/style/color_palette.dart';

class ChatDetailPage extends StatelessWidget {
  final String receiverImageUrl;
  final String receiverName;
  final String facilityName;
  final DateTime lastMessage;
  final bool isHost;
  final void Function() onTap;

  const ChatDetailPage({
    super.key, 
    required this.receiverImageUrl,
    required this.receiverName,
    required this.facilityName,
    required this.lastMessage,
    required this.isHost,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return SecondaryTemplateScreen(
      leftHeaderWidget: DarkBackButton(onPressed: () => Navigator.pop(context)), 
      centerHeaderWidget: AccountPhoto(size: 50.w, imageUrl: receiverImageUrl), 
      content: ChatDetailPageBody(
        receiverImageUrl: receiverImageUrl, 
        receiverName: receiverName, 
        facilityName: facilityName, 
        lastMessage: lastMessage, 
        isHost: isHost,
        onTap: onTap
      )
    );
  } 
}

class ChatDetailPageBody extends StatelessWidget {
  final String receiverImageUrl;
  final String receiverName;
  final String facilityName;
  final DateTime lastMessage;
  final bool isHost;
  final void Function() onTap;

  const ChatDetailPageBody({
    super.key,
    required this.receiverImageUrl,
    required this.receiverName,
    required this.facilityName,
    required this.lastMessage,
    required this.isHost,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(height: 5.h),
          Text(
            receiverName,
            style: TextStyle(
              color: ColorPalette.oxfordBlue,
              fontSize: 16.w,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            facilityName,
            style: TextStyle(
              color: ColorPalette.oxfordBlue,
              fontSize: 14.w,
            ),
          ),
          SizedBox(height: 10.h),
          Divider(
            indent: 20.w,
            endIndent: 20.w,
          ),
          SizedBox(height: 10.h),
          Text(
            DateFormat('d MMM yyyy').format(lastMessage),
            style: TextStyle(
              color: ColorPalette.oxfordBlue,
              fontSize: 14.h,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                if(isHost) ...[
                  const Message(
                    message: "Good afternoon, I'm a student who is looking for an accommodation in Padova. Is your proposal still available?",
                    isSent: false,
                    time: '05:35 PM',
                  ),
                  const Message(
                    message: "Good afternoon, the room is still available.",
                    isSent: true,
                    time: '05:40 PM',
                  ),
                  const Message(
                    message: "Great! Can we share our phone numbers to discuss more about the proposal?",
                    isSent: false,
                    time: '05:50 PM',
                  ),
                ],
                if(!isHost) ...[
                  const Message(
                    message: "Good afternoon, I'm a student who is looking for an accommodation in Padova. Is your proposal still available?",
                    isSent: true,
                    time: '05:35 PM',
                  ),
                  const Message(
                    message: "Good afternoon, the room is still available.",
                    isSent: false,
                    time: '05:40 PM',
                  ),
                  const Message(
                    message: "Great! Can we share our phone numbers to discuss more about the proposal?",
                    isSent: true,
                    time: '05:50 PM',
                  ),
                ]
                
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(25.w),
            child: MessageInputField(onTap: onTap),
          ),
        ],
      ),
    );
  }
}
