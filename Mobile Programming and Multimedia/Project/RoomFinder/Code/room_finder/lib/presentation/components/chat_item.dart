import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:room_finder/style/color_palette.dart';
import 'account_photo.dart';

/// The class [ChatItem] defines a single chat item belonging to a list of different chat. 
/// To correctly invoke this widget you need to specify the following required parameters: 
/// - [receiverPhoto], the account photo of the receiver;
/// - [facilityPhoto], one of the facility photos for which the user is requesting information;
/// - [receiverName], the name of the receiver;
/// - [facilityName], the name of the facility;
/// - [address] of the facility;
/// - [lastMessage], the date of last chat message;
/// - [isLastChatItem], used to don't output a divider after the final chat item (just for convenience since at the moment there is no chat implementation);
/// - [onPressed], the function that specifies what happens if the user taps on a chat item.
class ChatItem extends StatelessWidget {
  final String receiverPhoto;
  final String facilityPhoto;
  final String receiverName;
  final String facilityName;
  final String address;
  final DateTime lastMessage;
  final bool isLastChatItem;
  final void Function() onPressed;

  const ChatItem({
    super.key,
    required this.receiverPhoto,
    required this.facilityPhoto,
    required this.receiverName,
    required this.facilityName,
    required this.address,
    required this.lastMessage,
    required this.isLastChatItem,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final String formattedDate = formatter.format(lastMessage);

    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(15.w),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.network(
                      facilityPhoto,
                      width: 60.w,
                      height: 60.w,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: -5.w,
                      right: -5.w,
                      child: AccountPhoto(
                        imageUrl: receiverPhoto, 
                        size: 40.w,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.r),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receiverName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.w,
                        ),
                      ),
                      Text(
                        facilityName,
                        style: TextStyle(
                          fontSize: 14.w,
                          color: ColorPalette.oxfordBlue,
                        ),
                      ),
                      Text(
                        address,
                        style: TextStyle(
                          fontSize: 14.w,
                          color: ColorPalette.oxfordBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 14.w,
                    color: ColorPalette.oxfordBlue,
                  ),
                ),
              ],
            ),
          ),
          if(!isLastChatItem)...[
            Divider(
              indent: 15.w,
              endIndent: 15.w,
              color: const Color.fromRGBO(78, 128, 240, 47),
            ),
          ]
        ],
      ),
    );
  }
}
